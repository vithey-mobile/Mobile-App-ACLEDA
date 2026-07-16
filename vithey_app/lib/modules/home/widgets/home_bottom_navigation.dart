import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.usePillHighlight = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool usePillHighlight;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet,
              label: 'Finance',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble,
              label: 'Chat',
              selected: currentIndex == 3,
              onTap: () => onTap(3),
              usePill: usePillHighlight,
            ),
            _NavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.usePill = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool usePill;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : context.appColors.muted;
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(selected ? activeIcon : icon, color: color, size: 22),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );

    final showPill = selected && usePill;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        // The pill adds its own vertical padding; skip the outer vertical
        // padding then so the item still fits the 56px bar without overflow.
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: showPill ? 0 : 6),
        child: showPill
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: child,
              )
            : child,
      ),
    );
  }
}
