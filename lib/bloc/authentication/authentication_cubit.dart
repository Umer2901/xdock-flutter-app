import 'dart:convert';
import 'dart:io';
import 'package:coldxpress/export.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationInitial());

  Future<void> check(Database database) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        await onStart(database, token);
      } catch (e) {
        debugPrint('Error: $e');
      }
    }

    await Future.delayed(
      const Duration(milliseconds: 800),
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
        await onStart(database, token);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
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

  Future<void> onStart(Database database, String token) async {
    try {
      await InternetAddress.lookup('google.com').then((value) async {
        try {
          await PreCheckDatabase(database, accessToken: token)
              .read()
              .then((submissions) async {
            if (submissions.isEmpty) {
              try {
                await PrecheckStatusService(
                  database,
                ).fetchAndStore(token);
              } catch (e) {
                debugPrint("Not Connected to Network");
              }
            }
          }).whenComplete(() {
            ConsignmentService(database).fetchAndStore(token);
          });
        } catch (e) {
          debugPrint('My Error: $e');
        }
      });
    } on SocketException catch (e) {
      throw Exception('No Internet ($e)');
    } catch (e) {
      throw Exception('Something went wrong! ($e)');
    }
    Connectivity().onConnectivityChanged.listen((event) async {
      try {
        if (event.contains(ConnectivityResult.wifi) ||
            event.contains(ConnectivityResult.mobile)) {
          await InternetAddress.lookup('google.com').then((value) async {
            try {
              await PreCheckDatabase(database, accessToken: token)
                  .read()
                  .then((submissions) async {
                if (submissions.isEmpty) {
                  try {
                    await PrecheckStatusService(
                      database,
                    ).fetchAndStore(token);
                  } catch (e) {
                    debugPrint("Not Connected to Network");
                  }
                }
              }).whenComplete(() {
                ConsignmentService(database).fetchAndStore(token);
              });
            } catch (e) {
              debugPrint('My Error: $e');
            }
          });
        }
      } on SocketException catch (e) {
        throw Exception('No Internet ($e)');
      } catch (e) {
        throw Exception('Something went wrong! ($e)');
      }
    });
  }

  Future<void> logout(
      {required Database database, required String token}) async {
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
        await UserDatabase(database, accessToken: token).delete();
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
