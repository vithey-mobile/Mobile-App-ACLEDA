import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.usePillHighlight = false,
    this.floating = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool usePillHighlight;
  final bool floating;

  @override
  Widget build(BuildContext context) {
    final navigation = Material(
      color: context.appColors.cardSurface,
      elevation: floating ? 8 : 2,
      shadowColor: context.appColors.subtleShadow,
      borderRadius: floating ? BorderRadius.circular(30) : BorderRadius.zero,
      child: SizedBox(
        height: 58,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Home',
              selected: currentIndex == 0,
              onTap: () => onTap(0),
              highlightIcon: floating,
            ),
            _NavItem(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet,
              label: 'Finance',
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            if (floating)
              _CreateNavItem(onTap: () => onTap(2))
            else
              const Expanded(child: SizedBox()),
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

    if (!floating) {
      return BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: navigation,
      );
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: navigation,
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
    this.highlightIcon = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool usePill;
  final bool highlightIcon;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : context.appColors.muted;
    final icon = Icon(
      selected ? activeIcon : this.icon,
      color: color,
      size: 21,
    );
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (selected && highlightIcon)
          Container(
            width: 29,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: icon,
          )
        else
          SizedBox(height: 29, child: Center(child: icon)),
        Text(label, style: TextStyle(fontSize: 10.5, color: color)),
      ],
    );

    final showPill = selected && usePill;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          // The pill adds its own vertical padding; skip the outer vertical
          // padding then so the item still fits the 56px bar without overflow.
          padding:
              EdgeInsets.symmetric(horizontal: 12, vertical: showPill ? 0 : 6),
          child: showPill
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}

class _CreateNavItem extends StatelessWidget {
  const _CreateNavItem({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Transform.translate(
          offset: const Offset(0, -8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: context.scheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_circle_outline_rounded,
                  color: context.scheme.onPrimary,
                  size: 21,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Create',
                style: TextStyle(
                  color: context.appColors.muted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
