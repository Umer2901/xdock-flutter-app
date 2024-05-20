import 'dart:convert';
import 'package:coldxpress/export.dart';
import 'package:coldxpress/services/user_service.dart';
import 'package:http/http.dart' as http;

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());

  Future<void> check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (token != null && token != '') {
      emit(Authenticated(token: token));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login(
      {required String email,
      required String password,
      required Database database}) async {
    emit(Authenticating());
    try {
      final response = await http.post(
        Uri.parse(AppHost.login),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['access_token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        print(token.toString());
        await UserService(database).fetchAndStore(token);
        emit(Authenticated(token: token));
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        emit(
          AuthenticationError(
              error: '${responseData['error']} (${response.statusCode})'),
        );
      }
    } catch (e) {
      emit(
        AuthenticationError(error: 'Failed to fetch data: $e'),
      );
    }
  }

  Future<void> logout({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse(AppHost.logout),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', '');
        emit(Unauthenticated());
      } else {
        final Map<String, dynamic> responseData = json.decode(response.body);
        emit(
          AuthenticationError(
              error: '${responseData['error']} (${response.statusCode})'),
        );
      }
    } catch (e) {
      emit(
        AuthenticationError(error: 'Failed to logout: $e'),
      );
    }
  }
}
