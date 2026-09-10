import 'package:auth/presentation/bloc/login_bloc.dart';
import 'package:auth/presentation/bloc/login_event.dart';
import 'package:auth/presentation/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_ui/core_ui.dart';

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
    if (email.isEmpty) {
      setState(() {
        _emailErrorText = 'Email is required';
      });
      isValid = false;
    }

    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _emailErrorText = 'Invalid email';
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginErrorState) {
          WHSnackBar.showError(context, state.error);
        }
      },
      child: Scaffold(
        backgroundColor: WHColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // image
              Image.asset('assets/images/login_page_top.png'),

              // form
              Column(
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

              // button
              WHButton(
                label: 'Login',
                backgroundColor: WHColors.secondary,
                onPressed: handleLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
