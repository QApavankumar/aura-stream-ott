import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum HubType { icon, textBadge, storyBubbleCapsule, storyAvatar }

class ModernHubItem {
  final String id;
  final String label;
  final String? subtitle;
  final HubType type;
  final IconData? icon;
  final String? badgeText;
  final String? imageUrl;
  final Color glowColor;

  const ModernHubItem({
    required this.id,
    required this.label,
    this.subtitle,
    required this.type,
    this.icon,
    this.badgeText,
    this.imageUrl,
    this.glowColor = AppColors.noirWhite,
  });
}

/// Clean Apple TV+ / Noir horizontal category pill bar (replaces cluttered story bubbles).
class ModernCategoryHub extends StatefulWidget {
  final List<ModernHubItem> items;
  final String? selectedId;
  final ValueChanged<ModernHubItem>? onSelect;

  const ModernCategoryHub({
    super.key,
    required this.items,
    this.selectedId,
    this.onSelect,
  });

  @override
  State<ModernCategoryHub> createState() => _ModernCategoryHubState();
}

class _ModernCategoryHubState extends State<ModernCategoryHub> {
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.selectedId;
  }

  @override
  void didUpdateWidget(covariant ModernCategoryHub oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      _selectedId = widget.selectedId;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final isSelected = _selectedId == item.id;
          final isLive = item.id.toLowerCase().contains('live') ||
              item.label.toLowerCase().contains('live');

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedId = item.id);
                widget.onSelect?.call(item);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.noirWhite
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.noirWhite
                        : AppColors.glassBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.liveRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                    ] else if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 15,
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
