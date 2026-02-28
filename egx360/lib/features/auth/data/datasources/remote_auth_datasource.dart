import 'dart:io';
import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/core/services/network_service.dart';
import 'package:egx/features/auth/data/model/auth_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_signin;
import 'package:egx/core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteAuthDatasource {
  Future<AuthModel> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthModel> signIn({required String email, required String password});

  Future<bool> isEmailVerified();

  Future<void> resetPassword(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> updateUserData(AuthModel user);

  Future<AuthModel> googleSignIN();

  bool get isLoggedIn;

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  });

  Future<void> logout();

  Future<void> deleteAccount(String userId);

  Future<String?> getUserFcmToken(String userId);
}

class RemoteAuthDatasourceImpl implements RemoteAuthDatasource {
  final supabase = Supabase.instance.client;

  // Sign Up
  @override
  Future<AuthModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: 'io.supabase.flutter://login-callback/',
      );

      if (res.user != null) {
        final identities = res.user!.identities;
        if (identities == null || identities.isEmpty) {
          throw const UserAlreadyExistsException('User already registered');
        }
        if (res.user!.emailConfirmedAt != null) {
          throw const UserAlreadyExistsException('User already registered');
        }

        final fcmToken = await NotificationService.getToken();
        print("DEBUG: FCM Token during SignUp: $fcmToken");

        final data = AuthModel(
          id: res.user!.id,
          name: name,
          email: email,
          avatarUrl: '',
          lastActiveAtDate: DateTime.now(),
          createdAtDate: DateTime.now(),
          updatedAtDate: DateTime.now(),
          fcmToken: fcmToken,
        );

        await supabase.from('profiles').upsert(data.toMap());
        print("DEBUG: SignUp Success for ${data.email}");
        return data;
      } else {
        throw const AuthAppException(
          'Signup failed - no user created',
          'signup_failed',
        );
      }
    } on UserAlreadyExistsException {
      rethrow;
    } on AuthApiException catch (e) {
      if (e.code == 'user_already_exists' ||
          e.code == 'email_exists' ||
          e.message.toLowerCase().contains('already registered') ||
          e.message.toLowerCase().contains('duplicate') ||
          e.statusCode == 409 ||
          e.statusCode == 422) {
        throw const UserAlreadyExistsException('User already registered');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      print(e);
      throw AuthAppException('Unexpected error: ${e.toString()}');
    }
  }

  // Sign In
  @override
  Future<AuthModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', res.user!.id)
          .maybeSingle();
      if (profileResponse == null) {
        throw const MissingDataException('Profile not found.');
      }

      final data = AuthModel.fromMap(
        profileResponse,
      ).copyWith(lastActiveAtDate: DateTime.now());

      final fcmToken = await NotificationService.getToken();
      print("DEBUG: FCM Token during SignIn: $fcmToken");

      await supabase
          .from('profiles')
          .update({
            'last_active_at': data.lastActiveAt?.toString(),
            if (fcmToken != null) 'fcm_token': fcmToken,
          })
          .eq('id', res.user!.id);

      print("DEBUG: SignIn Success for ${data.email}");

      return data;
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials' ||
          e.statusCode == 400 ||
          e.message.toLowerCase().contains('invalid login credentials')) {
        throw const MissingDataException('Invalid login credentials');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      print(e);
      throw AuthAppException('Unexpected error: ${e.toString()}');
    }
  }

  // Check Email Verification
  @override
  Future<bool> isEmailVerified() async {
    await supabase.auth.refreshSession();
    final user = supabase.auth.currentUser;
    if (user == null) return false;
    return user.emailConfirmedAt != null;
  }

  // Reset Password (Send Email)
  @override
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flutter://reset-password/',
      );
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials' ||
          e.statusCode == 400 ||
          e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('email not found')) {
        throw const UserNotFoundException('No account found for this email.');
      }
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw const AuthAppException('Something went wrong. Please try again.');
    }
  }

  // Update Password (After Reset Link)
  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthApiException catch (e) {
      throw AuthAppException(e.message, e.code);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      print(e);
      throw const AuthAppException('Unexpected error while updating password.');
    }
  }

  @override
  Future<AuthModel> googleSignIN() async {
    try {
      print("🔵 DEBUG: Starting Cross-Platform Google Sign-In for EGX360...");

      // 1. for App on Desktop (Linux/Windows)
      if (Platform.isLinux || Platform.isWindows) {
        print("💻 DEBUG: Desktop detected. Starting local server for OAuth...");

        // 1. Start local server to listen for callback
        // We use port 54321 as it's the standard Supabase local dev port
        final server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          54321,
        );

        try {
          // 2. Start OAuth flow pointing to our local server
          await supabase.auth.signInWithOAuth(
            OAuthProvider.google,
            redirectTo: 'http://localhost:54321/callback',
            authScreenLaunchMode: LaunchMode.externalApplication,
            queryParams: {
              'access_type': 'offline', // refresh token
              'prompt': 'select_account', //always ask account
            },
          );

          print(
            "🌐 DEBUG: Browser opened. Waiting for callback on localhost:54321...",
          );

          // 3. Wait for the callback request
          await for (final HttpRequest request in server) {
            final uri = request.uri;

            // Allow basic favicon requests without breaking the loop
            if (uri.path == '/favicon.ico') {
              request.response.statusCode = HttpStatus.notFound;
              await request.response.close();
              continue;
            }

            // Check for auth code (accept root path or /callback)
            if (uri.queryParameters.containsKey('code')) {
              final code = uri.queryParameters['code'];
              print("✅ DEBUG: Auth code received!");

              // Exchange code for session
              await supabase.auth.exchangeCodeForSession(code!);

              // Show success message to user in browser
              request.response
                ..statusCode = HttpStatus.ok
                ..headers.contentType = ContentType.html
                ..write('''
                  <html>
                    <body style="font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #121212; color: #fff;">
                      <h1>Login Successful!</h1>
                      <p>You can close this tab and return to the application.</p>
                      <script>window.close();</script>
                    </body>
                  </html>
                ''');
              await request.response.close();
              break; // Stop listening
            } else {
              // Handle other requests
              request.response.statusCode = HttpStatus.badRequest;
              await request.response.close();
            }
          }
        } finally {
          await server.close();
        }

        // 4. Return user profile (now logged in)
        final user = supabase.auth.currentUser;
        if (user == null) {
          throw const AuthAppException(
            'Login failed: User session not created',
          );
        }
        return await _processProfileAfterLogin(user);
      }
      // 2. for mobile platforms (Android/iOS)
      else {
        print(
          "📱 DEBUG: Mobile Platform detected. Using GoogleSignIn ID Token flow...",
        );
        final googleSignIn = g_signin.GoogleSignIn.instance;

        // الموبايل بيدعم initialize عادي
        await googleSignIn.initialize(
          clientId: dotenv.env['CLIENT_ID'],
          serverClientId: dotenv.env['SERVER_CLIENT_ID'],
        );

        final googleUser = await googleSignIn.authenticate();
        if (googleUser == null) throw const GoogleSignInCancelledException();

        final idToken = googleUser.authentication.idToken;
        final response = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken!,
        );

        return await _processProfileAfterLogin(response.user!);
      }
    } on DesktopOAuthInProgressException {
      // Rethrow this exception so the controller can handle it
      rethrow;
    } catch (e) {
      print("🔴 DEBUG: Error in googleSignIN: $e");
      throw AuthAppException('Unexpected error during Google Sign-In: $e');
    }
  }

  // herper function Profile
  Future<AuthModel> _processProfileAfterLogin(User user) async {
    final avatarUrl = user.userMetadata?['avatar_url'] ?? '';

    final profileResponse = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse == null) {
      final fcmToken = await NotificationService.getToken();
      final userProfile = AuthModel(
        id: user.id,
        name: user.userMetadata?['name'] ?? user.email ?? '',
        email: user.email ?? '',
        avatarUrl: avatarUrl,
        lastActiveAtDate: DateTime.now(),
        createdAtDate: DateTime.now(),
        updatedAtDate: DateTime.now(),
        fcmToken: fcmToken,
      );
      await supabase.from('profiles').upsert(userProfile.toMap());
      return userProfile;
    } else {
      // تحديث البيانات للمستخدم الحالي
      return AuthModel.fromMap(
        profileResponse,
      ).copyWith(lastActiveAtDate: DateTime.now());
    }
  }

  // Check if logged in before
  @override
  bool get isLoggedIn => supabase.auth.currentUser != null;

  // Update User Data
  @override
  Future<void> updateUserData(AuthModel user) async {
    try {
      await supabase.from('profiles').update(user.toMap()).eq('id', user.id);
    } on SocketException {
      throw const NetworkAppException('No internet connection.');
    } catch (e) {
      throw AuthAppException('Failed to update profile: $e');
    }
  }

  // Change Password
  @override
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw const AuthInvalidCredentialsException('Incorrect old password.');
      }
      throw AuthAppException(e.message);
    }

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  // Logout
  @override
  Future<void> logout() async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthAppException('Logout failed: ${e.message}');
    } catch (e) {
      throw UserNotFoundException('Unexpected error during logout: $e');
    }
  }

  final supabaseAdmin = SupabaseClient(
    dotenv.env['SUPABASE_URL']!,
    dotenv.env['SUPABASE_SERVICEROLE']!,
  );

  // Delete Account
  @override
  Future<void> deleteAccount(String userId) async {
    if (!await NetworkService.isConnected) {
      throw const NetworkAppException('No internet connection.');
    }

    try {
      // Delete profile data
      await supabase.from('profiles').delete().eq('id', userId);
      await supabaseAdmin.auth.admin.deleteUser(userId);

      await supabase.auth.signOut();
    } on AuthException catch (e) {
      throw AuthAppException(e.message);
    } catch (e) {
      throw UserNotFoundException('Failed to delete account: $e');
    }
  }

  @override
  Future<String?> getUserFcmToken(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('fcm_token')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return response['fcm_token'] as String?;
      }
      return null;
    } catch (e) {
      print("Error fetching FCM token for user $userId: $e");
      return null;
    }
  }
}
