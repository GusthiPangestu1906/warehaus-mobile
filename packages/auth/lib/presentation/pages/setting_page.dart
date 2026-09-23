import 'package:auth/presentation/bloc/auth_bloc.dart';
import 'package:auth/presentation/bloc/auth_event.dart';
import 'package:auth/presentation/bloc/auth_state.dart';
import 'package:auth/presentation/components/setting_hero.dart';
import 'package:auth/presentation/components/setting_menu_card.dart';
import 'package:auth/presentation/pages/change_password.dart';
import 'package:auth/presentation/pages/login_page.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool _isLoggingOut = false;

  void _onChangePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ChangePassword()));
  }

  void _handleLogout() {
    setState(() => _isLoggingOut = true);
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is UnauthenticatedState) {
          // Logout sukses — navigasi ke login dan clear seluruh stack
          _goToLogin();
        } else if (state is LogoutErrorState) {
          setState(() => _isLoggingOut = false);
          WHSnackBar.showError(context, 'Logout gagal: ${state.error}');
        }
      },
      // buildWhen: hanya rebuild saat session berubah, bukan saat logout state
      buildWhen: (prev, curr) =>
          curr is AuthenticatedState ||
          (prev is AuthenticatedState && curr is! AuthenticatedState),
      builder: (context, state) {
        // Simpan session dari last AuthenticatedState
        final session = state is AuthenticatedState ? state.session : null;

        if (session == null) {
          // Hanya tampil saat pertama kali load (belum ada session sama sekali)
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: WHAppbar(title: 'Settings'),
          backgroundColor: WHColors.background,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 8,
              children: [
                // icon hero
                SettingHero(
                  fullName: session.fullName,
                  email: session.email,
                  status: session.status,
                ),

                // setting list
                Column(
                  children: [
                    // phone
                    SettingMenuCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      subtitle: session.phoneNumber,
                      isTop: true,
                    ),

                    // warehouse name
                    SettingMenuCard(
                      icon: Icons.warehouse,
                      title: 'Warehouse Name',
                      subtitle: session.warehouseName,
                      isBottom: true,
                    ),

                    const SizedBox(height: 16),

                    // deleted change password
                    // SettingMenuCard(
                    //   icon: Icons.lock,
                    //   title: 'Change Password',
                    //   hasChevron: true,
                    //   onTap: _onChangePassword,
                    // ),
                    const SizedBox(height: 8),

                    // logout — loading hanya pada tombol
                    WHButton(
                      label: _isLoggingOut ? 'Logging out...' : 'Logout',
                      icon: _isLoggingOut
                          ? Icons.hourglass_empty
                          : Icons.logout,
                      backgroundColor: WHColors.error,
                      onPressed: _isLoggingOut ? null : _handleLogout,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
