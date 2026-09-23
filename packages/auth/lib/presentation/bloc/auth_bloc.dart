import 'package:auth/domain/usecase/check_auth.dart';
import 'package:auth/domain/usecase/login.dart';
import 'package:auth/domain/usecase/logout.dart';
import 'package:auth/presentation/bloc/auth_event.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:core_services/interceptors/error/app_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login loginUsecase;
  final Logout logoutUsecase;
  final CheckAuth checkAuthUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.logoutUsecase,
    required this.checkAuthUsecase,
  }) : super(LoginInitialState()) {
    on<CheckAuthRequested>((event, emit) async {
      emit(AuthCheckLoadingState());
      final result = await checkAuthUsecase();
      result.fold(
        (_) => emit(UnauthenticatedState()),
        (session) => session != null
            ? emit(AuthenticatedState(session: session))
            : emit(UnauthenticatedState()),
      );
    });

    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await loginUsecase(email: event.email, password: event.password);
        final result = await checkAuthUsecase();
        result.fold(
          (failure) => emit(LoginErrorState(error: failure.message)),
          (session) => session != null
              ? emit(AuthenticatedState(session: session))
              : emit(LoginErrorState(error: 'Sesi tidak ditemukan.')),
        );
      } catch (e) {
        emit(LoginErrorState(error: AppErrorHandler.extractMessage(e)));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(LogoutLoadingState());
      try {
        await logoutUsecase();
        emit(LogoutSuccessState());
        emit(UnauthenticatedState());
      } catch (e) {
        emit(LogoutErrorState(error: AppErrorHandler.extractMessage(e)));
      }
    });
  }
}
