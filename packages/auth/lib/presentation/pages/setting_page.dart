import 'package:auth/presentation/bloc/login_event.dart';
import 'package:auth/presentation/components/setting_hero.dart';
import 'package:auth/presentation/components/setting_menu_card.dart';
import 'package:auth/presentation/bloc/login_bloc.dart';
import 'package:auth/presentation/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:core_ui/core_ui.dart';
import 'package:auth/presentation/pages/change_password.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void onChangePassword(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ChangePassword()));
  }

  void handleLogout(BuildContext context) async {
    context.read<LoginBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WHAppbar(title: 'Settings'),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LogoutSuccessState) {
            Navigator.of(context).pop();
          }

          if (state is LogoutErrorState) {
            WHSnackBar.showError(context, 'Logout gagal');
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final session = state is AuthenticatedState ? state.session : null;

            if (session == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              spacing: 32,
              children: [
                // icon hero
                SettingHero(
                  fullName: session.fullName,
                  email: session.email,
                  status: session.status,
                ),

                // setting list
                Column(
                  spacing: 24,
                  children: [
                    // phone
                    SettingMenuCard(
                      icon: Icons.phone,
                      title: 'Phone Number',
                      subtitle: session.phoneNumber,
                    ),

                    // warehouse name
                    SettingMenuCard(
                      icon: Icons.warehouse,
                      title: 'Warehouse Name',
                      subtitle: session.warehouseName,
                    ),

                    // change password
                    SettingMenuCard(
                      icon: Icons.lock,
                      title: 'Change Password',
                      hasChevron: true,
                      onTap: () => onChangePassword(context),
                    ),

                    // logout
                    SettingMenuCard(
                      icon: Icons.logout,
                      title: 'Logout',
                      isDanger: true,
                      onTap: () => handleLogout(context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
