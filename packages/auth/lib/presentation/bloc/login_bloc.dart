import 'package:auth/domain/usecase/login.dart';
import 'package:auth/domain/usecase/logout.dart';
import 'package:auth/presentation/bloc/login_event.dart';
import 'package:auth/presentation/bloc/login_state.dart';
import 'package:core_services/interceptors/error/app_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final Login loginUsecase;
  final Logout logoutUsecase;

  LoginBloc({required this.loginUsecase, required this.logoutUsecase})
    : super(LoginInitialState()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoadingState());
      try {
        await loginUsecase(email: event.email, password: event.password);
        emit(LoginSuccessState());
      } catch (e) {
        emit(LoginErrorState(error: AppErrorHandler.extractMessage(e)));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(LogoutLoadingState());
      try {
        await logoutUsecase();
        emit(LogoutSuccessState());
      } catch (e) {
        emit(LogoutErrorState(error: AppErrorHandler.extractMessage(e)));
      }
    });
  }
}
