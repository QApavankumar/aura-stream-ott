import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'dock_item.dart';

class FloatingFrostedDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<DockItemData> items;

  const FloatingFrostedDock({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: bottomPadding > 0 ? bottomPadding + 6 : 18,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: AppColors.cyanPrimary.withOpacity(0.2),
                blurRadius: 28,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xB80E1422),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (index) {
                    final item = items[index];
                    final isSelected = index == currentIndex;

                    return _DockTabButton(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => onTabSelected(index),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockTabButton extends StatelessWidget {
  final DockItemData item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockTabButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isSelected
                ? AppColors.cyanPrimary.withOpacity(0.15)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: AppColors.cyanPrimary.withOpacity(0.5),
                    width: 1.0,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.cyanPrimary.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 21,
                color: isSelected ? AppColors.cyanPrimary : Colors.white60,
              ),
              if (isSelected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 12,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: AppColors.cyanPrimary,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyanPrimary.withOpacity(0.9),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
