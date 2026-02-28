abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message';
}

class AuthAppException extends AppException {
  const AuthAppException(super.message, [super.code]);
}

class GoogleSignInCancelledException extends AuthAppException {
  const GoogleSignInCancelledException()
    : super('Google Sign-In cancelled by user.', 'sign_in_cancelled');
}

class DesktopOAuthInProgressException extends AuthAppException {
  const DesktopOAuthInProgressException()
    : super(
        'OAuth flow initiated. Waiting for callback...',
        'oauth_in_progress',
      );
}

class UserAlreadyExistsException extends AuthAppException {
  const UserAlreadyExistsException(String message)
    : super(message, 'user_already_exists');
}

class MissingDataException extends AuthAppException {
  const MissingDataException(String message) : super(message, 'missing_data');
}

class UserNotFoundException extends AuthAppException {
  const UserNotFoundException(String message)
    : super(message, 'invalid_credentials');
}

class NetworkAppException extends AppException {
  const NetworkAppException(super.message);
}

class UnknownAppException extends AppException {
  const UnknownAppException([String message = 'Unknown error occurred'])
    : super(message, 'unknown_error');
}

class AuthInvalidCredentialsException extends AuthAppException {
  const AuthInvalidCredentialsException(String message)
    : super(message, 'invalid_credentials');
}

class DatabaseAppException extends AppException {
  const DatabaseAppException(String message) : super(message, 'database_error');
}

class ImageUploadException extends AppException {
  const ImageUploadException(String message)
    : super(message, 'image_upload_error');
}
