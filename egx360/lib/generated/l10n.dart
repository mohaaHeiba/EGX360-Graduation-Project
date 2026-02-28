// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // skipped getter for the '//_APP_GLOBAL' key

  /// `EGX360`
  String get appTitle {
    return Intl.message('EGX360', name: 'appTitle', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Something went wrong.`
  String get unknown_error {
    return Intl.message(
      'Something went wrong.',
      name: 'unknown_error',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message('Skip', name: 'skip', desc: '', args: []);
  }

  // skipped getter for the '//_BUTTONS' key

  /// `Submit`
  String get button_submit {
    return Intl.message('Submit', name: 'button_submit', desc: '', args: []);
  }

  /// `Cancel`
  String get button_cancel {
    return Intl.message('Cancel', name: 'button_cancel', desc: '', args: []);
  }

  /// `Retry`
  String get button_retry {
    return Intl.message('Retry', name: 'button_retry', desc: '', args: []);
  }

  /// `OK`
  String get button_ok {
    return Intl.message('OK', name: 'button_ok', desc: '', args: []);
  }

  /// `Get started`
  String get get_started {
    return Intl.message('Get started', name: 'get_started', desc: '', args: []);
  }

  // skipped getter for the '//_ONBOARDING_SCREEN' key

  /// `Welcome Back!!`
  String get welcome_title {
    return Intl.message(
      'Welcome Back!!',
      name: 'welcome_title',
      desc: '',
      args: [],
    );
  }

  /// `Market data, charts and more — all in one place.`
  String get welcome_subtitle {
    return Intl.message(
      'Market data, charts and more — all in one place.',
      name: 'welcome_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `By continuing, you agree to our Terms of Service and Privacy Policy`
  String get policy_agreement {
    return Intl.message(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      name: 'policy_agreement',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_AUTH_COMMON' key

  /// `Email`
  String get email_label {
    return Intl.message('Email', name: 'email_label', desc: '', args: []);
  }

  /// `Password`
  String get password_label {
    return Intl.message('Password', name: 'password_label', desc: '', args: []);
  }

  /// `Now`
  String get now_label {
    return Intl.message(
      'Now',
      name: 'now_label',
      desc: 'Label for now/current time',
      args: [],
    );
  }

  /// `today`
  String get today {
    return Intl.message(
      'today',
      name: 'today',
      desc: 'Label for today\'s change',
      args: [],
    );
  }

  /// `USD`
  String get usd_label {
    return Intl.message('USD', name: 'usd_label', desc: '', args: []);
  }

  /// `EUR`
  String get eur_label {
    return Intl.message('EUR', name: 'eur_label', desc: '', args: []);
  }

  /// `GBP`
  String get gbp_label {
    return Intl.message('GBP', name: 'gbp_label', desc: '', args: []);
  }

  /// `Failed to load data`
  String get failed_to_load_data {
    return Intl.message(
      'Failed to load data',
      name: 'failed_to_load_data',
      desc: '',
      args: [],
    );
  }

  /// `Failed to refresh data`
  String get failed_to_refresh_data {
    return Intl.message(
      'Failed to refresh data',
      name: 'failed_to_refresh_data',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load full watchlist`
  String get failed_to_load_watchlist {
    return Intl.message(
      'Failed to load full watchlist',
      name: 'failed_to_load_watchlist',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get success_label {
    return Intl.message('Success', name: 'success_label', desc: '', args: []);
  }

  /// `Error`
  String get error_label {
    return Intl.message('Error', name: 'error_label', desc: '', args: []);
  }

  /// `Removed {symbol} from watchlist`
  String removed_from_watchlist_msg(Object symbol) {
    return Intl.message(
      'Removed $symbol from watchlist',
      name: 'removed_from_watchlist_msg',
      desc: '',
      args: [symbol],
    );
  }

  /// `Failed to remove {symbol}: {error}`
  String failed_to_remove_from_watchlist_msg(Object symbol, Object error) {
    return Intl.message(
      'Failed to remove $symbol: $error',
      name: 'failed_to_remove_from_watchlist_msg',
      desc: '',
      args: [symbol, error],
    );
  }

  /// `Gold 21k Price in EGP`
  String get gold_21k_desc {
    return Intl.message(
      'Gold 21k Price in EGP',
      name: 'gold_21k_desc',
      desc: '',
      args: [],
    );
  }

  /// `Silver 999 Price in EGP`
  String get silver_999_desc {
    return Intl.message(
      'Silver 999 Price in EGP',
      name: 'silver_999_desc',
      desc: '',
      args: [],
    );
  }

  /// `Full name`
  String get name_label {
    return Intl.message('Full name', name: 'name_label', desc: '', args: []);
  }

  /// `Phone`
  String get phone_label {
    return Intl.message('Phone', name: 'phone_label', desc: '', args: []);
  }

  /// `or continue with`
  String get continue_with {
    return Intl.message(
      'or continue with',
      name: 'continue_with',
      desc: '',
      args: [],
    );
  }

  /// `Sign in with Google`
  String get sign_google {
    return Intl.message(
      'Sign in with Google',
      name: 'sign_google',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_LOGIN_SCREEN' key

  /// `Sign in`
  String get auth_sign_in {
    return Intl.message('Sign in', name: 'auth_sign_in', desc: '', args: []);
  }

  /// `Forgot password?`
  String get forgot_password {
    return Intl.message(
      'Forgot password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Log In`
  String get register_login {
    return Intl.message('Log In', name: 'register_login', desc: '', args: []);
  }

  // skipped getter for the '//_REGISTER_SCREEN' key

  /// `Sign up`
  String get auth_sign_up {
    return Intl.message('Sign up', name: 'auth_sign_up', desc: '', args: []);
  }

  /// `Create an account`
  String get create_account {
    return Intl.message(
      'Create an account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Join us and start exploring all the amazing features we offer!`
  String get register_description {
    return Intl.message(
      'Join us and start exploring all the amazing features we offer!',
      name: 'register_description',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get register_have_account {
    return Intl.message(
      'Already have an account? ',
      name: 'register_have_account',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_FORGOT_PASSWORD_SCREEN' key

  /// `Enter your email below and we’ll send you a link to reset your password.`
  String get forgot_description {
    return Intl.message(
      'Enter your email below and we’ll send you a link to reset your password.',
      name: 'forgot_description',
      desc: '',
      args: [],
    );
  }

  /// `Send Reset Link`
  String get forgot_send_link {
    return Intl.message(
      'Send Reset Link',
      name: 'forgot_send_link',
      desc: '',
      args: [],
    );
  }

  /// `Sending...`
  String get forgot_loading {
    return Intl.message(
      'Sending...',
      name: 'forgot_loading',
      desc: '',
      args: [],
    );
  }

  /// `Remember your password? `
  String get forgot_remember {
    return Intl.message(
      'Remember your password? ',
      name: 'forgot_remember',
      desc: '',
      args: [],
    );
  }

  /// `Password reset instructions were sent if that email exists.`
  String get msg_password_reset {
    return Intl.message(
      'Password reset instructions were sent if that email exists.',
      name: 'msg_password_reset',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_VERIFICATION_SCREEN' key

  /// `Send code`
  String get send_code {
    return Intl.message('Send code', name: 'send_code', desc: '', args: []);
  }

  /// `Verify code`
  String get verify_code {
    return Intl.message('Verify code', name: 'verify_code', desc: '', args: []);
  }

  /// `A verification code was sent to your email.`
  String get msg_verification_sent {
    return Intl.message(
      'A verification code was sent to your email.',
      name: 'msg_verification_sent',
      desc: '',
      args: [],
    );
  }

  /// `We've sent a verification link to\n{email}`
  String email_verification_sent(Object email) {
    return Intl.message(
      'We\'ve sent a verification link to\n$email',
      name: 'email_verification_sent',
      desc: '',
      args: [email],
    );
  }

  /// `Please verify your email to continue...`
  String get email_verification_message {
    return Intl.message(
      'Please verify your email to continue...',
      name: 'email_verification_message',
      desc: '',
      args: [],
    );
  }

  /// `Email Verified!!`
  String get email_verified_success {
    return Intl.message(
      'Email Verified!!',
      name: 'email_verified_success',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully verified.`
  String get email_verified_message {
    return Intl.message(
      'Your account has been successfully verified.',
      name: 'email_verified_message',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_CREATE_NEW_PASSWORD' key

  /// `Create New Password`
  String get create_password_title {
    return Intl.message(
      'Create New Password',
      name: 'create_password_title',
      desc: '',
      args: [],
    );
  }

  /// `Set a strong new password to secure your account.`
  String get create_password_description {
    return Intl.message(
      'Set a strong new password to secure your account.',
      name: 'create_password_description',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get create_password_new {
    return Intl.message(
      'New Password',
      name: 'create_password_new',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get create_password_confirm_new {
    return Intl.message(
      'Confirm New Password',
      name: 'create_password_confirm_new',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get create_password_update_button {
    return Intl.message(
      'Update Password',
      name: 'create_password_update_button',
      desc: '',
      args: [],
    );
  }

  /// `Remembered your password? `
  String get create_password_remember {
    return Intl.message(
      'Remembered your password? ',
      name: 'create_password_remember',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_INPUT_PLACEHOLDERS' key

  /// `you@example.com`
  String get placeholder_email {
    return Intl.message(
      'you@example.com',
      name: 'placeholder_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter your password`
  String get placeholder_password {
    return Intl.message(
      'Enter your password',
      name: 'placeholder_password',
      desc: '',
      args: [],
    );
  }

  /// `Your full name`
  String get placeholder_name {
    return Intl.message(
      'Your full name',
      name: 'placeholder_name',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_VALIDATION_ERRORS' key

  /// `This field is required.`
  String get error_required_field {
    return Intl.message(
      'This field is required.',
      name: 'error_required_field',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get error_invalid_email {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'error_invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters.`
  String get error_password_too_short {
    return Intl.message(
      'Password must be at least 6 characters.',
      name: 'error_password_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Network error, please try again.`
  String get error_network {
    return Intl.message(
      'Network error, please try again.',
      name: 'error_network',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your name.`
  String get enterName {
    return Intl.message(
      'Please enter your name.',
      name: 'enterName',
      desc: '',
      args: [],
    );
  }

  /// `Name must be at least 3 characters.`
  String get nameMinChars {
    return Intl.message(
      'Name must be at least 3 characters.',
      name: 'nameMinChars',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email address.`
  String get enterEmail {
    return Intl.message(
      'Please enter your email address.',
      name: 'enterEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get invalidEmail {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'invalidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password.`
  String get enterPassword {
    return Intl.message(
      'Please enter your password.',
      name: 'enterPassword',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters.`
  String get passwordMinChars {
    return Intl.message(
      'Password must be at least 6 characters.',
      name: 'passwordMinChars',
      desc: '',
      args: [],
    );
  }

  /// `Password must contain an uppercase letter and a number.`
  String get passwordUpperNumber {
    return Intl.message(
      'Password must contain an uppercase letter and a number.',
      name: 'passwordUpperNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm your password.`
  String get confirmPassword {
    return Intl.message(
      'Please confirm your password.',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get passwordsNotMatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'passwordsNotMatch',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_NAVIGATION_BAR' key

  /// `Home`
  String get nav_home {
    return Intl.message('Home', name: 'nav_home', desc: '', args: []);
  }

  /// `Markets`
  String get nav_markets {
    return Intl.message('Markets', name: 'nav_markets', desc: '', args: []);
  }

  /// `Search`
  String get nav_search {
    return Intl.message('Search', name: 'nav_search', desc: '', args: []);
  }

  /// `Community`
  String get nav_community {
    return Intl.message('Community', name: 'nav_community', desc: '', args: []);
  }

  /// `Simulation`
  String get nav_simulation {
    return Intl.message(
      'Simulation',
      name: 'nav_simulation',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get nav_menu {
    return Intl.message('Menu', name: 'nav_menu', desc: '', args: []);
  }

  /// `Settings`
  String get nav_settings {
    return Intl.message('Settings', name: 'nav_settings', desc: '', args: []);
  }

  // skipped getter for the '//_MAIN_SCREENS' key

  /// `Home`
  String get home_title {
    return Intl.message('Home', name: 'home_title', desc: '', args: []);
  }

  /// `Portfolio`
  String get portfolio_title {
    return Intl.message(
      'Portfolio',
      name: 'portfolio_title',
      desc: '',
      args: [],
    );
  }

  /// `Markets`
  String get markets_title {
    return Intl.message('Markets', name: 'markets_title', desc: '', args: []);
  }

  /// `Settings`
  String get settings_title {
    return Intl.message('Settings', name: 'settings_title', desc: '', args: []);
  }

  /// `Candlestick`
  String get chart_candlestick {
    return Intl.message(
      'Candlestick',
      name: 'chart_candlestick',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get chart_line {
    return Intl.message('Line', name: 'chart_line', desc: '', args: []);
  }

  /// `Loading chart...`
  String get chart_loading {
    return Intl.message(
      'Loading chart...',
      name: 'chart_loading',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search_hint {
    return Intl.message('Search', name: 'search_hint', desc: '', args: []);
  }

  /// `No results found`
  String get no_results {
    return Intl.message(
      'No results found',
      name: 'no_results',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_SNACKBAR_MESSAGES' key

  /// `Account Created Successfully!`
  String get success_account_created_title {
    return Intl.message(
      'Account Created Successfully!',
      name: 'success_account_created_title',
      desc: '',
      args: [],
    );
  }

  /// `A verification link has been sent to your email.`
  String get success_verification_sent_msg {
    return Intl.message(
      'A verification link has been sent to your email.',
      name: 'success_verification_sent_msg',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get success_welcome_back_title {
    return Intl.message(
      'Welcome Back',
      name: 'success_welcome_back_title',
      desc: '',
      args: [],
    );
  }

  /// `You’ve signed in successfully!`
  String get success_signed_in_msg {
    return Intl.message(
      'You’ve signed in successfully!',
      name: 'success_signed_in_msg',
      desc: '',
      args: [],
    );
  }

  /// `Signed in successfully with Google.`
  String get success_google_signed_in_msg {
    return Intl.message(
      'Signed in successfully with Google.',
      name: 'success_google_signed_in_msg',
      desc: '',
      args: [],
    );
  }

  /// `Email Sent`
  String get success_email_sent_title {
    return Intl.message(
      'Email Sent',
      name: 'success_email_sent_title',
      desc: '',
      args: [],
    );
  }

  /// `A password reset link has been sent to your email.`
  String get success_reset_link_sent_msg {
    return Intl.message(
      'A password reset link has been sent to your email.',
      name: 'success_reset_link_sent_msg',
      desc: '',
      args: [],
    );
  }

  /// `Password Updated`
  String get success_password_updated_title {
    return Intl.message(
      'Password Updated',
      name: 'success_password_updated_title',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been changed successfully.`
  String get success_password_changed_msg {
    return Intl.message(
      'Your password has been changed successfully.',
      name: 'success_password_changed_msg',
      desc: '',
      args: [],
    );
  }

  /// `Logged Out`
  String get success_logged_out_title {
    return Intl.message(
      'Logged Out',
      name: 'success_logged_out_title',
      desc: '',
      args: [],
    );
  }

  /// `You have been logged out successfully.`
  String get success_logged_out_msg {
    return Intl.message(
      'You have been logged out successfully.',
      name: 'success_logged_out_msg',
      desc: '',
      args: [],
    );
  }

  /// `Account Deleted`
  String get success_account_deleted_title {
    return Intl.message(
      'Account Deleted',
      name: 'success_account_deleted_title',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been permanently removed.`
  String get success_account_deleted_msg {
    return Intl.message(
      'Your account has been permanently removed.',
      name: 'success_account_deleted_msg',
      desc: '',
      args: [],
    );
  }

  /// `No Connection`
  String get error_no_connection_title {
    return Intl.message(
      'No Connection',
      name: 'error_no_connection_title',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection.`
  String get error_check_connection_msg {
    return Intl.message(
      'Please check your internet connection.',
      name: 'error_check_connection_msg',
      desc: '',
      args: [],
    );
  }

  /// `Email Already Registered`
  String get error_email_already_registered_title {
    return Intl.message(
      'Email Already Registered',
      name: 'error_email_already_registered_title',
      desc: '',
      args: [],
    );
  }

  /// `This email is already in use.`
  String get error_email_already_in_use_msg {
    return Intl.message(
      'This email is already in use.',
      name: 'error_email_already_in_use_msg',
      desc: '',
      args: [],
    );
  }

  /// `Signup Error`
  String get error_signup_title {
    return Intl.message(
      'Signup Error',
      name: 'error_signup_title',
      desc: '',
      args: [],
    );
  }

  /// `Sign-in Error`
  String get error_signin_title {
    return Intl.message(
      'Sign-in Error',
      name: 'error_signin_title',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected Error`
  String get error_unexpected_title {
    return Intl.message(
      'Unexpected Error',
      name: 'error_unexpected_title',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong.`
  String get error_something_wrong_msg {
    return Intl.message(
      'Something went wrong.',
      name: 'error_something_wrong_msg',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Credentials`
  String get error_invalid_credentials_title {
    return Intl.message(
      'Invalid Credentials',
      name: 'error_invalid_credentials_title',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect email or password.`
  String get error_incorrect_email_pass_msg {
    return Intl.message(
      'Incorrect email or password.',
      name: 'error_incorrect_email_pass_msg',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get error_google_cancelled_title {
    return Intl.message(
      'Cancelled',
      name: 'error_google_cancelled_title',
      desc: '',
      args: [],
    );
  }

  /// `Google sign-in was cancelled by you.`
  String get error_google_cancelled_msg {
    return Intl.message(
      'Google sign-in was cancelled by you.',
      name: 'error_google_cancelled_msg',
      desc: '',
      args: [],
    );
  }

  /// `User Not Found`
  String get error_user_not_found_title {
    return Intl.message(
      'User Not Found',
      name: 'error_user_not_found_title',
      desc: '',
      args: [],
    );
  }

  /// `No account found with this email.`
  String get error_no_account_found_msg {
    return Intl.message(
      'No account found with this email.',
      name: 'error_no_account_found_msg',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get error_invalid_password_title {
    return Intl.message(
      'Invalid Password',
      name: 'error_invalid_password_title',
      desc: '',
      args: [],
    );
  }

  /// `The current password you entered is incorrect.`
  String get error_current_password_incorrect_msg {
    return Intl.message(
      'The current password you entered is incorrect.',
      name: 'error_current_password_incorrect_msg',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change password.`
  String get error_failed_change_password_msg {
    return Intl.message(
      'Failed to change password.',
      name: 'error_failed_change_password_msg',
      desc: '',
      args: [],
    );
  }

  /// `Logout Failed`
  String get error_logout_failed_title {
    return Intl.message(
      'Logout Failed',
      name: 'error_logout_failed_title',
      desc: '',
      args: [],
    );
  }

  /// `Deletion Failed`
  String get error_deletion_failed_title {
    return Intl.message(
      'Deletion Failed',
      name: 'error_deletion_failed_title',
      desc: '',
      args: [],
    );
  }

  /// `Authentication Error`
  String get error_auth_title {
    return Intl.message(
      'Authentication Error',
      name: 'error_auth_title',
      desc: '',
      args: [],
    );
  }

  /// `Failed to complete sign-in. Please try again.`
  String get error_auth_failed_msg {
    return Intl.message(
      'Failed to complete sign-in. Please try again.',
      name: 'error_auth_failed_msg',
      desc: '',
      args: [],
    );
  }

  /// `AI News Summary`
  String get ai_news_summary {
    return Intl.message(
      'AI News Summary',
      name: 'ai_news_summary',
      desc: '',
      args: [],
    );
  }

  /// `Articles Analyzed`
  String get articles_analyzed {
    return Intl.message(
      'Articles Analyzed',
      name: 'articles_analyzed',
      desc: '',
      args: [],
    );
  }

  /// `This summary was generated by AI and should be used for informational purposes only.`
  String get alert_summry {
    return Intl.message(
      'This summary was generated by AI and should be used for informational purposes only.',
      name: 'alert_summry',
      desc: '',
      args: [],
    );
  }

  /// `CURRENT VIRTUAL BALANCE`
  String get virtual_balance_title {
    return Intl.message(
      'CURRENT VIRTUAL BALANCE',
      name: 'virtual_balance_title',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully funded. You can now start practicing your trading strategies risk-free.`
  String get welcome_dialog_message {
    return Intl.message(
      'Your account has been successfully funded. You can now start practicing your trading strategies risk-free.',
      name: 'welcome_dialog_message',
      desc: '',
      args: [],
    );
  }

  /// `START TRADING`
  String get start_trading_btn {
    return Intl.message(
      'START TRADING',
      name: 'start_trading_btn',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_SETTINGS_SCREENS' key

  /// `Settings`
  String get menu_settings {
    return Intl.message('Settings', name: 'menu_settings', desc: '', args: []);
  }

  /// `Posts`
  String get profile_posts {
    return Intl.message('Posts', name: 'profile_posts', desc: '', args: []);
  }

  /// `Followers`
  String get profile_followers {
    return Intl.message(
      'Followers',
      name: 'profile_followers',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get profile_following {
    return Intl.message(
      'Following',
      name: 'profile_following',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_SIMULATION_PORTFOLIO' key

  /// `Simulation Portfolio`
  String get simulation_portfolio {
    return Intl.message(
      'Simulation Portfolio',
      name: 'simulation_portfolio',
      desc: '',
      args: [],
    );
  }

  /// `Total P&L`
  String get simulation_total_pl {
    return Intl.message(
      'Total P&L',
      name: 'simulation_total_pl',
      desc: '',
      args: [],
    );
  }

  /// `Positions`
  String get simulation_positions {
    return Intl.message(
      'Positions',
      name: 'simulation_positions',
      desc: '',
      args: [],
    );
  }

  /// `Available Cash`
  String get simulation_available_cash {
    return Intl.message(
      'Available Cash',
      name: 'simulation_available_cash',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_APP_SETTINGS' key

  /// `ACCOUNT`
  String get account_section {
    return Intl.message('ACCOUNT', name: 'account_section', desc: '', args: []);
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Change your name, avatar, bio`
  String get edit_profile_subtitle {
    return Intl.message(
      'Change your name, avatar, bio',
      name: 'edit_profile_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Privacy & Security`
  String get privacy_security {
    return Intl.message(
      'Privacy & Security',
      name: 'privacy_security',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `PREFERENCES`
  String get preferences_section {
    return Intl.message(
      'PREFERENCES',
      name: 'preferences_section',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get dark_mode {
    return Intl.message('Dark Mode', name: 'dark_mode', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `English`
  String get language_english {
    return Intl.message(
      'English',
      name: 'language_english',
      desc: '',
      args: [],
    );
  }

  /// `ABOUT`
  String get about_section {
    return Intl.message('ABOUT', name: 'about_section', desc: '', args: []);
  }

  /// `About EGX`
  String get about_egx {
    return Intl.message('About EGX', name: 'about_egx', desc: '', args: []);
  }

  /// `Version 1.0.0`
  String get about_version {
    return Intl.message(
      'Version 1.0.0',
      name: 'about_version',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Help & Support`
  String get help_support {
    return Intl.message(
      'Help & Support',
      name: 'help_support',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Confirm Logout`
  String get confirm_logout {
    return Intl.message(
      'Confirm Logout',
      name: 'confirm_logout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to logout?`
  String get confirm_logout_message {
    return Intl.message(
      'Are you sure you want to logout?',
      name: 'confirm_logout_message',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_EDIT_PROFILE' key

  /// `Full Name`
  String get full_name {
    return Intl.message('Full Name', name: 'full_name', desc: '', args: []);
  }

  /// `Enter your full name`
  String get full_name_hint {
    return Intl.message(
      'Enter your full name',
      name: 'full_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Bio`
  String get bio {
    return Intl.message('Bio', name: 'bio', desc: '', args: []);
  }

  /// `Tell us a bit about yourself...`
  String get bio_hint {
    return Intl.message(
      'Tell us a bit about yourself...',
      name: 'bio_hint',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get email_address {
    return Intl.message(
      'Email Address',
      name: 'email_address',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_THEME_PAGE' key

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Choose your preferred theme`
  String get choose_theme {
    return Intl.message(
      'Choose your preferred theme',
      name: 'choose_theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Use System Theme`
  String get use_system_theme {
    return Intl.message(
      'Use System Theme',
      name: 'use_system_theme',
      desc: '',
      args: [],
    );
  }

  /// `Theme will change depending on phone settings`
  String get system_theme_description {
    return Intl.message(
      'Theme will change depending on phone settings',
      name: 'system_theme_description',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_LANGUAGE_PAGE' key

  /// `Select your preferred language`
  String get select_language {
    return Intl.message(
      'Select your preferred language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `العربية`
  String get arabic {
    return Intl.message('العربية', name: 'arabic', desc: '', args: []);
  }

  /// `Set app language to English`
  String get language_english_subtitle {
    return Intl.message(
      'Set app language to English',
      name: 'language_english_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `اضبط لغة التطبيق إلى العربية`
  String get language_arabic_subtitle {
    return Intl.message(
      'اضبط لغة التطبيق إلى العربية',
      name: 'language_arabic_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Apply Language`
  String get apply_language {
    return Intl.message(
      'Apply Language',
      name: 'apply_language',
      desc: '',
      args: [],
    );
  }

  /// `Language Changed`
  String get language_changed {
    return Intl.message(
      'Language Changed',
      name: 'language_changed',
      desc: '',
      args: [],
    );
  }

  /// `تم تغيير اللغة إلى العربية`
  String get language_changed_to_arabic {
    return Intl.message(
      'تم تغيير اللغة إلى العربية',
      name: 'language_changed_to_arabic',
      desc: '',
      args: [],
    );
  }

  /// `App language set to English`
  String get language_changed_to_english {
    return Intl.message(
      'App language set to English',
      name: 'language_changed_to_english',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_NOTIFICATIONS_PAGE' key

  /// `GENERAL`
  String get general_section {
    return Intl.message('GENERAL', name: 'general_section', desc: '', args: []);
  }

  /// `Allow Notifications`
  String get allow_notifications {
    return Intl.message(
      'Allow Notifications',
      name: 'allow_notifications',
      desc: '',
      args: [],
    );
  }

  /// `System notifications are ON`
  String get system_notifications_on {
    return Intl.message(
      'System notifications are ON',
      name: 'system_notifications_on',
      desc: '',
      args: [],
    );
  }

  /// `Tap to enable in settings`
  String get tap_to_enable {
    return Intl.message(
      'Tap to enable in settings',
      name: 'tap_to_enable',
      desc: '',
      args: [],
    );
  }

  /// `CATEGORIES`
  String get categories_section {
    return Intl.message(
      'CATEGORIES',
      name: 'categories_section',
      desc: '',
      args: [],
    );
  }

  /// `Market Alerts`
  String get market_alerts {
    return Intl.message(
      'Market Alerts',
      name: 'market_alerts',
      desc: '',
      args: [],
    );
  }

  /// `Price movements, volume spikes`
  String get market_alerts_subtitle {
    return Intl.message(
      'Price movements, volume spikes',
      name: 'market_alerts_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `News Updates`
  String get news_updates {
    return Intl.message(
      'News Updates',
      name: 'news_updates',
      desc: '',
      args: [],
    );
  }

  /// `Financial and market news`
  String get news_updates_subtitle {
    return Intl.message(
      'Financial and market news',
      name: 'news_updates_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `App Updates`
  String get app_updates {
    return Intl.message('App Updates', name: 'app_updates', desc: '', args: []);
  }

  /// `New features and versions`
  String get app_updates_subtitle {
    return Intl.message(
      'New features and versions',
      name: 'app_updates_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `SOUNDS & ALERTS`
  String get sounds_alerts_section {
    return Intl.message(
      'SOUNDS & ALERTS',
      name: 'sounds_alerts_section',
      desc: '',
      args: [],
    );
  }

  /// `Notification Sounds`
  String get notification_sounds {
    return Intl.message(
      'Notification Sounds',
      name: 'notification_sounds',
      desc: '',
      args: [],
    );
  }

  /// `Play sound for new alerts`
  String get notification_sounds_subtitle {
    return Intl.message(
      'Play sound for new alerts',
      name: 'notification_sounds_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Mute All App Alerts`
  String get mute_all_alerts {
    return Intl.message(
      'Mute All App Alerts',
      name: 'mute_all_alerts',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_SECURITY_PAGE' key

  /// `SECURITY`
  String get security_section {
    return Intl.message(
      'SECURITY',
      name: 'security_section',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Update your account password`
  String get change_password_subtitle {
    return Intl.message(
      'Update your account password',
      name: 'change_password_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Active Sessions`
  String get active_sessions {
    return Intl.message(
      'Active Sessions',
      name: 'active_sessions',
      desc: '',
      args: [],
    );
  }

  /// `View where your account is currently logged in`
  String get active_sessions_subtitle {
    return Intl.message(
      'View where your account is currently logged in',
      name: 'active_sessions_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `ACCOUNT ACTIONS`
  String get account_actions_section {
    return Intl.message(
      'ACCOUNT ACTIONS',
      name: 'account_actions_section',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get delete_account {
    return Intl.message(
      'Delete Account',
      name: 'delete_account',
      desc: '',
      args: [],
    );
  }

  /// `Permanently remove your data and account`
  String get delete_account_subtitle {
    return Intl.message(
      'Permanently remove your data and account',
      name: 'delete_account_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to permanently delete your account? This action cannot be undone.`
  String get delete_account_confirm {
    return Intl.message(
      'Are you sure you want to permanently delete your account? This action cannot be undone.',
      name: 'delete_account_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  // skipped getter for the '//_ABOUT_EGX_PAGE' key

  /// `About EGX360`
  String get about_egx360 {
    return Intl.message(
      'About EGX360',
      name: 'about_egx360',
      desc: '',
      args: [],
    );
  }

  /// `EGX360 is a modern stock market simulator app for the Egyptian Exchange, helping users learn, practice, and explore trading safely with virtual funds.`
  String get about_egx360_description {
    return Intl.message(
      'EGX360 is a modern stock market simulator app for the Egyptian Exchange, helping users learn, practice, and explore trading safely with virtual funds.',
      name: 'about_egx360_description',
      desc: '',
      args: [],
    );
  }

  /// `About the Developer`
  String get about_developer {
    return Intl.message(
      'About the Developer',
      name: 'about_developer',
      desc: '',
      args: [],
    );
  }

  /// `Developed by Mohamed Heiba — Software Engineering student specializing in Flutter and AI integrations.`
  String get about_developer_description {
    return Intl.message(
      'Developed by Mohamed Heiba — Software Engineering student specializing in Flutter and AI integrations.',
      name: 'about_developer_description',
      desc: '',
      args: [],
    );
  }

  /// `APP DETAILS`
  String get app_details_section {
    return Intl.message(
      'APP DETAILS',
      name: 'app_details_section',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get app_version {
    return Intl.message('App Version', name: 'app_version', desc: '', args: []);
  }

  /// `1.0.0 (Beta)`
  String get app_version_number {
    return Intl.message(
      '1.0.0 (Beta)',
      name: 'app_version_number',
      desc: '',
      args: [],
    );
  }

  /// `Licenses`
  String get licenses {
    return Intl.message('Licenses', name: 'licenses', desc: '', args: []);
  }

  // skipped getter for the '//_PRIVACY_POLICY_PAGE' key

  /// `Privacy Policy`
  String get privacy_policy_title {
    return Intl.message(
      'Privacy Policy',
      name: 'privacy_policy_title',
      desc: '',
      args: [],
    );
  }

  /// `Last Updated: October 26, 2025`
  String get last_updated {
    return Intl.message(
      'Last Updated: October 26, 2025',
      name: 'last_updated',
      desc: '',
      args: [],
    );
  }

  /// `At EGX App, we value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and protect your data when you use our services.`
  String get privacy_intro {
    return Intl.message(
      'At EGX App, we value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and protect your data when you use our services.',
      name: 'privacy_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. Information We Collect`
  String get privacy_section_1_title {
    return Intl.message(
      '1. Information We Collect',
      name: 'privacy_section_1_title',
      desc: '',
      args: [],
    );
  }

  /// `We may collect information such as your name, email address, portfolio preferences, and usage activity within the app to enhance your experience.`
  String get privacy_section_1_content {
    return Intl.message(
      'We may collect information such as your name, email address, portfolio preferences, and usage activity within the app to enhance your experience.',
      name: 'privacy_section_1_content',
      desc: '',
      args: [],
    );
  }

  /// `2. How We Use Your Information`
  String get privacy_section_2_title {
    return Intl.message(
      '2. How We Use Your Information',
      name: 'privacy_section_2_title',
      desc: '',
      args: [],
    );
  }

  /// `Your data helps us provide personalized content, improve app performance, and ensure security of your account.`
  String get privacy_section_2_content {
    return Intl.message(
      'Your data helps us provide personalized content, improve app performance, and ensure security of your account.',
      name: 'privacy_section_2_content',
      desc: '',
      args: [],
    );
  }

  /// `3. Data Protection`
  String get privacy_section_3_title {
    return Intl.message(
      '3. Data Protection',
      name: 'privacy_section_3_title',
      desc: '',
      args: [],
    );
  }

  /// `We use secure encryption and authentication methods to protect your data. Your information is not shared with third parties without your consent.`
  String get privacy_section_3_content {
    return Intl.message(
      'We use secure encryption and authentication methods to protect your data. Your information is not shared with third parties without your consent.',
      name: 'privacy_section_3_content',
      desc: '',
      args: [],
    );
  }

  /// `4. Third-Party Services`
  String get privacy_section_4_title {
    return Intl.message(
      '4. Third-Party Services',
      name: 'privacy_section_4_title',
      desc: '',
      args: [],
    );
  }

  /// `We may integrate with trusted services like Firebase or analytics tools for performance tracking and crash reporting.`
  String get privacy_section_4_content {
    return Intl.message(
      'We may integrate with trusted services like Firebase or analytics tools for performance tracking and crash reporting.',
      name: 'privacy_section_4_content',
      desc: '',
      args: [],
    );
  }

  /// `5. Your Rights`
  String get privacy_section_5_title {
    return Intl.message(
      '5. Your Rights',
      name: 'privacy_section_5_title',
      desc: '',
      args: [],
    );
  }

  /// `You have the right to access, modify, or delete your data. You can request this via the app settings or contact support.`
  String get privacy_section_5_content {
    return Intl.message(
      'You have the right to access, modify, or delete your data. You can request this via the app settings or contact support.',
      name: 'privacy_section_5_content',
      desc: '',
      args: [],
    );
  }

  /// `6. Updates to This Policy`
  String get privacy_section_6_title {
    return Intl.message(
      '6. Updates to This Policy',
      name: 'privacy_section_6_title',
      desc: '',
      args: [],
    );
  }

  /// `We may update this Privacy Policy from time to time. All changes will be reflected here with a new 'Last Updated' date.`
  String get privacy_section_6_content {
    return Intl.message(
      'We may update this Privacy Policy from time to time. All changes will be reflected here with a new \'Last Updated\' date.',
      name: 'privacy_section_6_content',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 EGX App. All rights reserved.`
  String get copyright {
    return Intl.message(
      '© 2025 EGX App. All rights reserved.',
      name: 'copyright',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_HELP_SUPPORT_PAGE' key

  /// `Need Help?`
  String get need_help {
    return Intl.message('Need Help?', name: 'need_help', desc: '', args: []);
  }

  /// `Find quick answers or reach out for support.`
  String get need_help_subtitle {
    return Intl.message(
      'Find quick answers or reach out for support.',
      name: 'need_help_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `FAQs`
  String get faqs_section {
    return Intl.message('FAQs', name: 'faqs_section', desc: '', args: []);
  }

  /// `How to use EGX360?`
  String get how_to_use_egx360 {
    return Intl.message(
      'How to use EGX360?',
      name: 'how_to_use_egx360',
      desc: '',
      args: [],
    );
  }

  /// `Learn how to explore markets and access real-time data.`
  String get how_to_use_subtitle {
    return Intl.message(
      'Learn how to explore markets and access real-time data.',
      name: 'how_to_use_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Data Sources`
  String get data_sources {
    return Intl.message(
      'Data Sources',
      name: 'data_sources',
      desc: '',
      args: [],
    );
  }

  /// `Understand where EGX360 gets its market data from.`
  String get data_sources_subtitle {
    return Intl.message(
      'Understand where EGX360 gets its market data from.',
      name: 'data_sources_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `SUPPORT`
  String get support_section {
    return Intl.message('SUPPORT', name: 'support_section', desc: '', args: []);
  }

  /// `Contact & Report Issue`
  String get contact_report {
    return Intl.message(
      'Contact & Report Issue',
      name: 'contact_report',
      desc: '',
      args: [],
    );
  }

  /// `Send us an email if you need help or found a problem.`
  String get contact_report_subtitle {
    return Intl.message(
      'Send us an email if you need help or found a problem.',
      name: 'contact_report_subtitle',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_DATA_SOURCES_PAGE' key

  /// `Data Sources`
  String get data_sources_page_title {
    return Intl.message(
      'Data Sources',
      name: 'data_sources_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Understand where EGX360 gets its market data.`
  String get data_sources_description {
    return Intl.message(
      'Understand where EGX360 gets its market data.',
      name: 'data_sources_description',
      desc: '',
      args: [],
    );
  }

  /// `EGX360 aggregates data from reliable and trusted sources to provide accurate market insights.`
  String get data_sources_intro {
    return Intl.message(
      'EGX360 aggregates data from reliable and trusted sources to provide accurate market insights.',
      name: 'data_sources_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. TradingView (TDV)`
  String get data_source_1_title {
    return Intl.message(
      '1. TradingView (TDV)',
      name: 'data_source_1_title',
      desc: '',
      args: [],
    );
  }

  /// `We fetch real-time stock quotes, indices, and trading volumes from TradingView via TDV and store them securely in our cloud for fast access.`
  String get data_source_1_content {
    return Intl.message(
      'We fetch real-time stock quotes, indices, and trading volumes from TradingView via TDV and store them securely in our cloud for fast access.',
      name: 'data_source_1_content',
      desc: '',
      args: [],
    );
  }

  /// `2. Gold Local Prices`
  String get data_source_2_title {
    return Intl.message(
      '2. Gold Local Prices',
      name: 'data_source_2_title',
      desc: '',
      args: [],
    );
  }

  /// `We scrape local gold prices from trusted sources to provide accurate and up-to-date pricing for investors.`
  String get data_source_2_content {
    return Intl.message(
      'We scrape local gold prices from trusted sources to provide accurate and up-to-date pricing for investors.',
      name: 'data_source_2_content',
      desc: '',
      args: [],
    );
  }

  /// `3. Historical Market Data`
  String get data_source_3_title {
    return Intl.message(
      '3. Historical Market Data',
      name: 'data_source_3_title',
      desc: '',
      args: [],
    );
  }

  /// `Access past stock and index data for analysis, charting, and backtesting.`
  String get data_source_3_content {
    return Intl.message(
      'Access past stock and index data for analysis, charting, and backtesting.',
      name: 'data_source_3_content',
      desc: '',
      args: [],
    );
  }

  /// `4. Financial News`
  String get data_source_4_title {
    return Intl.message(
      '4. Financial News',
      name: 'data_source_4_title',
      desc: '',
      args: [],
    );
  }

  /// `Aggregated news from verified financial and economic outlets to keep you updated with market events.`
  String get data_source_4_content {
    return Intl.message(
      'Aggregated news from verified financial and economic outlets to keep you updated with market events.',
      name: 'data_source_4_content',
      desc: '',
      args: [],
    );
  }

  /// `5. Third-Party APIs`
  String get data_source_5_title {
    return Intl.message(
      '5. Third-Party APIs',
      name: 'data_source_5_title',
      desc: '',
      args: [],
    );
  }

  /// `Integrations with trusted APIs provide analytics, charts, and additional market information.`
  String get data_source_5_content {
    return Intl.message(
      'Integrations with trusted APIs provide analytics, charts, and additional market information.',
      name: 'data_source_5_content',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_HOW_TO_USE_PAGE' key

  /// `How to use EGX360`
  String get how_to_use_page_title {
    return Intl.message(
      'How to use EGX360',
      name: 'how_to_use_page_title',
      desc: '',
      args: [],
    );
  }

  /// `Learn how to explore EGX360 features effectively.`
  String get how_to_use_description {
    return Intl.message(
      'Learn how to explore EGX360 features effectively.',
      name: 'how_to_use_description',
      desc: '',
      args: [],
    );
  }

  /// `EGX360 is designed to give you real-time market data and analytics. Follow these steps to maximize your experience:`
  String get how_to_use_intro {
    return Intl.message(
      'EGX360 is designed to give you real-time market data and analytics. Follow these steps to maximize your experience:',
      name: 'how_to_use_intro',
      desc: '',
      args: [],
    );
  }

  /// `1. Explore Markets`
  String get how_to_step_1_title {
    return Intl.message(
      '1. Explore Markets',
      name: 'how_to_step_1_title',
      desc: '',
      args: [],
    );
  }

  /// `Navigate through indices, sectors, and stocks using the bottom menu and search bar.`
  String get how_to_step_1_content {
    return Intl.message(
      'Navigate through indices, sectors, and stocks using the bottom menu and search bar.',
      name: 'how_to_step_1_content',
      desc: '',
      args: [],
    );
  }

  /// `2. Real-Time Data`
  String get how_to_step_2_title {
    return Intl.message(
      '2. Real-Time Data',
      name: 'how_to_step_2_title',
      desc: '',
      args: [],
    );
  }

  /// `Access live market prices, volume, and historical trends for informed decision-making.`
  String get how_to_step_2_content {
    return Intl.message(
      'Access live market prices, volume, and historical trends for informed decision-making.',
      name: 'how_to_step_2_content',
      desc: '',
      args: [],
    );
  }

  /// `3. Portfolio Management`
  String get how_to_step_3_title {
    return Intl.message(
      '3. Portfolio Management',
      name: 'how_to_step_3_title',
      desc: '',
      args: [],
    );
  }

  /// `Track your investments, create watchlists, and get alerts on price movements.`
  String get how_to_step_3_content {
    return Intl.message(
      'Track your investments, create watchlists, and get alerts on price movements.',
      name: 'how_to_step_3_content',
      desc: '',
      args: [],
    );
  }

  /// `4. Analysis Tools`
  String get how_to_step_4_title {
    return Intl.message(
      '4. Analysis Tools',
      name: 'how_to_step_4_title',
      desc: '',
      args: [],
    );
  }

  /// `Use charts, indicators, and AI insights to analyze market patterns.`
  String get how_to_step_4_content {
    return Intl.message(
      'Use charts, indicators, and AI insights to analyze market patterns.',
      name: 'how_to_step_4_content',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_ACTIVE_SESSIONS_PAGE' key

  /// `Your account is currently active on this device only.`
  String get active_sessions_description {
    return Intl.message(
      'Your account is currently active on this device only.',
      name: 'active_sessions_description',
      desc: '',
      args: [],
    );
  }

  /// `CURRENT SESSION`
  String get current_session_section {
    return Intl.message(
      'CURRENT SESSION',
      name: 'current_session_section',
      desc: '',
      args: [],
    );
  }

  /// `This Device`
  String get this_device {
    return Intl.message('This Device', name: 'this_device', desc: '', args: []);
  }

  /// `Cairo, Egypt`
  String get location_egypt {
    return Intl.message(
      'Cairo, Egypt',
      name: 'location_egypt',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get last_active_now {
    return Intl.message(
      'Just now',
      name: 'last_active_now',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get session_active {
    return Intl.message('Active', name: 'session_active', desc: '', args: []);
  }

  // skipped getter for the '//_CHANGE_PASSWORD_PAGE' key

  /// `Change Password`
  String get change_password_title {
    return Intl.message(
      'Change Password',
      name: 'change_password_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get current_password {
    return Intl.message(
      'Current Password',
      name: 'current_password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get update_password {
    return Intl.message(
      'Update Password',
      name: 'update_password',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get snackbar_success {
    return Intl.message(
      'Success',
      name: 'snackbar_success',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get snackbar_error {
    return Intl.message('Error', name: 'snackbar_error', desc: '', args: []);
  }

  /// `Warning`
  String get snackbar_warning {
    return Intl.message(
      'Warning',
      name: 'snackbar_warning',
      desc: '',
      args: [],
    );
  }

  /// `No Connection`
  String get snackbar_no_connection {
    return Intl.message(
      'No Connection',
      name: 'snackbar_no_connection',
      desc: '',
      args: [],
    );
  }

  /// `Unexpected Error`
  String get snackbar_unexpected_error {
    return Intl.message(
      'Unexpected Error',
      name: 'snackbar_unexpected_error',
      desc: '',
      args: [],
    );
  }

  /// `Your profile has been updated successfully!`
  String get profile_updated_success {
    return Intl.message(
      'Your profile has been updated successfully!',
      name: 'profile_updated_success',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet connection.`
  String get check_internet_connection {
    return Intl.message(
      'Please check your internet connection.',
      name: 'check_internet_connection',
      desc: '',
      args: [],
    );
  }

  /// `Something went wrong.`
  String get something_went_wrong {
    return Intl.message(
      'Something went wrong.',
      name: 'something_went_wrong',
      desc: '',
      args: [],
    );
  }

  /// `Profile picture updated successfully!`
  String get profile_picture_updated {
    return Intl.message(
      'Profile picture updated successfully!',
      name: 'profile_picture_updated',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update image.`
  String get failed_to_update_image {
    return Intl.message(
      'Failed to update image.',
      name: 'failed_to_update_image',
      desc: '',
      args: [],
    );
  }

  /// `Password Updated`
  String get password_updated {
    return Intl.message(
      'Password Updated',
      name: 'password_updated',
      desc: '',
      args: [],
    );
  }

  /// `Your password has been changed successfully.`
  String get password_changed_success {
    return Intl.message(
      'Your password has been changed successfully.',
      name: 'password_changed_success',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get invalid_password {
    return Intl.message(
      'Invalid Password',
      name: 'invalid_password',
      desc: '',
      args: [],
    );
  }

  /// `The current password you entered is incorrect.`
  String get incorrect_current_password {
    return Intl.message(
      'The current password you entered is incorrect.',
      name: 'incorrect_current_password',
      desc: '',
      args: [],
    );
  }

  /// `Failed to change password.`
  String get failed_to_change_password {
    return Intl.message(
      'Failed to change password.',
      name: 'failed_to_change_password',
      desc: '',
      args: [],
    );
  }

  /// `Logged Out`
  String get logged_out {
    return Intl.message('Logged Out', name: 'logged_out', desc: '', args: []);
  }

  /// `You have been logged out successfully.`
  String get logged_out_success {
    return Intl.message(
      'You have been logged out successfully.',
      name: 'logged_out_success',
      desc: '',
      args: [],
    );
  }

  /// `Logout failed.`
  String get logout_failed {
    return Intl.message(
      'Logout failed.',
      name: 'logout_failed',
      desc: '',
      args: [],
    );
  }

  /// `Account Deleted`
  String get account_deleted {
    return Intl.message(
      'Account Deleted',
      name: 'account_deleted',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been permanently removed.`
  String get account_deleted_message {
    return Intl.message(
      'Your account has been permanently removed.',
      name: 'account_deleted_message',
      desc: '',
      args: [],
    );
  }

  /// `Account deletion failed.`
  String get account_deletion_failed {
    return Intl.message(
      'Account deletion failed.',
      name: 'account_deletion_failed',
      desc: '',
      args: [],
    );
  }

  /// `Unable to open email app.`
  String get unable_to_open_email {
    return Intl.message(
      'Unable to open email app.',
      name: 'unable_to_open_email',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_LANGUAGE_NAMES' key

  /// `Arabic`
  String get language_name_arabic {
    return Intl.message(
      'Arabic',
      name: 'language_name_arabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get language_name_english {
    return Intl.message(
      'English',
      name: 'language_name_english',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_NOTIFICATIONS_CONTROLLER' key

  /// `System Settings`
  String get system_settings {
    return Intl.message(
      'System Settings',
      name: 'system_settings',
      desc: '',
      args: [],
    );
  }

  /// `Please disable notifications from system settings.`
  String get disable_notifications_message {
    return Intl.message(
      'Please disable notifications from system settings.',
      name: 'disable_notifications_message',
      desc: '',
      args: [],
    );
  }

  /// `Muted`
  String get muted {
    return Intl.message('Muted', name: 'muted', desc: '', args: []);
  }

  /// `All in-app alerts muted`
  String get all_alerts_muted {
    return Intl.message(
      'All in-app alerts muted',
      name: 'all_alerts_muted',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_PORTFOLIO_AND_LICENSES' key

  /// `My Portfolio`
  String get my_portfolio {
    return Intl.message(
      'My Portfolio',
      name: 'my_portfolio',
      desc: '',
      args: [],
    );
  }

  /// `Open Source Licenses`
  String get open_source_licenses {
    return Intl.message(
      'Open Source Licenses',
      name: 'open_source_licenses',
      desc: '',
      args: [],
    );
  }

  /// `Error loading licenses`
  String get error_loading_licenses {
    return Intl.message(
      'Error loading licenses',
      name: 'error_loading_licenses',
      desc: '',
      args: [],
    );
  }

  /// `EGX360`
  String get egx360_app_name {
    return Intl.message('EGX360', name: 'egx360_app_name', desc: '', args: []);
  }

  /// `Version 1.0.0`
  String get version_number {
    return Intl.message(
      'Version 1.0.0',
      name: 'version_number',
      desc: '',
      args: [],
    );
  }

  /// `© 2025 EGX360. All rights reserved.\nBuilt with Flutter & Firebase.`
  String get copyright_notice {
    return Intl.message(
      '© 2025 EGX360. All rights reserved.\nBuilt with Flutter & Firebase.',
      name: 'copyright_notice',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the '//_HOME_FEATURE' key

  /// `Hello, {name}`
  String home_greeting(Object name) {
    return Intl.message(
      'Hello, $name',
      name: 'home_greeting',
      desc: '',
      args: [name],
    );
  }

  /// `Trending Stocks`
  String get trending_stocks_title {
    return Intl.message(
      'Trending Stocks',
      name: 'trending_stocks_title',
      desc: '',
      args: [],
    );
  }

  /// `Market Status`
  String get market_status_title {
    return Intl.message(
      'Market Status',
      name: 'market_status_title',
      desc: '',
      args: [],
    );
  }

  /// `LIVE`
  String get market_live {
    return Intl.message('LIVE', name: 'market_live', desc: '', args: []);
  }

  /// `CLOSED`
  String get market_closed {
    return Intl.message('CLOSED', name: 'market_closed', desc: '', args: []);
  }

  /// `Value Traded`
  String get value_traded_label {
    return Intl.message(
      'Value Traded',
      name: 'value_traded_label',
      desc: '',
      args: [],
    );
  }

  /// `Market Cap`
  String get market_cap_label {
    return Intl.message(
      'Market Cap',
      name: 'market_cap_label',
      desc: '',
      args: [],
    );
  }

  /// `N/A`
  String get not_available {
    return Intl.message('N/A', name: 'not_available', desc: '', args: []);
  }

  /// `Market Indices`
  String get market_indices_title {
    return Intl.message(
      'Market Indices',
      name: 'market_indices_title',
      desc: '',
      args: [],
    );
  }

  /// `Gold 21k`
  String get gold_21k_title {
    return Intl.message('Gold 21k', name: 'gold_21k_title', desc: '', args: []);
  }

  /// `Silver 999`
  String get silver_999_title {
    return Intl.message(
      'Silver 999',
      name: 'silver_999_title',
      desc: '',
      args: [],
    );
  }

  /// `Currency`
  String get currency_sector {
    return Intl.message(
      'Currency',
      name: 'currency_sector',
      desc: '',
      args: [],
    );
  }

  /// `Exchange rate between {name} and Egyptian Pound`
  String currency_desc(Object name) {
    return Intl.message(
      'Exchange rate between $name and Egyptian Pound',
      name: 'currency_desc',
      desc: '',
      args: [name],
    );
  }

  /// `Your Watchlist`
  String get your_watchlist_title {
    return Intl.message(
      'Your Watchlist',
      name: 'your_watchlist_title',
      desc: '',
      args: [],
    );
  }

  /// `See All`
  String get see_all_btn {
    return Intl.message('See All', name: 'see_all_btn', desc: '', args: []);
  }

  /// `Delete`
  String get delete_action {
    return Intl.message('Delete', name: 'delete_action', desc: '', args: []);
  }

  /// `Latest News`
  String get latest_news_title {
    return Intl.message(
      'Latest News',
      name: 'latest_news_title',
      desc: '',
      args: [],
    );
  }

  /// `No news available`
  String get no_news_available {
    return Intl.message(
      'No news available',
      name: 'no_news_available',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications_title {
    return Intl.message(
      'Notifications',
      name: 'notifications_title',
      desc: '',
      args: [],
    );
  }

  /// `Mark all read`
  String get mark_all_read_btn {
    return Intl.message(
      'Mark all read',
      name: 'mark_all_read_btn',
      desc: '',
      args: [],
    );
  }

  /// `No notifications yet`
  String get no_notifications_msg {
    return Intl.message(
      'No notifications yet',
      name: 'no_notifications_msg',
      desc: '',
      args: [],
    );
  }

  /// `View all notifications`
  String get view_all_notifications_btn {
    return Intl.message(
      'View all notifications',
      name: 'view_all_notifications_btn',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry_btn {
    return Intl.message('Retry', name: 'retry_btn', desc: '', args: []);
  }

  /// `Market`
  String get market_label {
    return Intl.message('Market', name: 'market_label', desc: '', args: []);
  }

  /// `Notification`
  String get notification_fallback_title {
    return Intl.message(
      'Notification',
      name: 'notification_fallback_title',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load notifications`
  String get failed_to_load_notifications {
    return Intl.message(
      'Failed to load notifications',
      name: 'failed_to_load_notifications',
      desc: '',
      args: [],
    );
  }

  /// `All notifications marked as read`
  String get success_mark_all_read {
    return Intl.message(
      'All notifications marked as read',
      name: 'success_mark_all_read',
      desc: '',
      args: [],
    );
  }

  /// `Failed to mark all as read`
  String get failed_mark_all_read {
    return Intl.message(
      'Failed to mark all as read',
      name: 'failed_mark_all_read',
      desc: '',
      args: [],
    );
  }

  /// `Chart Type`
  String get chart_type_menu_title {
    return Intl.message(
      'Chart Type',
      name: 'chart_type_menu_title',
      desc: '',
      args: [],
    );
  }

  /// `Candles`
  String get chart_type_candles {
    return Intl.message(
      'Candles',
      name: 'chart_type_candles',
      desc: '',
      args: [],
    );
  }

  /// `Traditional candlestick chart`
  String get chart_type_candles_desc {
    return Intl.message(
      'Traditional candlestick chart',
      name: 'chart_type_candles_desc',
      desc: '',
      args: [],
    );
  }

  /// `Bars`
  String get chart_type_bars {
    return Intl.message('Bars', name: 'chart_type_bars', desc: '', args: []);
  }

  /// `OHLC bar chart`
  String get chart_type_bars_desc {
    return Intl.message(
      'OHLC bar chart',
      name: 'chart_type_bars_desc',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get chart_type_line {
    return Intl.message('Line', name: 'chart_type_line', desc: '', args: []);
  }

  /// `Simple line chart`
  String get chart_type_line_desc {
    return Intl.message(
      'Simple line chart',
      name: 'chart_type_line_desc',
      desc: '',
      args: [],
    );
  }

  /// `Heikin Ashi`
  String get chart_type_heikin_ashi {
    return Intl.message(
      'Heikin Ashi',
      name: 'chart_type_heikin_ashi',
      desc: '',
      args: [],
    );
  }

  /// `Smoothed trend candles`
  String get chart_type_heikin_ashi_desc {
    return Intl.message(
      'Smoothed trend candles',
      name: 'chart_type_heikin_ashi_desc',
      desc: '',
      args: [],
    );
  }

  /// `Renko`
  String get chart_type_renko {
    return Intl.message('Renko', name: 'chart_type_renko', desc: '', args: []);
  }

  /// `Brick-based chart`
  String get chart_type_renko_desc {
    return Intl.message(
      'Brick-based chart',
      name: 'chart_type_renko_desc',
      desc: '',
      args: [],
    );
  }

  /// `Drawing Tools`
  String get drawing_tools_title {
    return Intl.message(
      'Drawing Tools',
      name: 'drawing_tools_title',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get drawing_tools_clear_all {
    return Intl.message(
      'Clear All',
      name: 'drawing_tools_clear_all',
      desc: '',
      args: [],
    );
  }

  /// `Select Tool`
  String get drawing_tools_select_tool {
    return Intl.message(
      'Select Tool',
      name: 'drawing_tools_select_tool',
      desc: '',
      args: [],
    );
  }

  /// `Line`
  String get drawing_tools_line {
    return Intl.message('Line', name: 'drawing_tools_line', desc: '', args: []);
  }

  /// `H-Line`
  String get drawing_tools_h_line {
    return Intl.message(
      'H-Line',
      name: 'drawing_tools_h_line',
      desc: '',
      args: [],
    );
  }

  /// `V-Line`
  String get drawing_tools_v_line {
    return Intl.message(
      'V-Line',
      name: 'drawing_tools_v_line',
      desc: '',
      args: [],
    );
  }

  /// `Rect`
  String get drawing_tools_rect {
    return Intl.message('Rect', name: 'drawing_tools_rect', desc: '', args: []);
  }

  /// `Color`
  String get drawing_tools_color {
    return Intl.message(
      'Color',
      name: 'drawing_tools_color',
      desc: '',
      args: [],
    );
  }

  /// `Width`
  String get drawing_tools_width {
    return Intl.message(
      'Width',
      name: 'drawing_tools_width',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get drawing_tools_preview {
    return Intl.message(
      'Preview',
      name: 'drawing_tools_preview',
      desc: '',
      args: [],
    );
  }

  /// `Edit Drawing`
  String get drawing_tools_edit_title {
    return Intl.message(
      'Edit Drawing',
      name: 'drawing_tools_edit_title',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get drawing_tools_done {
    return Intl.message('Done', name: 'drawing_tools_done', desc: '', args: []);
  }

  /// `Select`
  String get chart_header_select {
    return Intl.message(
      'Select',
      name: 'chart_header_select',
      desc: '',
      args: [],
    );
  }

  /// `Toggle Watchlist`
  String get chart_header_toggle_watchlist {
    return Intl.message(
      'Toggle Watchlist',
      name: 'chart_header_toggle_watchlist',
      desc: '',
      args: [],
    );
  }

  /// `Select Crypto`
  String get chart_header_select_crypto {
    return Intl.message(
      'Select Crypto',
      name: 'chart_header_select_crypto',
      desc: '',
      args: [],
    );
  }

  /// `Search...`
  String get chart_header_search_hint {
    return Intl.message(
      'Search...',
      name: 'chart_header_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get chart_header_no_results {
    return Intl.message(
      'No results',
      name: 'chart_header_no_results',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get sidebar_details {
    return Intl.message('Details', name: 'sidebar_details', desc: '', args: []);
  }

  /// `Watchlist`
  String get sidebar_watchlist {
    return Intl.message(
      'Watchlist',
      name: 'sidebar_watchlist',
      desc: '',
      args: [],
    );
  }

  /// `Show Watchlist`
  String get sidebar_show_watchlist {
    return Intl.message(
      'Show Watchlist',
      name: 'sidebar_show_watchlist',
      desc: '',
      args: [],
    );
  }

  /// `Show Details`
  String get sidebar_show_details {
    return Intl.message(
      'Show Details',
      name: 'sidebar_show_details',
      desc: '',
      args: [],
    );
  }

  /// `Search Symbol`
  String get sidebar_search_symbol {
    return Intl.message(
      'Search Symbol',
      name: 'sidebar_search_symbol',
      desc: '',
      args: [],
    );
  }

  /// `Symbol`
  String get sidebar_symbol {
    return Intl.message('Symbol', name: 'sidebar_symbol', desc: '', args: []);
  }

  /// `Last`
  String get sidebar_last {
    return Intl.message('Last', name: 'sidebar_last', desc: '', args: []);
  }

  /// `Chg`
  String get sidebar_chg {
    return Intl.message('Chg', name: 'sidebar_chg', desc: '', args: []);
  }

  /// `Chg%`
  String get sidebar_chg_percent {
    return Intl.message(
      'Chg%',
      name: 'sidebar_chg_percent',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get sidebar_no_results {
    return Intl.message(
      'No results found',
      name: 'sidebar_no_results',
      desc: '',
      args: [],
    );
  }

  /// `No assets available`
  String get sidebar_no_assets {
    return Intl.message(
      'No assets available',
      name: 'sidebar_no_assets',
      desc: '',
      args: [],
    );
  }

  /// `No asset selected`
  String get details_no_asset {
    return Intl.message(
      'No asset selected',
      name: 'details_no_asset',
      desc: '',
      args: [],
    );
  }

  /// `Spot`
  String get details_spot {
    return Intl.message('Spot', name: 'details_spot', desc: '', args: []);
  }

  /// `Asset`
  String get details_asset_fallback {
    return Intl.message(
      'Asset',
      name: 'details_asset_fallback',
      desc: '',
      args: [],
    );
  }

  /// `Market open`
  String get details_market_open {
    return Intl.message(
      'Market open',
      name: 'details_market_open',
      desc: '',
      args: [],
    );
  }

  /// `Market closed`
  String get details_market_closed {
    return Intl.message(
      'Market closed',
      name: 'details_market_closed',
      desc: '',
      args: [],
    );
  }

  /// `Key stats`
  String get details_key_stats {
    return Intl.message(
      'Key stats',
      name: 'details_key_stats',
      desc: '',
      args: [],
    );
  }

  /// `Volume`
  String get details_volume {
    return Intl.message('Volume', name: 'details_volume', desc: '', args: []);
  }

  /// `Average Volume (30D)`
  String get details_avg_volume_30d {
    return Intl.message(
      'Average Volume (30D)',
      name: 'details_avg_volume_30d',
      desc: '',
      args: [],
    );
  }

  /// `Trading Volume 24h`
  String get details_volume_24h {
    return Intl.message(
      'Trading Volume 24h',
      name: 'details_volume_24h',
      desc: '',
      args: [],
    );
  }

  /// `Market capitalization`
  String get details_market_cap {
    return Intl.message(
      'Market capitalization',
      name: 'details_market_cap',
      desc: '',
      args: [],
    );
  }

  /// `Fully diluted market cap`
  String get details_fully_diluted_mc {
    return Intl.message(
      'Fully diluted market cap',
      name: 'details_fully_diluted_mc',
      desc: '',
      args: [],
    );
  }

  /// `Volume / Market Cap`
  String get details_vol_mc_ratio {
    return Intl.message(
      'Volume / Market Cap',
      name: 'details_vol_mc_ratio',
      desc: '',
      args: [],
    );
  }

  /// `Circulating supply`
  String get details_circulating_supply {
    return Intl.message(
      'Circulating supply',
      name: 'details_circulating_supply',
      desc: '',
      args: [],
    );
  }

  /// `Seasonals`
  String get details_seasonals {
    return Intl.message(
      'Seasonals',
      name: 'details_seasonals',
      desc: '',
      args: [],
    );
  }

  /// `Technicals`
  String get details_technicals {
    return Intl.message(
      'Technicals',
      name: 'details_technicals',
      desc: '',
      args: [],
    );
  }

  /// `Strong Sell`
  String get gauge_strong_sell {
    return Intl.message(
      'Strong Sell',
      name: 'gauge_strong_sell',
      desc: '',
      args: [],
    );
  }

  /// `Sell`
  String get gauge_sell {
    return Intl.message('Sell', name: 'gauge_sell', desc: '', args: []);
  }

  /// `Neutral`
  String get gauge_neutral {
    return Intl.message('Neutral', name: 'gauge_neutral', desc: '', args: []);
  }

  /// `Buy`
  String get gauge_buy {
    return Intl.message('Buy', name: 'gauge_buy', desc: '', args: []);
  }

  /// `Strong Buy`
  String get gauge_strong_buy {
    return Intl.message(
      'Strong Buy',
      name: 'gauge_strong_buy',
      desc: '',
      args: [],
    );
  }

  /// `Trend (Moving Averages)`
  String get gauge_trend_ma {
    return Intl.message(
      'Trend (Moving Averages)',
      name: 'gauge_trend_ma',
      desc: '',
      args: [],
    );
  }

  /// `Oscillators`
  String get gauge_oscillators {
    return Intl.message(
      'Oscillators',
      name: 'gauge_oscillators',
      desc: '',
      args: [],
    );
  }

  /// `Bollinger Band Buy Signal (Price at Lower Band + Oversold RSI)`
  String get gauge_bollinger_desc {
    return Intl.message(
      'Bollinger Band Buy Signal (Price at Lower Band + Oversold RSI)',
      name: 'gauge_bollinger_desc',
      desc: '',
      args: [],
    );
  }

  /// `{count} Buy`
  String gauge_buy_count(Object count) {
    return Intl.message(
      '$count Buy',
      name: 'gauge_buy_count',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Neutral`
  String gauge_neutral_count(Object count) {
    return Intl.message(
      '$count Neutral',
      name: 'gauge_neutral_count',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Sell`
  String gauge_sell_count(Object count) {
    return Intl.message(
      '$count Sell',
      name: 'gauge_sell_count',
      desc: '',
      args: [count],
    );
  }

  /// `My Position`
  String get position_my_position {
    return Intl.message(
      'My Position',
      name: 'position_my_position',
      desc: '',
      args: [],
    );
  }

  /// `{count} Shares`
  String position_shares(Object count) {
    return Intl.message(
      '$count Shares',
      name: 'position_shares',
      desc: '',
      args: [count],
    );
  }

  /// `Avg. Buy Price`
  String get position_avg_buy_price {
    return Intl.message(
      'Avg. Buy Price',
      name: 'position_avg_buy_price',
      desc: '',
      args: [],
    );
  }

  /// `Current Price`
  String get position_current_price {
    return Intl.message(
      'Current Price',
      name: 'position_current_price',
      desc: '',
      args: [],
    );
  }

  /// `Total Cost`
  String get position_total_cost {
    return Intl.message(
      'Total Cost',
      name: 'position_total_cost',
      desc: '',
      args: [],
    );
  }

  /// `Current Value`
  String get position_current_value {
    return Intl.message(
      'Current Value',
      name: 'position_current_value',
      desc: '',
      args: [],
    );
  }

  /// `Total P&L`
  String get position_total_pl {
    return Intl.message(
      'Total P&L',
      name: 'position_total_pl',
      desc: '',
      args: [],
    );
  }

  /// `P&L`
  String get position_pl_short {
    return Intl.message('P&L', name: 'position_pl_short', desc: '', args: []);
  }

  /// `Shares Owned`
  String get position_shares_owned {
    return Intl.message(
      'Shares Owned',
      name: 'position_shares_owned',
      desc: '',
      args: [],
    );
  }

  /// `px`
  String get drawing_tools_px {
    return Intl.message('px', name: 'drawing_tools_px', desc: '', args: []);
  }

  /// `Buy`
  String get order_buy {
    return Intl.message('Buy', name: 'order_buy', desc: '', args: []);
  }

  /// `Sell`
  String get order_sell {
    return Intl.message('Sell', name: 'order_sell', desc: '', args: []);
  }

  /// `Market`
  String get order_market {
    return Intl.message('Market', name: 'order_market', desc: '', args: []);
  }

  /// `Limit`
  String get order_limit {
    return Intl.message('Limit', name: 'order_limit', desc: '', args: []);
  }

  /// `Quantity`
  String get order_quantity {
    return Intl.message('Quantity', name: 'order_quantity', desc: '', args: []);
  }

  /// `Price`
  String get order_price {
    return Intl.message('Price', name: 'order_price', desc: '', args: []);
  }

  /// `Estimated Total: EGP {total}`
  String order_est_total(Object total) {
    return Intl.message(
      'Estimated Total: EGP $total',
      name: 'order_est_total',
      desc: '',
      args: [total],
    );
  }

  /// `Available Balance: EGP {balance}`
  String order_available_balance(Object balance) {
    return Intl.message(
      'Available Balance: EGP $balance',
      name: 'order_available_balance',
      desc: '',
      args: [balance],
    );
  }

  /// `PLACE {action} ORDER`
  String order_place_order(Object action) {
    return Intl.message(
      'PLACE $action ORDER',
      name: 'order_place_order',
      desc: '',
      args: [action],
    );
  }

  /// `Please enter a valid quantity`
  String get order_valid_qty {
    return Intl.message(
      'Please enter a valid quantity',
      name: 'order_valid_qty',
      desc: '',
      args: [],
    );
  }

  /// `Simulation feature is not available right now`
  String get order_sim_not_available {
    return Intl.message(
      'Simulation feature is not available right now',
      name: 'order_sim_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Trade Executed`
  String get order_trade_executed {
    return Intl.message(
      'Trade Executed',
      name: 'order_trade_executed',
      desc: '',
      args: [],
    );
  }

  /// `Sold {qty} shares of {symbol}`
  String order_sold_msg(Object qty, Object symbol) {
    return Intl.message(
      'Sold $qty shares of $symbol',
      name: 'order_sold_msg',
      desc: '',
      args: [qty, symbol],
    );
  }

  /// `Bought {symbol} without protection`
  String order_bought_msg(Object symbol) {
    return Intl.message(
      'Bought $symbol without protection',
      name: 'order_bought_msg',
      desc: '',
      args: [symbol],
    );
  }

  /// `🎉 Trade Successful!`
  String get order_protection_title {
    return Intl.message(
      '🎉 Trade Successful!',
      name: 'order_protection_title',
      desc: '',
      args: [],
    );
  }

  /// `Enable capital protection for {symbol}?`
  String order_protection_desc(Object symbol) {
    return Intl.message(
      'Enable capital protection for $symbol?',
      name: 'order_protection_desc',
      desc: '',
      args: [symbol],
    );
  }

  /// `📢 Alert Threshold`
  String get order_alert_threshold {
    return Intl.message(
      '📢 Alert Threshold',
      name: 'order_alert_threshold',
      desc: '',
      args: [],
    );
  }

  /// `Auto-Sell`
  String get order_auto_sell {
    return Intl.message(
      'Auto-Sell',
      name: 'order_auto_sell',
      desc: '',
      args: [],
    );
  }

  /// `🛡️ Auto-Sell Threshold`
  String get order_auto_sell_threshold {
    return Intl.message(
      '🛡️ Auto-Sell Threshold',
      name: 'order_auto_sell_threshold',
      desc: '',
      args: [],
    );
  }

  /// `Alert at {alert}% loss, auto-sell at {sell}% loss.`
  String order_protection_info_both(Object alert, Object sell) {
    return Intl.message(
      'Alert at $alert% loss, auto-sell at $sell% loss.',
      name: 'order_protection_info_both',
      desc: '',
      args: [alert, sell],
    );
  }

  /// `Alert only at {alert}% loss. No automatic selling.`
  String order_protection_info_alert(Object alert) {
    return Intl.message(
      'Alert only at $alert% loss. No automatic selling.',
      name: 'order_protection_info_alert',
      desc: '',
      args: [alert],
    );
  }

  /// `Skip`
  String get order_skip {
    return Intl.message('Skip', name: 'order_skip', desc: '', args: []);
  }

  /// `Enable Protection`
  String get order_enable_protection {
    return Intl.message(
      'Enable Protection',
      name: 'order_enable_protection',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get order_saving {
    return Intl.message('Saving...', name: 'order_saving', desc: '', args: []);
  }

  /// `Protection Enabled 🛡️`
  String get order_protection_enabled {
    return Intl.message(
      'Protection Enabled 🛡️',
      name: 'order_protection_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Monitoring {symbol} — {msg}`
  String order_monitoring_msg(Object symbol, Object msg) {
    return Intl.message(
      'Monitoring $symbol — $msg',
      name: 'order_monitoring_msg',
      desc: '',
      args: [symbol, msg],
    );
  }

  /// `Alert: {alert}% / Sell: {sell}%`
  String order_msg_both(Object alert, Object sell) {
    return Intl.message(
      'Alert: $alert% / Sell: $sell%',
      name: 'order_msg_both',
      desc: '',
      args: [alert, sell],
    );
  }

  /// `Alert only at {alert}% loss`
  String order_msg_alert(Object alert) {
    return Intl.message(
      'Alert only at $alert% loss',
      name: 'order_msg_alert',
      desc: '',
      args: [alert],
    );
  }

  /// `Technical Indicators`
  String get indicators_title {
    return Intl.message(
      'Technical Indicators',
      name: 'indicators_title',
      desc: '',
      args: [],
    );
  }

  /// `Tap an indicator to configure its settings`
  String get indicators_config_hint {
    return Intl.message(
      'Tap an indicator to configure its settings',
      name: 'indicators_config_hint',
      desc: '',
      args: [],
    );
  }

  /// `Simple Moving Average (SMA)`
  String get indicators_sma {
    return Intl.message(
      'Simple Moving Average (SMA)',
      name: 'indicators_sma',
      desc: '',
      args: [],
    );
  }

  /// `SMA`
  String get indicators_sma_short {
    return Intl.message(
      'SMA',
      name: 'indicators_sma_short',
      desc: '',
      args: [],
    );
  }

  /// `Shows the average price over a specified period, helping identify trends.`
  String get indicators_sma_desc {
    return Intl.message(
      'Shows the average price over a specified period, helping identify trends.',
      name: 'indicators_sma_desc',
      desc: '',
      args: [],
    );
  }

  /// `Exponential Moving Average (EMA)`
  String get indicators_ema {
    return Intl.message(
      'Exponential Moving Average (EMA)',
      name: 'indicators_ema',
      desc: '',
      args: [],
    );
  }

  /// `EMA`
  String get indicators_ema_short {
    return Intl.message(
      'EMA',
      name: 'indicators_ema_short',
      desc: '',
      args: [],
    );
  }

  /// `Similar to SMA but gives more weight to recent prices, reacting faster to changes.`
  String get indicators_ema_desc {
    return Intl.message(
      'Similar to SMA but gives more weight to recent prices, reacting faster to changes.',
      name: 'indicators_ema_desc',
      desc: '',
      args: [],
    );
  }

  /// `Bollinger Bands`
  String get indicators_bollinger {
    return Intl.message(
      'Bollinger Bands',
      name: 'indicators_bollinger',
      desc: '',
      args: [],
    );
  }

  /// `Bollinger`
  String get indicators_bollinger_short {
    return Intl.message(
      'Bollinger',
      name: 'indicators_bollinger_short',
      desc: '',
      args: [],
    );
  }

  /// `Shows price volatility with upper and lower bands around a moving average. Prices tend to bounce within the bands.`
  String get indicators_bollinger_desc {
    return Intl.message(
      'Shows price volatility with upper and lower bands around a moving average. Prices tend to bounce within the bands.',
      name: 'indicators_bollinger_desc',
      desc: '',
      args: [],
    );
  }

  /// `Relative Strength Index (RSI)`
  String get indicators_rsi {
    return Intl.message(
      'Relative Strength Index (RSI)',
      name: 'indicators_rsi',
      desc: '',
      args: [],
    );
  }

  /// `RSI`
  String get indicators_rsi_short {
    return Intl.message(
      'RSI',
      name: 'indicators_rsi_short',
      desc: '',
      args: [],
    );
  }

  /// `Measures the speed and magnitude of price changes. Values above 70 indicate overbought, below 30 indicate oversold.`
  String get indicators_rsi_desc {
    return Intl.message(
      'Measures the speed and magnitude of price changes. Values above 70 indicate overbought, below 30 indicate oversold.',
      name: 'indicators_rsi_desc',
      desc: '',
      args: [],
    );
  }

  /// `Volume Bars`
  String get indicators_volume {
    return Intl.message(
      'Volume Bars',
      name: 'indicators_volume',
      desc: '',
      args: [],
    );
  }

  /// `Show trading volume at the bottom of the chart`
  String get indicators_volume_desc {
    return Intl.message(
      'Show trading volume at the bottom of the chart',
      name: 'indicators_volume_desc',
      desc: '',
      args: [],
    );
  }

  /// `Enable Indicator`
  String get indicators_enable {
    return Intl.message(
      'Enable Indicator',
      name: 'indicators_enable',
      desc: '',
      args: [],
    );
  }

  /// `Period`
  String get indicators_period {
    return Intl.message(
      'Period',
      name: 'indicators_period',
      desc: '',
      args: [],
    );
  }

  /// `Number of candles used for calculation (Default: {defaultPeriod})`
  String indicators_period_desc(Object defaultPeriod) {
    return Intl.message(
      'Number of candles used for calculation (Default: $defaultPeriod)',
      name: 'indicators_period_desc',
      desc: '',
      args: [defaultPeriod],
    );
  }

  /// `Period: {period}`
  String indicators_period_val(Object period) {
    return Intl.message(
      'Period: $period',
      name: 'indicators_period_val',
      desc: '',
      args: [period],
    );
  }

  /// `P: {p}, SD: {sd}`
  String indicators_bollinger_val(Object p, Object sd) {
    return Intl.message(
      'P: $p, SD: $sd',
      name: 'indicators_bollinger_val',
      desc: '',
      args: [p, sd],
    );
  }

  /// `Apply Settings`
  String get indicators_apply {
    return Intl.message(
      'Apply Settings',
      name: 'indicators_apply',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get indicators_default {
    return Intl.message(
      'Default',
      name: 'indicators_default',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get indicators_reset {
    return Intl.message('Reset', name: 'indicators_reset', desc: '', args: []);
  }

  /// `Quick select:`
  String get indicators_quick_select {
    return Intl.message(
      'Quick select:',
      name: 'indicators_quick_select',
      desc: '',
      args: [],
    );
  }

  /// `Standard Deviation`
  String get indicators_std_dev {
    return Intl.message(
      'Standard Deviation',
      name: 'indicators_std_dev',
      desc: '',
      args: [],
    );
  }

  /// `Distance of bands from the middle line (Default: {defaultStdDev}σ)`
  String indicators_std_dev_desc(Object defaultStdDev) {
    return Intl.message(
      'Distance of bands from the middle line (Default: $defaultStdDevσ)',
      name: 'indicators_std_dev_desc',
      desc: '',
      args: [defaultStdDev],
    );
  }

  /// `Tight`
  String get indicators_tight {
    return Intl.message('Tight', name: 'indicators_tight', desc: '', args: []);
  }

  /// `Normal`
  String get indicators_normal {
    return Intl.message(
      'Normal',
      name: 'indicators_normal',
      desc: '',
      args: [],
    );
  }

  /// `Wide`
  String get indicators_wide {
    return Intl.message('Wide', name: 'indicators_wide', desc: '', args: []);
  }

  /// `Select an Asset from the list`
  String get markets_select_asset {
    return Intl.message(
      'Select an Asset from the list',
      name: 'markets_select_asset',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get search_cat_all {
    return Intl.message('All', name: 'search_cat_all', desc: '', args: []);
  }

  /// `Stocks`
  String get search_cat_stocks {
    return Intl.message(
      'Stocks',
      name: 'search_cat_stocks',
      desc: '',
      args: [],
    );
  }

  /// `Indices`
  String get search_cat_indices {
    return Intl.message(
      'Indices',
      name: 'search_cat_indices',
      desc: '',
      args: [],
    );
  }

  /// `Crypto`
  String get search_cat_crypto {
    return Intl.message(
      'Crypto',
      name: 'search_cat_crypto',
      desc: '',
      args: [],
    );
  }

  /// `Materials`
  String get search_cat_materials {
    return Intl.message(
      'Materials',
      name: 'search_cat_materials',
      desc: '',
      args: [],
    );
  }

  /// `Search symbol...`
  String get search_hint_main {
    return Intl.message(
      'Search symbol...',
      name: 'search_hint_main',
      desc: '',
      args: [],
    );
  }

  /// `Market Movers`
  String get search_market_movers {
    return Intl.message(
      'Market Movers',
      name: 'search_market_movers',
      desc: '',
      args: [],
    );
  }

  /// `Market Overview`
  String get search_market_overview {
    return Intl.message(
      'Market Overview',
      name: 'search_market_overview',
      desc: '',
      args: [],
    );
  }

  /// `Latest News`
  String get search_latest_news {
    return Intl.message(
      'Latest News',
      name: 'search_latest_news',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get search_view_all {
    return Intl.message(
      'View All',
      name: 'search_view_all',
      desc: '',
      args: [],
    );
  }

  /// `No news available`
  String get search_no_news {
    return Intl.message(
      'No news available',
      name: 'search_no_news',
      desc: '',
      args: [],
    );
  }

  /// `No results found`
  String get search_results_not_found {
    return Intl.message(
      'No results found',
      name: 'search_results_not_found',
      desc: '',
      args: [],
    );
  }

  /// `All News`
  String get search_all_news {
    return Intl.message(
      'All News',
      name: 'search_all_news',
      desc: '',
      args: [],
    );
  }

  /// `News Details`
  String get search_news_details {
    return Intl.message(
      'News Details',
      name: 'search_news_details',
      desc: '',
      args: [],
    );
  }

  /// `Please check the source for details`
  String get search_tts_check_source {
    return Intl.message(
      'Please check the source for details',
      name: 'search_tts_check_source',
      desc: '',
      args: [],
    );
  }

  /// `EGX News`
  String get search_egx_news {
    return Intl.message(
      'EGX News',
      name: 'search_egx_news',
      desc: '',
      args: [],
    );
  }

  /// `No content available.`
  String get search_no_content {
    return Intl.message(
      'No content available.',
      name: 'search_no_content',
      desc: '',
      args: [],
    );
  }

  /// `Read Original Article`
  String get search_read_original {
    return Intl.message(
      'Read Original Article',
      name: 'search_read_original',
      desc: '',
      args: [],
    );
  }

  /// `Asset`
  String get search_asset {
    return Intl.message('Asset', name: 'search_asset', desc: '', args: []);
  }

  /// `Pts`
  String get search_pts {
    return Intl.message('Pts', name: 'search_pts', desc: '', args: []);
  }

  /// `EGP`
  String get search_egp {
    return Intl.message('EGP', name: 'search_egp', desc: '', args: []);
  }

  /// `$`
  String get search_currency_usd {
    return Intl.message('\$', name: 'search_currency_usd', desc: '', args: []);
  }

  /// `Community`
  String get community_title {
    return Intl.message(
      'Community',
      name: 'community_title',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get community_all {
    return Intl.message('All', name: 'community_all', desc: '', args: []);
  }

  /// `All Feeds`
  String get community_all_feeds {
    return Intl.message(
      'All Feeds',
      name: 'community_all_feeds',
      desc: '',
      args: [],
    );
  }

  /// `Posts`
  String get community_posts {
    return Intl.message('Posts', name: 'community_posts', desc: '', args: []);
  }

  /// `Followers`
  String get community_followers {
    return Intl.message(
      'Followers',
      name: 'community_followers',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get community_following {
    return Intl.message(
      'Following',
      name: 'community_following',
      desc: '',
      args: [],
    );
  }

  /// `COMMUNITIES`
  String get community_communities {
    return Intl.message(
      'COMMUNITIES',
      name: 'community_communities',
      desc: '',
      args: [],
    );
  }

  /// `Trending Topics`
  String get community_trending_topics {
    return Intl.message(
      'Trending Topics',
      name: 'community_trending_topics',
      desc: '',
      args: [],
    );
  }

  /// `Who to follow`
  String get community_who_to_follow {
    return Intl.message(
      'Who to follow',
      name: 'community_who_to_follow',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get community_follow {
    return Intl.message('Follow', name: 'community_follow', desc: '', args: []);
  }

  /// `User`
  String get community_user {
    return Intl.message('User', name: 'community_user', desc: '', args: []);
  }

  /// `No posts yet`
  String get community_no_posts {
    return Intl.message(
      'No posts yet',
      name: 'community_no_posts',
      desc: '',
      args: [],
    );
  }

  /// `Bullish`
  String get community_bullish {
    return Intl.message(
      'Bullish',
      name: 'community_bullish',
      desc: '',
      args: [],
    );
  }

  /// `Bearish`
  String get community_bearish {
    return Intl.message(
      'Bearish',
      name: 'community_bearish',
      desc: '',
      args: [],
    );
  }

  /// `Just now`
  String get community_just_now {
    return Intl.message(
      'Just now',
      name: 'community_just_now',
      desc: '',
      args: [],
    );
  }

  /// `{count}d ago`
  String community_time_ago_days(Object count) {
    return Intl.message(
      '${count}d ago',
      name: 'community_time_ago_days',
      desc: '',
      args: [count],
    );
  }

  /// `{count}h ago`
  String community_time_ago_hours(Object count) {
    return Intl.message(
      '${count}h ago',
      name: 'community_time_ago_hours',
      desc: '',
      args: [count],
    );
  }

  /// `{count}m ago`
  String community_time_ago_minutes(Object count) {
    return Intl.message(
      '${count}m ago',
      name: 'community_time_ago_minutes',
      desc: '',
      args: [count],
    );
  }

  /// `Please login to like posts`
  String get community_login_to_like {
    return Intl.message(
      'Please login to like posts',
      name: 'community_login_to_like',
      desc: '',
      args: [],
    );
  }

  /// `Could not like post`
  String get community_like_failed {
    return Intl.message(
      'Could not like post',
      name: 'community_like_failed',
      desc: '',
      args: [],
    );
  }

  /// `Please login to bookmark posts`
  String get community_login_to_bookmark {
    return Intl.message(
      'Please login to bookmark posts',
      name: 'community_login_to_bookmark',
      desc: '',
      args: [],
    );
  }

  /// `Could not save post`
  String get community_save_failed {
    return Intl.message(
      'Could not save post',
      name: 'community_save_failed',
      desc: '',
      args: [],
    );
  }

  /// `Holdings`
  String get sim_holdings {
    return Intl.message('Holdings', name: 'sim_holdings', desc: '', args: []);
  }

  /// `Holdings ({count})`
  String sim_holdings_count(Object count) {
    return Intl.message(
      'Holdings ($count)',
      name: 'sim_holdings_count',
      desc: '',
      args: [count],
    );
  }

  /// `View All`
  String get sim_view_all {
    return Intl.message('View All', name: 'sim_view_all', desc: '', args: []);
  }

  /// `No holdings yet`
  String get sim_no_holdings {
    return Intl.message(
      'No holdings yet',
      name: 'sim_no_holdings',
      desc: '',
      args: [],
    );
  }

  /// `Start trading to build your portfolio`
  String get sim_start_trading {
    return Intl.message(
      'Start trading to build your portfolio',
      name: 'sim_start_trading',
      desc: '',
      args: [],
    );
  }

  /// `Go to Markets`
  String get sim_go_to_markets {
    return Intl.message(
      'Go to Markets',
      name: 'sim_go_to_markets',
      desc: '',
      args: [],
    );
  }

  /// `Transaction History`
  String get sim_transaction_history {
    return Intl.message(
      'Transaction History',
      name: 'sim_transaction_history',
      desc: '',
      args: [],
    );
  }

  /// `No transactions yet`
  String get sim_no_transactions {
    return Intl.message(
      'No transactions yet',
      name: 'sim_no_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Your trading history will appear here`
  String get sim_trading_history_desc {
    return Intl.message(
      'Your trading history will appear here',
      name: 'sim_trading_history_desc',
      desc: '',
      args: [],
    );
  }

  /// `AUTO`
  String get sim_auto {
    return Intl.message('AUTO', name: 'sim_auto', desc: '', args: []);
  }

  /// `Quantity`
  String get sim_quantity {
    return Intl.message('Quantity', name: 'sim_quantity', desc: '', args: []);
  }

  /// `Price`
  String get sim_price {
    return Intl.message('Price', name: 'sim_price', desc: '', args: []);
  }

  /// `Total`
  String get sim_total_capital {
    return Intl.message('Total', name: 'sim_total_capital', desc: '', args: []);
  }

  /// `shares`
  String get sim_shares_unit {
    return Intl.message('shares', name: 'sim_shares_unit', desc: '', args: []);
  }

  /// `Avg Price`
  String get sim_avg_price {
    return Intl.message('Avg Price', name: 'sim_avg_price', desc: '', args: []);
  }

  /// `Current Price`
  String get sim_current_price {
    return Intl.message(
      'Current Price',
      name: 'sim_current_price',
      desc: '',
      args: [],
    );
  }

  /// `P&L`
  String get sim_pl {
    return Intl.message('P&L', name: 'sim_pl', desc: '', args: []);
  }

  /// `Total Portfolio Value`
  String get sim_total_portfolio_value {
    return Intl.message(
      'Total Portfolio Value',
      name: 'sim_total_portfolio_value',
      desc: '',
      args: [],
    );
  }

  /// `Available Cash`
  String get sim_available_cash {
    return Intl.message(
      'Available Cash',
      name: 'sim_available_cash',
      desc: '',
      args: [],
    );
  }

  /// `Positions`
  String get sim_positions {
    return Intl.message('Positions', name: 'sim_positions', desc: '', args: []);
  }

  /// `Capital Protection`
  String get sim_capital_protection {
    return Intl.message(
      'Capital Protection',
      name: 'sim_capital_protection',
      desc: '',
      args: [],
    );
  }

  /// `Alert Me`
  String get sim_alert_me {
    return Intl.message('Alert Me', name: 'sim_alert_me', desc: '', args: []);
  }

  /// `Notify when loss reaches threshold`
  String get sim_alert_desc {
    return Intl.message(
      'Notify when loss reaches threshold',
      name: 'sim_alert_desc',
      desc: '',
      args: [],
    );
  }

  /// `Auto-Sell`
  String get sim_auto_sell_protection {
    return Intl.message(
      'Auto-Sell',
      name: 'sim_auto_sell_protection',
      desc: '',
      args: [],
    );
  }

  /// `Automatically sell when loss reaches threshold`
  String get sim_auto_sell_desc {
    return Intl.message(
      'Automatically sell when loss reaches threshold',
      name: 'sim_auto_sell_desc',
      desc: '',
      args: [],
    );
  }

  /// `Both features are disabled. Enable at least one to protect your capital.`
  String get sim_both_disabled_msg {
    return Intl.message(
      'Both features are disabled. Enable at least one to protect your capital.',
      name: 'sim_both_disabled_msg',
      desc: '',
      args: [],
    );
  }

  /// `Alert at {percent}% loss`
  String sim_alert_at_msg(Object percent) {
    return Intl.message(
      'Alert at $percent% loss',
      name: 'sim_alert_at_msg',
      desc: '',
      args: [percent],
    );
  }

  /// `Auto-sell at {percent}% loss`
  String sim_auto_sell_at_msg(Object percent) {
    return Intl.message(
      'Auto-sell at $percent% loss',
      name: 'sim_auto_sell_at_msg',
      desc: '',
      args: [percent],
    );
  }

  /// `Remove`
  String get sim_remove {
    return Intl.message('Remove', name: 'sim_remove', desc: '', args: []);
  }

  /// `Update Rule`
  String get sim_update_rule {
    return Intl.message(
      'Update Rule',
      name: 'sim_update_rule',
      desc: '',
      args: [],
    );
  }

  /// `Save Rule`
  String get sim_save_rule {
    return Intl.message('Save Rule', name: 'sim_save_rule', desc: '', args: []);
  }

  /// `Protection rule updated for {symbol}`
  String sim_protection_updated(Object symbol) {
    return Intl.message(
      'Protection rule updated for $symbol',
      name: 'sim_protection_updated',
      desc: '',
      args: [symbol],
    );
  }

  /// `Protection rule saved for {symbol}`
  String sim_protection_saved(Object symbol) {
    return Intl.message(
      'Protection rule saved for $symbol',
      name: 'sim_protection_saved',
      desc: '',
      args: [symbol],
    );
  }

  /// `Protection removed for {symbol}`
  String sim_protection_removed(Object symbol) {
    return Intl.message(
      'Protection removed for $symbol',
      name: 'sim_protection_removed',
      desc: '',
      args: [symbol],
    );
  }

  /// `Failed to load simulation data`
  String get sim_failed_to_load {
    return Intl.message(
      'Failed to load simulation data',
      name: 'sim_failed_to_load',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save rule: {error}`
  String sim_failed_to_save_rule(Object error) {
    return Intl.message(
      'Failed to save rule: $error',
      name: 'sim_failed_to_save_rule',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to remove rule: {error}`
  String sim_failed_to_remove_rule(Object error) {
    return Intl.message(
      'Failed to remove rule: $error',
      name: 'sim_failed_to_remove_rule',
      desc: '',
      args: [error],
    );
  }

  /// `Failed to fetch wallet`
  String get sim_failed_to_fetch_wallet {
    return Intl.message(
      'Failed to fetch wallet',
      name: 'sim_failed_to_fetch_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch holdings`
  String get sim_failed_to_fetch_holdings {
    return Intl.message(
      'Failed to fetch holdings',
      name: 'sim_failed_to_fetch_holdings',
      desc: '',
      args: [],
    );
  }

  /// `Failed to fetch transactions`
  String get sim_failed_to_fetch_transactions {
    return Intl.message(
      'Failed to fetch transactions',
      name: 'sim_failed_to_fetch_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Simulation Portfolio`
  String get sim_portfolio_title {
    return Intl.message(
      'Simulation Portfolio',
      name: 'sim_portfolio_title',
      desc: '',
      args: [],
    );
  }

  /// `User not authenticated`
  String get sim_user_not_auth {
    return Intl.message(
      'User not authenticated',
      name: 'sim_user_not_auth',
      desc: '',
      args: [],
    );
  }

  /// `Set Protection`
  String get sim_set_protection {
    return Intl.message(
      'Set Protection',
      name: 'sim_set_protection',
      desc: '',
      args: [],
    );
  }

  /// `Protection Active (Alert: {alert}% / Sell: {sell}%)`
  String sim_protection_active(Object alert, Object sell) {
    return Intl.message(
      'Protection Active (Alert: $alert% / Sell: $sell%)',
      name: 'sim_protection_active',
      desc: '',
      args: [alert, sell],
    );
  }

  /// `Profile`
  String get profile_title {
    return Intl.message('Profile', name: 'profile_title', desc: '', args: []);
  }

  /// `No posts shared yet`
  String get profile_no_posts {
    return Intl.message(
      'No posts shared yet',
      name: 'profile_no_posts',
      desc: '',
      args: [],
    );
  }

  /// `User not found`
  String get profile_user_not_found {
    return Intl.message(
      'User not found',
      name: 'profile_user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `No followers yet`
  String get profile_no_followers {
    return Intl.message(
      'No followers yet',
      name: 'profile_no_followers',
      desc: '',
      args: [],
    );
  }

  /// `Not following anyone yet`
  String get profile_not_following_anyone {
    return Intl.message(
      'Not following anyone yet',
      name: 'profile_not_following_anyone',
      desc: '',
      args: [],
    );
  }

  /// `Create Post`
  String get profile_create_post {
    return Intl.message(
      'Create Post',
      name: 'profile_create_post',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get profile_post_button {
    return Intl.message(
      'Post',
      name: 'profile_post_button',
      desc: '',
      args: [],
    );
  }

  /// `Headline`
  String get profile_headline_hint {
    return Intl.message(
      'Headline',
      name: 'profile_headline_hint',
      desc: '',
      args: [],
    );
  }

  /// `Share your market analysis...\nUse $ for symbols like $EGX30`
  String get profile_post_hint {
    return Intl.message(
      'Share your market analysis...\nUse \$ for symbols like \$EGX30',
      name: 'profile_post_hint',
      desc: '',
      args: [],
    );
  }

  /// `SUGGESTED STOCKS`
  String get profile_suggested_stocks {
    return Intl.message(
      'SUGGESTED STOCKS',
      name: 'profile_suggested_stocks',
      desc: '',
      args: [],
    );
  }

  /// `Failed to update follow status`
  String get profile_failed_to_follow {
    return Intl.message(
      'Failed to update follow status',
      name: 'profile_failed_to_follow',
      desc: '',
      args: [],
    );
  }

  /// `Idea published successfully!`
  String get profile_idea_published {
    return Intl.message(
      'Idea published successfully!',
      name: 'profile_idea_published',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create post`
  String get profile_failed_to_create_post {
    return Intl.message(
      'Failed to create post',
      name: 'profile_failed_to_create_post',
      desc: '',
      args: [],
    );
  }

  /// `Please login to create a post`
  String get profile_login_to_post {
    return Intl.message(
      'Please login to create a post',
      name: 'profile_login_to_post',
      desc: '',
      args: [],
    );
  }

  /// `{count} posts`
  String profile_posts_count(Object count) {
    return Intl.message(
      '$count posts',
      name: 'profile_posts_count',
      desc: '',
      args: [count],
    );
  }

  /// `Start the discussion for {symbol}!`
  String stock_chat_start_discussion(Object symbol) {
    return Intl.message(
      'Start the discussion for $symbol!',
      name: 'stock_chat_start_discussion',
      desc: '',
      args: [symbol],
    );
  }

  /// `You`
  String get stock_chat_you {
    return Intl.message('You', name: 'stock_chat_you', desc: '', args: []);
  }

  /// `User`
  String get stock_chat_user_prefix {
    return Intl.message(
      'User',
      name: 'stock_chat_user_prefix',
      desc: '',
      args: [],
    );
  }

  /// `Join the discussion...`
  String get stock_chat_input_hint {
    return Intl.message(
      'Join the discussion...',
      name: 'stock_chat_input_hint',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send message`
  String get stock_chat_error_send {
    return Intl.message(
      'Failed to send message',
      name: 'stock_chat_error_send',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load post`
  String get post_details_error_load {
    return Intl.message(
      'Failed to load post',
      name: 'post_details_error_load',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add comment`
  String get post_details_error_add_comment {
    return Intl.message(
      'Failed to add comment',
      name: 'post_details_error_add_comment',
      desc: '',
      args: [],
    );
  }

  /// `Failed to vote`
  String get post_details_error_vote {
    return Intl.message(
      'Failed to vote',
      name: 'post_details_error_vote',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get post_details_user_fallback {
    return Intl.message(
      'User',
      name: 'post_details_user_fallback',
      desc: '',
      args: [],
    );
  }

  /// `Bullish`
  String get post_details_bullish {
    return Intl.message(
      'Bullish',
      name: 'post_details_bullish',
      desc: '',
      args: [],
    );
  }

  /// `Bearish`
  String get post_details_bearish {
    return Intl.message(
      'Bearish',
      name: 'post_details_bearish',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get post_details_comments_header {
    return Intl.message(
      'Comments',
      name: 'post_details_comments_header',
      desc: '',
      args: [],
    );
  }

  /// `No comments yet`
  String get post_details_no_comments {
    return Intl.message(
      'No comments yet',
      name: 'post_details_no_comments',
      desc: '',
      args: [],
    );
  }

  /// `Replying to {name}`
  String post_details_replying_to(Object name) {
    return Intl.message(
      'Replying to $name',
      name: 'post_details_replying_to',
      desc: '',
      args: [name],
    );
  }

  /// `Replying`
  String get post_details_replying {
    return Intl.message(
      'Replying',
      name: 'post_details_replying',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get post_details_reply {
    return Intl.message(
      'Reply',
      name: 'post_details_reply',
      desc: '',
      args: [],
    );
  }

  /// `View {count} replies`
  String post_details_view_replies(Object count) {
    return Intl.message(
      'View $count replies',
      name: 'post_details_view_replies',
      desc: '',
      args: [count],
    );
  }

  /// `Share your thoughts...`
  String get post_details_share_thoughts {
    return Intl.message(
      'Share your thoughts...',
      name: 'post_details_share_thoughts',
      desc: '',
      args: [],
    );
  }

  /// `Reply to {name}...`
  String post_details_reply_to_hint(Object name) {
    return Intl.message(
      'Reply to $name...',
      name: 'post_details_reply_to_hint',
      desc: '',
      args: [name],
    );
  }

  /// `Someone`
  String get post_details_someone {
    return Intl.message(
      'Someone',
      name: 'post_details_someone',
      desc: '',
      args: [],
    );
  }

  /// `Replies`
  String get post_details_replies_title {
    return Intl.message(
      'Replies',
      name: 'post_details_replies_title',
      desc: '',
      args: [],
    );
  }

  /// `EGX • Index`
  String get asset_details_index_label {
    return Intl.message(
      'EGX • Index',
      name: 'asset_details_index_label',
      desc: '',
      args: [],
    );
  }

  /// `EGX • Stock`
  String get asset_details_stock_label {
    return Intl.message(
      'EGX • Stock',
      name: 'asset_details_stock_label',
      desc: '',
      args: [],
    );
  }

  /// `EGP`
  String get asset_details_egp {
    return Intl.message('EGP', name: 'asset_details_egp', desc: '', args: []);
  }

  /// `USD`
  String get asset_details_usd {
    return Intl.message('USD', name: 'asset_details_usd', desc: '', args: []);
  }

  /// `Overview`
  String get asset_details_tab_overview {
    return Intl.message(
      'Overview',
      name: 'asset_details_tab_overview',
      desc: '',
      args: [],
    );
  }

  /// `News`
  String get asset_details_tab_news {
    return Intl.message(
      'News',
      name: 'asset_details_tab_news',
      desc: '',
      args: [],
    );
  }

  /// `Community`
  String get asset_details_tab_community {
    return Intl.message(
      'Community',
      name: 'asset_details_tab_community',
      desc: '',
      args: [],
    );
  }

  /// `Live Chat`
  String get asset_details_tab_live_chat {
    return Intl.message(
      'Live Chat',
      name: 'asset_details_tab_live_chat',
      desc: '',
      args: [],
    );
  }

  /// `No description available.`
  String get asset_details_no_description {
    return Intl.message(
      'No description available.',
      name: 'asset_details_no_description',
      desc: '',
      args: [],
    );
  }

  /// `No posts yet for this stock`
  String get asset_details_no_posts {
    return Intl.message(
      'No posts yet for this stock',
      name: 'asset_details_no_posts',
      desc: '',
      args: [],
    );
  }

  /// `Market Data`
  String get asset_details_market_data {
    return Intl.message(
      'Market Data',
      name: 'asset_details_market_data',
      desc: '',
      args: [],
    );
  }

  /// `Technicals`
  String get asset_details_technicals {
    return Intl.message(
      'Technicals',
      name: 'asset_details_technicals',
      desc: '',
      args: [],
    );
  }

  /// `Performance`
  String get asset_details_performance {
    return Intl.message(
      'Performance',
      name: 'asset_details_performance',
      desc: '',
      args: [],
    );
  }

  /// `Local Prices (EGP)`
  String get asset_details_local_prices {
    return Intl.message(
      'Local Prices (EGP)',
      name: 'asset_details_local_prices',
      desc: '',
      args: [],
    );
  }

  /// `Company Profile`
  String get asset_details_company_profile {
    return Intl.message(
      'Company Profile',
      name: 'asset_details_company_profile',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get asset_details_about {
    return Intl.message(
      'About',
      name: 'asset_details_about',
      desc: '',
      args: [],
    );
  }

  /// `Constituents`
  String get asset_details_constituents {
    return Intl.message(
      'Constituents',
      name: 'asset_details_constituents',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get asset_details_open {
    return Intl.message('Open', name: 'asset_details_open', desc: '', args: []);
  }

  /// `Prev Close`
  String get asset_details_prev_close {
    return Intl.message(
      'Prev Close',
      name: 'asset_details_prev_close',
      desc: '',
      args: [],
    );
  }

  /// `High`
  String get asset_details_high {
    return Intl.message('High', name: 'asset_details_high', desc: '', args: []);
  }

  /// `Low`
  String get asset_details_low {
    return Intl.message('Low', name: 'asset_details_low', desc: '', args: []);
  }

  /// `Volume`
  String get asset_details_volume {
    return Intl.message(
      'Volume',
      name: 'asset_details_volume',
      desc: '',
      args: [],
    );
  }

  /// `Avg Volume`
  String get asset_details_avg_volume {
    return Intl.message(
      'Avg Volume',
      name: 'asset_details_avg_volume',
      desc: '',
      args: [],
    );
  }

  /// `Volatility`
  String get asset_details_volatility {
    return Intl.message(
      'Volatility',
      name: 'asset_details_volatility',
      desc: '',
      args: [],
    );
  }

  /// `Mkt Cap`
  String get asset_details_mkt_cap {
    return Intl.message(
      'Mkt Cap',
      name: 'asset_details_mkt_cap',
      desc: '',
      args: [],
    );
  }

  /// `Key Statistics`
  String get asset_details_key_stats {
    return Intl.message(
      'Key Statistics',
      name: 'asset_details_key_stats',
      desc: '',
      args: [],
    );
  }

  /// `24k Gold`
  String get asset_details_gold_24k {
    return Intl.message(
      '24k Gold',
      name: 'asset_details_gold_24k',
      desc: '',
      args: [],
    );
  }

  /// `21k Gold`
  String get asset_details_gold_21k {
    return Intl.message(
      '21k Gold',
      name: 'asset_details_gold_21k',
      desc: '',
      args: [],
    );
  }

  /// `18k Gold`
  String get asset_details_gold_18k {
    return Intl.message(
      '18k Gold',
      name: 'asset_details_gold_18k',
      desc: '',
      args: [],
    );
  }

  /// `Silver 999`
  String get asset_details_silver_999 {
    return Intl.message(
      'Silver 999',
      name: 'asset_details_silver_999',
      desc: '',
      args: [],
    );
  }

  /// `Silver 800`
  String get asset_details_silver_800 {
    return Intl.message(
      'Silver 800',
      name: 'asset_details_silver_800',
      desc: '',
      args: [],
    );
  }

  /// `Arabic Name`
  String get asset_details_arabic_name {
    return Intl.message(
      'Arabic Name',
      name: 'asset_details_arabic_name',
      desc: '',
      args: [],
    );
  }

  /// `ISIN Code`
  String get asset_details_isin_code {
    return Intl.message(
      'ISIN Code',
      name: 'asset_details_isin_code',
      desc: '',
      args: [],
    );
  }

  /// `Listing Date`
  String get asset_details_listing_date {
    return Intl.message(
      'Listing Date',
      name: 'asset_details_listing_date',
      desc: '',
      args: [],
    );
  }

  /// `Website`
  String get asset_details_website {
    return Intl.message(
      'Website',
      name: 'asset_details_website',
      desc: '',
      args: [],
    );
  }

  /// `No Data Available`
  String get asset_details_no_chart_data {
    return Intl.message(
      'No Data Available',
      name: 'asset_details_no_chart_data',
      desc: '',
      args: [],
    );
  }

  /// `Gauge candle fetch error`
  String get asset_details_error_load_gauge {
    return Intl.message(
      'Gauge candle fetch error',
      name: 'asset_details_error_load_gauge',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching crypto historical data`
  String get asset_details_error_load_crypto_hist {
    return Intl.message(
      'Error fetching crypto historical data',
      name: 'asset_details_error_load_crypto_hist',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching stock candles`
  String get asset_details_error_load_stock_candles {
    return Intl.message(
      'Error fetching stock candles',
      name: 'asset_details_error_load_stock_candles',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching 24hr ticker`
  String get asset_details_error_load_ticker {
    return Intl.message(
      'Error fetching 24hr ticker',
      name: 'asset_details_error_load_ticker',
      desc: '',
      args: [],
    );
  }

  /// `Error updating stock candles`
  String get asset_details_error_update_stock_candles {
    return Intl.message(
      'Error updating stock candles',
      name: 'asset_details_error_update_stock_candles',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching material price`
  String get asset_details_error_load_material {
    return Intl.message(
      'Error fetching material price',
      name: 'asset_details_error_load_material',
      desc: '',
      args: [],
    );
  }

  /// `Added to Watchlist`
  String get asset_details_watchlist_added {
    return Intl.message(
      'Added to Watchlist',
      name: 'asset_details_watchlist_added',
      desc: '',
      args: [],
    );
  }

  /// `Removed from Watchlist`
  String get asset_details_watchlist_removed {
    return Intl.message(
      'Removed from Watchlist',
      name: 'asset_details_watchlist_removed',
      desc: '',
      args: [],
    );
  }

  /// `{symbol} has been added to your watchlist`
  String asset_details_watchlist_added_msg(Object symbol) {
    return Intl.message(
      '$symbol has been added to your watchlist',
      name: 'asset_details_watchlist_added_msg',
      desc: '',
      args: [symbol],
    );
  }

  /// `{symbol} has been removed from your watchlist`
  String asset_details_watchlist_removed_msg(Object symbol) {
    return Intl.message(
      '$symbol has been removed from your watchlist',
      name: 'asset_details_watchlist_removed_msg',
      desc: '',
      args: [symbol],
    );
  }

  /// `Could not update watchlist`
  String get asset_details_watchlist_error {
    return Intl.message(
      'Could not update watchlist',
      name: 'asset_details_watchlist_error',
      desc: '',
      args: [],
    );
  }

  /// `No News Available`
  String get asset_details_news_no_news {
    return Intl.message(
      'No News Available',
      name: 'asset_details_news_no_news',
      desc: '',
      args: [],
    );
  }

  /// `There is no news available for this asset to summarize.`
  String get asset_details_news_no_news_msg {
    return Intl.message(
      'There is no news available for this asset to summarize.',
      name: 'asset_details_news_no_news_msg',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient News`
  String get asset_details_news_insufficient {
    return Intl.message(
      'Insufficient News',
      name: 'asset_details_news_insufficient',
      desc: '',
      args: [],
    );
  }

  /// `Not enough recent news to generate a meaningful summary. At least 3 articles are required.`
  String get asset_details_news_insufficient_msg {
    return Intl.message(
      'Not enough recent news to generate a meaningful summary. At least 3 articles are required.',
      name: 'asset_details_news_insufficient_msg',
      desc: '',
      args: [],
    );
  }

  /// `Summarization Failed`
  String get asset_details_news_fail {
    return Intl.message(
      'Summarization Failed',
      name: 'asset_details_news_fail',
      desc: '',
      args: [],
    );
  }

  /// `Failed to generate summary. Please try again later.`
  String get asset_details_news_fail_msg {
    return Intl.message(
      'Failed to generate summary. Please try again later.',
      name: 'asset_details_news_fail_msg',
      desc: '',
      args: [],
    );
  }

  /// `Could not like post`
  String get asset_details_post_like_error {
    return Intl.message(
      'Could not like post',
      name: 'asset_details_post_like_error',
      desc: '',
      args: [],
    );
  }

  /// `Could not save post`
  String get asset_details_post_save_error {
    return Intl.message(
      'Could not save post',
      name: 'asset_details_post_save_error',
      desc: '',
      args: [],
    );
  }

  /// `Egyptian Exchange`
  String get market_egx {
    return Intl.message(
      'Egyptian Exchange',
      name: 'market_egx',
      desc: '',
      args: [],
    );
  }

  /// `Crypto Market`
  String get market_crypto {
    return Intl.message(
      'Crypto Market',
      name: 'market_crypto',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get market_status_open {
    return Intl.message('Open', name: 'market_status_open', desc: '', args: []);
  }

  /// `Closed`
  String get market_status_closed {
    return Intl.message(
      'Closed',
      name: 'market_status_closed',
      desc: '',
      args: [],
    );
  }

  /// `Add to Watchlist`
  String get watchlist_add {
    return Intl.message(
      'Add to Watchlist',
      name: 'watchlist_add',
      desc: '',
      args: [],
    );
  }

  /// `Remove from Watchlist`
  String get watchlist_remove {
    return Intl.message(
      'Remove from Watchlist',
      name: 'watchlist_remove',
      desc: '',
      args: [],
    );
  }

  /// `1D`
  String get range_1d {
    return Intl.message('1D', name: 'range_1d', desc: '', args: []);
  }

  /// `5D`
  String get range_5d {
    return Intl.message('5D', name: 'range_5d', desc: '', args: []);
  }

  /// `1W`
  String get range_1w {
    return Intl.message('1W', name: 'range_1w', desc: '', args: []);
  }

  /// `1M`
  String get range_1m {
    return Intl.message('1M', name: 'range_1m', desc: '', args: []);
  }

  /// `3M`
  String get range_3m {
    return Intl.message('3M', name: 'range_3m', desc: '', args: []);
  }

  /// `6M`
  String get range_6m {
    return Intl.message('6M', name: 'range_6m', desc: '', args: []);
  }

  /// `1Y`
  String get range_1y {
    return Intl.message('1Y', name: 'range_1y', desc: '', args: []);
  }

  /// `5Y`
  String get range_5y {
    return Intl.message('5Y', name: 'range_5y', desc: '', args: []);
  }

  /// `All`
  String get range_all {
    return Intl.message('All', name: 'range_all', desc: '', args: []);
  }

  /// `AI Summary`
  String get asset_details_ai_summary {
    return Intl.message(
      'AI Summary',
      name: 'asset_details_ai_summary',
      desc: '',
      args: [],
    );
  }

  /// `Summarizing...`
  String get asset_details_summarizing {
    return Intl.message(
      'Summarizing...',
      name: 'asset_details_summarizing',
      desc: '',
      args: [],
    );
  }

  /// `No news available for this asset`
  String get asset_details_no_news_available {
    return Intl.message(
      'No news available for this asset',
      name: 'asset_details_no_news_available',
      desc: '',
      args: [],
    );
  }

  /// `Back to news list`
  String get asset_details_back_news {
    return Intl.message(
      'Back to news list',
      name: 'asset_details_back_news',
      desc: '',
      args: [],
    );
  }

  /// `Read Full Article`
  String get asset_details_read_full {
    return Intl.message(
      'Read Full Article',
      name: 'asset_details_read_full',
      desc: '',
      args: [],
    );
  }

  /// `AI News Summary`
  String get asset_details_ai_summary_title {
    return Intl.message(
      'AI News Summary',
      name: 'asset_details_ai_summary_title',
      desc: '',
      args: [],
    );
  }

  /// `AI Generated`
  String get asset_details_ai_generated {
    return Intl.message(
      'AI Generated',
      name: 'asset_details_ai_generated',
      desc: '',
      args: [],
    );
  }

  /// `Latest News`
  String get asset_details_latest_news {
    return Intl.message(
      'Latest News',
      name: 'asset_details_latest_news',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
