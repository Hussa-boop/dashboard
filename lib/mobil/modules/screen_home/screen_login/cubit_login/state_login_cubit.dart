import 'package:firebase_auth/firebase_auth.dart';
abstract class LoginState {}

class LoginInitial extends LoginState {}
class LoginTogglePasswordState extends LoginState {}
class LoginChangeTabState extends LoginState {}
class LoginLoading extends LoginState {}
class SignLoading extends LoginState {}
class LoginSuccess extends LoginState {
  final User user;

  LoginSuccess(this.user);
}
class SignSuccess extends LoginState {
  final User user;

  SignSuccess(this.user);
}
class LoginSuccessGetData extends LoginState {
  final Map<String, dynamic> user;

  LoginSuccessGetData(this.user);
}
class SignError extends LoginState {
  final String error;

  SignError(this.error);
}class LoginError extends LoginState {
  final String error;

  LoginError(this.error);
}


