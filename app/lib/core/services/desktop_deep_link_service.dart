import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class DesktopDeepLinkService {
  static final DesktopDeepLinkService _instance = DesktopDeepLinkService._internal();
  factory DesktopDeepLinkService() => _instance;

  DesktopDeepLinkService._internal() {
    _init();
  }

  HttpServer? _server;
  final _uriController = StreamController<Uri>.broadcast();

  Stream<Uri> get uriStream => _uriController.stream;

  Future<void> _init() async {
    // Only run on desktop platforms
    if (kIsWeb || (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
      return;
    }

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 54321);
      print("🌐 DesktopDeepLinkService: Listening on http://localhost:54321/");

      _server!.listen((HttpRequest request) async {
        final uri = request.uri;

        if (uri.path == '/favicon.ico') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }

        print("✅ DesktopDeepLinkService: Received callback: $uri");

        // Broadcast the URI to listeners (e.g., AuthController or GoogleSignIn)
        // Reconstruct the full URL to ensure fragments (e.g., #access_token) are intact
        // Note: Browsers usually don't send the URL fragment (#) to the server!
        // Supabase PKCE flow uses query parameters (?code=...), which ARE sent.
        final fullUri = Uri.parse('http://localhost:54321${uri.toString()}');
        _uriController.add(fullUri);

        String msgTitle = "Authentication Successful!";
        if (uri.path.contains('reset-password')) {
           msgTitle = "Password Reset Verified!";
        }

        // Return a professional success page that closes itself
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.html
          ..write('''
            <html>
              <head><title>$msgTitle</title></head>
              <body style="font-family: sans-serif; text-align: center; padding-top: 50px; background-color: #121212; color: #fff;">
                <h1>$msgTitle</h1>
                <p>You can close this tab and return to the application.</p>
                <script>
                  setTimeout(() => {
                    window.close();
                  }, 2000);
                </script>
              </body>
            </html>
          ''');
        await request.response.close();
      });
    } catch (e) {
      print("⚠️ DesktopDeepLinkService: Error binding to port 54321 (It might be in use): $e");
    }
  }

  void dispose() {
    _server?.close(force: true);
    _uriController.close();
  }
}
