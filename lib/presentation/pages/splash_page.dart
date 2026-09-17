import 'package:auth/presentation/bloc/login_bloc.dart';
import 'package:auth/presentation/bloc/login_event.dart';
import 'package:auth/presentation/bloc/login_state.dart';
import 'package:auth/presentation/pages/login_page.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/presentation/pages/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _versionLabel = 'Version 2.0.1';

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
      // Dispatch pengecekan auth setelah splash terlihat
      context.read<LoginBloc>().add(CheckAuthRequested());
    });
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainPage(),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          _goToMain();
        } else if (state is UnauthenticatedState) {
          _goToLogin();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: WHColors.surface,
          systemNavigationBarColor: WHColors.surface,
        ),
        child: Scaffold(
          backgroundColor: WHColors.surface,
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 136,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 28,
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 520),
                    curve: Curves.easeOutCubic,
                    child: Text(
                      _versionLabel,
                      textAlign: TextAlign.center,
                      style: WHTypography.caption.copyWith(
                        color: WHColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
