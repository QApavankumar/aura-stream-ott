import 'package:flutter/material.dart';
import 'package:aura_stream/models/media_item.dart';
import 'package:aura_stream/theme/aura_theme.dart';

/// Circular genre/studio hub with glowing neon gradient borders
/// and cinematic visuals for Live Sports, Sci-Fi, Anime, Cinema.
class CircularHubItem extends StatelessWidget {
  final StoryHub hub;
  final VoidCallback onTap;

  const CircularHubItem({
    super.key,
    required this.hub,
    required this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'rocket_launch':
        return Icons.rocket_launch_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'movie_creation':
        return Icons.movie_creation_outlined;
      default:
        return Icons.category_rounded;
    }
  }

  Color _parseHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return AuraTheme.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startColor = _parseHex(hub.gradientStart);
    final endColor = _parseHex(hub.gradientEnd);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Outer Glowing Circular Ring
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: startColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(2.5), // Border thickness
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AuraTheme.darkObsidian,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background Image
                      Image.network(
                        hub.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  startColor.withValues(alpha: 0.6),
                                  endColor.withValues(alpha: 0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              _getIconData(hub.iconName),
                              color: Colors.white,
                              size: 26,
                            ),
                          );
                        },
                      ),

                      // Dark Translucent Tint & Icon
                      Container(
                        color: Colors.black.withValues(alpha: 0.38),
                        child: Center(
                          child: Icon(
                            _getIconData(hub.iconName),
                            color: Colors.white,
                            size: 26,
                            shadows: const [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Hub Title
            Text(
              hub.title,
              style: AppTypography.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
