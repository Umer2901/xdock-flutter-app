import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:http/http.dart' as http;

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit() : super(ForgotPasswordInitial());

  Future<void> sendEmail({required String email}) async {
    emit(SendingEmail());
    try {
      final response = await http.post(
        Uri.parse(AppHost.resetPasswordEmail),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        emit(EmailSended(email: email));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        emit(
          EmailError(
              error: '${responseData['message']} (${response.statusCode})'),
        );
      }
    } catch (e) {
      emit(
        EmailError(error: 'Failed to fetch data: $e'),
      );
    }
  }

  Future<void> verifyOTP({required String email, required String otp}) async {
    emit(VerifyingOTP());
    try {
      final response = await http.post(
        Uri.parse(AppHost.verifyOTP),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        emit(OTPVerified(email: email, otp: otp));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        emit(
          OTPError(
              error: '${responseData['message']} (${response.statusCode})'),
        );
      }
    } catch (e) {
      emit(
        OTPError(error: 'Failed to fetch data: $e'),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    emit(UpdatingPassword());
    try {
      final response = await http.post(
        Uri.parse(AppHost.resetPassword),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          "email": email,
          "otp": otp,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        emit(PasswordUpdated(
          email: email,
          otp: otp,
          password: password,
          confirmPassword: confirmPassword,
        ));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        emit(
          PasswordError(
              error: '${responseData['message']} (${response.statusCode})'),
        );
      }
    } catch (e) {
      emit(
        PasswordError(error: 'Failed to fetch data: $e'),
      );
    }
  }
}
