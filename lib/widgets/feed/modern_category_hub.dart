import 'dart:ui';
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
    this.type = HubType.icon,
    this.icon,
    this.badgeText,
    this.imageUrl,
    this.glowColor = AppColors.cyanPrimary,
  });
}

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
    _selectedId = widget.selectedId ?? (widget.items.isNotEmpty ? widget.items.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Category / Channel Hub',
            style: AppTypography.titleLarge.copyWith(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal Hubs List
        SizedBox(
          height: 98,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = item.id == _selectedId;

              return _HubItemWidget(
                item: item,
                isSelected: isSelected,
                onTap: () {
                  setState(() => _selectedId = item.id);
                  widget.onSelect?.call(item);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HubItemWidget extends StatefulWidget {
  final ModernHubItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _HubItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_HubItemWidget> createState() => _HubItemWidgetState();
}

class _HubItemWidgetState extends State<_HubItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final bool active = widget.isSelected || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hub Graphic Container
            Transform.translate(
              offset: Offset(0.0, active ? -3.0 : 0.0),
              child: _buildGraphic(item, active),
            ),
            const SizedBox(height: 7),

            // Label
            Text(
              item.label,
              style: AppTypography.badge.copyWith(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? item.glowColor : AppColors.textSecondary,
                letterSpacing: 0.1,
              ),
            ),
            if (item.subtitle != null) ...[
              const SizedBox(height: 1.5),
              Text(
                item.subtitle!,
                style: const TextStyle(
                  fontSize: 9.0,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGraphic(ModernHubItem item, bool active) {
    // 1. Story Bubble Capsule (e.g. avatar on left + pill text on right)
    if (item.type == HubType.storyBubbleCapsule) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: const Color(0xFF101624),
          border: Border.all(
            color: active ? item.glowColor : Colors.white.withOpacity(0.2),
            width: active ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (active)
              BoxShadow(
                color: item.glowColor.withOpacity(0.4),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular Avatar Thumbnail
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1A2234),
              ),
              child: ClipOval(
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.play_circle_fill_rounded,
                          color: AppColors.cyanPrimary,
                          size: 22,
                        ),
                      )
                    : const Icon(Icons.movie_rounded, color: Colors.white70, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            // Tag Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: item.glowColor.withOpacity(0.18),
                border: Border.all(color: item.glowColor, width: 1.0),
              ),
              child: Text(
                item.badgeText ?? '',
                style: TextStyle(
                  color: item.glowColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      );
    }

    // 2. Standard Circular Hub (Icon, Text Badge, or Avatar)
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF101624),
        border: Border.all(
          color: active ? item.glowColor : Colors.white.withOpacity(0.18),
          width: active ? 2.0 : 1.2,
        ),
        boxShadow: [
          if (active)
            BoxShadow(
              color: item.glowColor.withOpacity(0.4),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildCircleContent(item, active),
      ),
    );
  }

  Widget _buildCircleContent(ModernHubItem item, bool active) {
    switch (item.type) {
      case HubType.icon:
        return Center(
          child: Icon(
            item.icon ?? Icons.category_rounded,
            size: 23,
            color: active ? item.glowColor : Colors.white70,
          ),
        );

      case HubType.textBadge:
        return Center(
          child: Text(
            item.badgeText ?? 'HUB',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: active ? item.glowColor : Colors.white,
            ),
          ),
        );

      case HubType.storyAvatar:
      case HubType.storyBubbleCapsule:
        if (item.imageUrl != null) {
          return Image.network(
            item.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.person_rounded, color: item.glowColor, size: 24),
            ),
          );
        }
        return Center(
          child: Icon(Icons.person_rounded, color: item.glowColor, size: 24),
        );
    }
  }
}
