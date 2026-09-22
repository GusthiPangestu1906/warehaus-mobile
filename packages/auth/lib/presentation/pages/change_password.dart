import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WHAppbar(title: 'Change Password'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              WHTextField(label: 'Old Password', isPassword: true),
              WHTextField(label: 'New Password', isPassword: true),
              WHTextField(label: 'Confirm Password', isPassword: true),
              const SizedBox(height: 24),
              WHButton(
                label: 'Change Password',
                onPressed: () {},
                backgroundColor: WHColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
