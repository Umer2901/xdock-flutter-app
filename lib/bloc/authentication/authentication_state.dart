part of 'authentication_cubit.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

final class Authenticating extends AuthenticationState {}

final class Authenticated extends AuthenticationState {
  final String token;

  Authenticated({required this.token});
}

final class Unauthenticated extends AuthenticationState {}

final class AuthenticationError extends AuthenticationState {
  final String error;

  AuthenticationError({required this.error});
}
