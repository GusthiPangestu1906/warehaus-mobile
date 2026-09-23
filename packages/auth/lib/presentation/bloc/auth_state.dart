import 'package:auth/domain/entities/user_session.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginInitialState extends AuthState {}

class LoginLoadingState extends AuthState {
  @override
  List<Object?> get props => [];
}

class LoginSubmittedState extends AuthState {
  final String email;
  final String password;

  LoginSubmittedState({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LoginSuccessState extends AuthState {}

class LoginErrorState extends AuthState {
  final String error;

  LoginErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class LogoutLoadingState extends AuthState {}

class LogoutSuccessState extends AuthState {}

class LogoutErrorState extends AuthState {
  final String error;

  LogoutErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

class AuthCheckLoadingState extends AuthState {}

class AuthenticatedState extends AuthState {
  final UserSession session;

  AuthenticatedState({required this.session});

  @override
  List<Object?> get props => [session];
}

class UnauthenticatedState extends AuthState {}
