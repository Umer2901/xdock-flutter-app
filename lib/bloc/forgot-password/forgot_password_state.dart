part of 'forgot_password_cubit.dart';

@immutable
sealed class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class SendingEmail extends ForgotPasswordState {}

final class EmailSended extends ForgotPasswordState {
  final String email;

  EmailSended({required this.email});
}

final class VerifyingOTP extends ForgotPasswordState {}

final class OTPVerified extends ForgotPasswordState {
  final String email;
  final String otp;

  OTPVerified({
    required this.email,
    required this.otp,
  });
}

final class UpdatingPassword extends ForgotPasswordState {}

final class PasswordUpdated extends ForgotPasswordState {
  final String email;
  final String otp;
  final String password;
  final String confirmPassword;

  PasswordUpdated({
    required this.email,
    required this.otp,
    required this.password,
    required this.confirmPassword,
  });
}

final class EmailError extends ForgotPasswordState {
  final String error;

  EmailError({required this.error});
}

final class OTPError extends ForgotPasswordState {
  final String error;

  OTPError({required this.error});
}

final class PasswordError extends ForgotPasswordState {
  final String error;

  PasswordError({required this.error});
}
