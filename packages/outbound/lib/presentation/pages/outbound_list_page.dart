import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class OutboundListPage extends StatelessWidget {
  const OutboundListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WHColors.background,
      appBar: const WHAppbar(title: 'Outbound'),
      body: const Center(
        child: WHEmptyState(
          message: 'No outbound orders yet.\nTap + to create a Sales Order.',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: WHColors.primary3,
        child: const Icon(Icons.add, color: WHColors.surface),
      ),
    );
  }
}
