import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

enum FlowType { inbound, outbound }

class FlowTabContent extends StatelessWidget {
  final FlowType type;
  final List<Widget> items;

  const FlowTabContent({
    super.key,
    required this.type,
    this.items = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return WHEmptyState(
        message: type == FlowType.inbound
            ? 'No inbound orders yet.\nTap + to create.'
            : 'No outbound orders yet.\nTap + to create.',
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }
}
