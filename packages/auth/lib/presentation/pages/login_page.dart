import 'package:auth/presentation/bloc/login_bloc.dart';
import 'package:auth/presentation/bloc/login_event.dart';
import 'package:auth/presentation/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_ui/core_ui.dart';
import 'package:mobile/presentation/pages/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void handleLogin() {
    final email = emailController.text;
    final password = passwordController.text;

    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );

    setState(() {
      _emailErrorText = null;
      _passwordErrorText = null;
    });

    bool isValid = true;

    // Email validation
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _emailErrorText = 'Invalid email';
      });
      isValid = false;
    }

    if (email.isEmpty) {
      setState(() {
        _emailErrorText = 'Email is required';
      });
      isValid = false;
    }

    // Password validation
    if (password.isEmpty) {
      setState(() {
        _passwordErrorText = 'Password is required';
      });
      isValid = false;
    }

    if (isValid) {
      context.read<LoginBloc>().add(
        LoginSubmitted(email: email, password: password),
      );
    }
  }

  // register website launcher
  final Uri registerUrl = Uri.parse('https://gudang-cloud.vercel.app/register');

  Future<void> launchFrontend() async {
    try {
      await launchUrl(registerUrl, mode: LaunchMode.externalApplication);
    } catch (err) {
      WHSnackBar.showError(context, "Failed to open register page");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder<void>(
              pageBuilder: (_, __, ___) => const MainPage(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            (route) => false,
          );
        } else if (state is LoginErrorState) {
          WHSnackBar.showError(context, state.error);
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                spacing: 0,
                children: [
                  // icon + text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icon/app_icon.png',
                        width: 48,
                        height: 48,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Ware',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: WHColors.primary,
                                ),
                              ),
                              Text(
                                'Haus',
                                style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: WHColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Warehouse Management System',
                            style: WHTypography.caption,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 44),

                  // text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Masuk ke Akun', style: WHTypography.heading1),
                      const SizedBox(height: 4),
                      Text(
                        'Masukkan email dan kata sandi untuk mengakses sistem.',
                        style: WHTypography.caption,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // form
                  Column(
                    spacing: 16,
                    children: [
                      // email
                      WHTextField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        errorText: _emailErrorText,
                      ),

                      // password
                      WHTextField(
                        label: 'Password',
                        hintText: 'Enter your password',
                        controller: passwordController,
                        isPassword: true,
                        errorText: _passwordErrorText,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // button
                  WHButton(
                    label: 'Login',
                    backgroundColor: WHColors.secondary,
                    onPressed: handleLogin,
                  ),

                  const SizedBox(height: 16),

                  // text register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun gudang? ',
                        style: WHTypography.caption,
                      ),
                      InkWell(
                        onTap: launchFrontend,
                        child: Text(
                          'Daftar Sebagai Owner',
                          style: WHTypography.caption.copyWith(
                            color: WHColors.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
