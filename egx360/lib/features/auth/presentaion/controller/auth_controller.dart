import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:egx/core/custom/custom_snackbar.dart';
import 'package:egx/core/constants/app_colors.dart';
import 'package:egx/core/helper/context_extensions.dart';
import 'package:egx/core/routes/app_pages.dart';
import 'package:egx/core/errors/app_exception.dart';
import 'package:egx/core/services/network_service.dart';

import 'package:egx/features/auth/domain/repository/auth_repository.dart';
import 'package:egx/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final supabase = Supabase.instance.client;

  // Deep linking
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  S get s => Get.context!.s;

  //
  //------------------ Page View & Navigation ------------------
  //
  final PageController pagecontroller = PageController(initialPage: 0);
  final currentPage = 0.obs;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  Future<void> goToRegister() async {
    pagecontroller.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await clearControllers();
  }

  Future<void> goToLogin() async {
    pagecontroller.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await clearControllers();
  }

  Future<void> goToForgotPass() async {
    currentPage.value = 0;
    await Future.delayed(const Duration(milliseconds: 100));
    pagecontroller.jumpToPage(2);
    await clearControllers();
  }

  Future<void> backfromForgotPass() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pagecontroller.jumpToPage(0);
    await clearControllers();
  }

  Future<void> goToNewPass() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pagecontroller.jumpToPage(3);
    await clearControllers();
  }

  Future<void> backToLogin() async {
    await Future.delayed(const Duration(milliseconds: 100));
    pagecontroller.jumpToPage(0);
    await clearControllers();
  }

  //
  //------------------ Form Variables ------------------
  //
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();

  // Settings Controllers
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  final isPasswordObscure = true.obs;
  final isConfirmPasswordObscure = true.obs;
  final isLoding = false.obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //
  //------------------ Email Verification Logic ------------------
  //
  final isVerified = false.obs;
  Timer? _verificationTimer;

  @override
  void onClose() {
    print("🗑️ AuthController (Hash: ${hashCode}) is being DELETED");
    _linkSubscription?.cancel();
    _verificationTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void _completeLogin() {
    isVerified.value = true;
    _verificationTimer?.cancel();

    if (GetStorage().read('loginBefore') != true) {
      print("🆕 First time login detected! Setting shouldShowWelcome = true");
      GetStorage().write('shouldShowWelcome', true);
      GetStorage().write('loginBefore', true);

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed(AppPages.layoutPage);
      });
    } else {
      print(
        "ℹ️ Not first login. loginBefore is ${GetStorage().read('loginBefore')}",
      );
    }
  }

  //
  //------------------ Auth Functions ------------------
  //

  Future<void> signUp(String name, String email, String password) async {
    try {
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      isLoding.value = true;

      await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );
      isLoding.value = false;

      customSnackbar(
        title: s.success_account_created_title,
        message: s.success_verification_sent_msg,
        color: AppColors.success,
      );

      Get.offNamed(
        AppPages.verifyEmailPage,
        arguments: {'email': email, 'password': password},
      );
    } on NetworkAppException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_no_connection_title,
        message: s.error_check_connection_msg,
        color: AppColors.error,
      );
    } on UserAlreadyExistsException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_email_already_registered_title,
        message: s.error_email_already_in_use_msg,
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_signup_title,
        message: e.message,
        color: AppColors.error,
      );
    } catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_unexpected_title,
        message: s.error_something_wrong_msg,
        color: AppColors.error,
      );
    } finally {
      isLoding.value = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      isLoding.value = true;

      await _authRepository.signIn(email: email, password: password);
      isLoding.value = false;

      customSnackbar(
        title: s.success_welcome_back_title,
        message: s.success_signed_in_msg,
        color: AppColors.success,
      );

      // Navigation is handled by onInit listener
    } on MissingDataException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_invalid_credentials_title,
        message: s.error_incorrect_email_pass_msg,
        color: AppColors.warning,
      );
    } on NetworkAppException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_no_connection_title,
        message: s.error_check_connection_msg,
        color: AppColors.error,
      );
    } on AuthAppException catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_signin_title,
        message: e.message,
        color: AppColors.error,
      );
    } catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_unexpected_title,
        message: s.error_something_wrong_msg,
        color: AppColors.error,
      );
    } finally {
      isLoding.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      print("🟢 CONTROLLER: googleSignIn() called");

      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      isLoding.value = true;

      await _authRepository.googleSignIn();

      await Duration(seconds: 1).delay();
      customSnackbar(
        title: s.success_welcome_back_title,
        message: s.success_google_signed_in_msg,
        color: AppColors.success,
      );

      // Successfully logged in, navigate now
      _completeLogin();
    } on NetworkAppException {
      customSnackbar(
        title: s.error_no_connection_title,
        message: s.error_check_connection_msg,
        color: AppColors.error,
      );
    } on GoogleSignInCancelledException {
      // customSnackbar(
      //   title: s.error_google_cancelled_title,
      //   message: s.error_google_cancelled_msg,
      //   color: AppColors.warning,
      // );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: s.error_signin_title,
        message: e.message,
        color: AppColors.warning,
      );
    } catch (e) {
      customSnackbar(
        title: s.error_unexpected_title,
        message: s.error_something_wrong_msg,
        color: AppColors.error,
      );
    } finally {
      isLoding.value = false;
    }
  }

  //
  //------------------ Password Reset & Settings ------------------
  //

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    try {
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      isLoding.value = true;

      await _authRepository.resetPassword(email);

      customSnackbar(
        title: s.success_email_sent_title,
        message: s.success_reset_link_sent_msg,
        color: AppColors.success,
      );
      backToLogin();
      emailController.clear();
    } on UserNotFoundException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_user_not_found_title,
        message: s.error_no_account_found_msg,
        color: AppColors.error,
      );
    } on NetworkAppException {
      isLoding.value = false;

      customSnackbar(
        title: s.error_no_connection_title,
        message: s.error_check_connection_msg,
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_unexpected_title,
        message: e.message,
        color: AppColors.error,
      );
    } finally {
      isLoding.value = false;
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      isLoding.value = true;
      await _authRepository.updatePassword(newPassword);
      isLoding.value = false;

      customSnackbar(
        title: s.success_password_updated_title,
        message: s.success_password_changed_msg,
        color: AppColors.success,
      );

      backToLogin();
    } on AuthAppException catch (e) {
      isLoding.value = false;

      customSnackbar(
        title: s.error_unexpected_title,
        message: e.message,
        color: AppColors.error,
      );
    } finally {
      isLoding.value = false;
    }
  }

  Future<void> changePassword() async {
    try {
      final email =
          supabase.auth.currentUser?.email ?? emailController.text.trim();

      await _authRepository.changePassword(
        email: email,
        oldPassword: oldPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      customSnackbar(
        title: s.success_password_updated_title,
        message: s.success_password_changed_msg,
        color: AppColors.success,
      );

      oldPasswordController.clear();
      newPasswordController.clear();
    } on AuthInvalidCredentialsException {
      customSnackbar(
        title: s.error_invalid_password_title,
        message: s.error_current_password_incorrect_msg,
        color: AppColors.warning,
      );
    } on NetworkAppException {
      customSnackbar(
        title: s.error_no_connection_title,
        message: s.error_check_connection_msg,
        color: AppColors.warning,
      );
    } catch (e) {
      customSnackbar(
        title: s.error_unexpected_title,
        message: s.error_failed_change_password_msg,
        color: AppColors.error,
      );
    }
  }

  Future<void> logout() async {
    try {
      if (!await NetworkService.isConnected) {
        throw const NetworkAppException('No internet connection.');
      }

      await _authRepository.logout();
      GetStorage().write('loginBefore', false);
      Get.offAllNamed(AppPages.welcomePage);

      customSnackbar(
        title: s.success_logged_out_title,
        message: s.success_logged_out_msg,
        color: AppColors.success,
      );
    } on NetworkAppException catch (e) {
      customSnackbar(
        title: s.error_no_connection_title,
        message: e.message,
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: s.error_logout_failed_title,
        message: e.message,
        color: AppColors.error,
      );
    }
  }

  Future<void> deleteAccount() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const UserNotFoundException('No user is currently logged in.');
      }

      await _authRepository.deleteAccount(userId);
      GetStorage().write('loginBefore', false);
      Get.offAllNamed(AppPages.welcomePage);

      customSnackbar(
        title: s.success_account_deleted_title,
        message: s.success_account_deleted_msg,
        color: AppColors.success,
      );
    } on NetworkAppException catch (e) {
      customSnackbar(
        title: s.error_no_connection_title,
        message: e.message,
        color: AppColors.warning,
      );
    } on AuthAppException catch (e) {
      customSnackbar(
        title: s.error_deletion_failed_title,
        message: e.message,
        color: AppColors.error,
      );
    }
  }

  //
  //------------------ Deep Link Handlers ------------------
  //

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        print('🔗 Initial Deep Link: $uri');
        _handleDeepLink(uri);
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    print('🔗 Deep Link Received: $uri');

    // Verify it's our custom scheme
    if (uri.scheme != 'io.supabase.flutter') {
      print('⚠️ Ignoring non-app deep link: ${uri.scheme}');
      return;
    }

    try {
      // Exchange the auth code for a session
      print('🔄 Exchanging auth code for session...');
      await supabase.auth.getSessionFromUrl(uri);

      // If we reach here, the session was successfully created
      print('✅ Session obtained from deep link!');
      _completeLogin();
    } catch (e) {
      print('❌ Error handling deep link: $e');
      customSnackbar(
        title: s.error_auth_title,
        message: s.error_auth_failed_msg,
        color: AppColors.error,
      );
    }
  }

  //
  //------------------ Lifecycle & Init ------------------
  //

  @override
  void onInit() {
    super.onInit();

    // Listen for deep links (incoming auth callbacks)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('❌ Deep Link Stream Error: $err');
      },
    );

    // Handle initial link (when app is opened via deep link)
    _handleInitialLink();

    supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      print("🔔 Auth Event: $event");

      // Forget Password logic
      if (event == AuthChangeEvent.passwordRecovery) {
        goToNewPass();
        return;
      }

      // إذا حدث تسجيل دخول بأي طريقة
      if ((event == AuthChangeEvent.signedIn ||
              event == AuthChangeEvent.tokenRefreshed) &&
          session != null) {
        _completeLogin();
      }
    });
  }

  Future<void> clearControllers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    nameController.clear();
    emailController.clear();
    passController.clear();
    confirmPassController.clear();
    isPasswordObscure.value = true;
    isConfirmPasswordObscure.value = true;
  }
}
