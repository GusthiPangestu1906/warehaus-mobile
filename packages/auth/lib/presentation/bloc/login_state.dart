import 'package:equatable/equatable.dart';

enum LoginStatus { initial, loading, success, failure, logoutSuccess }

class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitialState extends LoginState {}

class LoginLoadingState extends LoginState {
  @override
  List<Object?> get props => [];
}

class LoginSubmittedState extends LoginState {
  final String email;
  final String password;

  LoginSubmittedState({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginSuccessState extends LoginState {}

class LoginErrorState extends LoginState {
  final String error;

  LoginErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class LogoutLoadingState extends LoginState {}

class LogoutSuccessState extends LoginState {}

class LogoutErrorState extends LoginState {
  final String error;

  LogoutErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}
