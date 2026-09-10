import 'package:flutter/material.dart';

import '../colors.dart';

/// Model data untuk satu item tab di bottom navigation bar.
class WHBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const WHBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class WHBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<WHBottomNavItem> items;
  final Function(int) onTap;

  const WHBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              return _buildNavItem(item: items[index], index: index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required WHBottomNavItem item,
    required int index,
  }) {
    final bool isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTap(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? item.activeIcon : item.icon,
            color: isSelected ? WHColors.secondary3 : WHColors.grey3,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? WHColors.secondary3 : WHColors.grey3,
            ),
          ),
        ],
      ),
    );
  }
}
