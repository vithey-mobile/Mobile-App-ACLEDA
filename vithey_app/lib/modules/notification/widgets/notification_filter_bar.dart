import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _segmentWidth = 76.0;
  static const _segmentHeight = 34.0;

  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = NotificationFilter.values.indexOf(selected);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: _segmentWidth * NotificationFilter.values.length,
          height: _segmentHeight,
          child: Stack(
            children: [
              // Sliding thumb behind the labels.
              AnimatedAlign(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  -1 +
                      selectedIndex *
                          (2 / (NotificationFilter.values.length - 1)),
                  0,
                ),
                child: Container(
                  width: _segmentWidth,
                  height: _segmentHeight,
                  decoration: BoxDecoration(
                    color: context.scheme.primary,
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: context.scheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final filter in NotificationFilter.values)
                    _FilterSegment(
                      label: switch (filter) {
                        NotificationFilter.all => 'All',
                        NotificationFilter.read => 'Read',
                        NotificationFilter.unread => 'Unread',
                      },
                      selected: filter == selected,
                      onTap: () => onSelected(filter),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSegment extends StatelessWidget {
  const _FilterSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(17),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  color: selected
                      ? context.scheme.onPrimary
                      : context.appColors.muted,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
