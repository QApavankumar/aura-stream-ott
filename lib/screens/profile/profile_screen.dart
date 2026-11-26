import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/common/frosted_glass.dart';
import '../../widgets/common/aura_glow_button.dart';
import '../../widgets/dialogs/kids_pin_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _qualityIndex = 0;
  final List<String> _qualityOptions = ['Auto 4K HDR', '1080p FHD', 'Data Saver'];

  int _selectedMaturityIndex = 3;
  final List<String> _maturityRatings = ['All (G)', '13+ (PG-13)', '16+ (TV-14)', '18+ (TV-MA)'];

  bool _spatialAudio = true;
  bool _autoPlayNext = true;
  bool _autoPlayPreviews = false;
  bool _hardwareAcceleration = true;
  String _cacheSize = '1.42 GB';

  // Connected Devices Mock Data
  final List<Map<String, String>> _connectedDevices = [
    {
      'name': 'Sony Bravia XR OLED 65"',
      'type': 'Living Room TV • 4K HDR Stream',
      'lastActive': 'Active Now',
      'icon': 'tv',
    },
    {
      'name': 'Apple iPad Pro 12.9" M2',
      'type': 'Tablet • 4 Offline Downloads',
      'lastActive': '2 hours ago',
      'icon': 'tablet',
    },
    {
      'name': 'Samsung Galaxy S25 Ultra',
      'type': 'Mobile • Cellular Stream',
      'lastActive': 'Yesterday',
      'icon': 'phone',
    },
  ];

  void _showDevicesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F131D),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.glassBorderCyan, width: 1.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Active Devices',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_connectedDevices.length} of 5 Concurrent Streams In Use',
                            style: TextStyle(color: AppColors.cyanPrimary, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._connectedDevices.map((device) {
                    IconData iconData = Icons.tv_rounded;
                    if (device['icon'] == 'tablet') iconData = Icons.tablet_mac_rounded;
                    if (device['icon'] == 'phone') iconData = Icons.smartphone_rounded;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorder, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          Icon(iconData, color: AppColors.cyanPrimary, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device['name']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${device['type']} • ${device['lastActive']}',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                _connectedDevices.remove(device);
                              });
                              setState(() {});
                            },
                            child: const Text('Revoke', style: TextStyle(color: AppColors.error, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      setSheetState(() {
                        _connectedDevices.clear();
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.phonelink_erase_rounded, color: AppColors.error, size: 18),
                    label: const Text('Sign Out of All Other Devices', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearCache() {
    setState(() {
      _cacheSize = '0 MB';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.success, width: 1.0),
        ),
        content: const Row(
          children: [
            Icon(Icons.cleaning_services_rounded, color: AppColors.success, size: 20),
            SizedBox(width: 10),
            Text('Playback Cache & Render Shaders Cleared!', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final activeProfile = profileProvider.activeProfile;
    final isDesktop = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, isDesktop ? 84 : 16, 24, 130),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP APP BAR HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACCOUNT & HARDWARE',
                            style: AppTypography.badge.copyWith(
                              color: AppColors.cyanPrimary,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Profile & Settings',
                            style: AppTypography.h2.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => context.go(RouteNames.whoIsWatching),
                        icon: const Icon(Icons.switch_account_rounded, color: AppColors.cyanPrimary, size: 24),
                        tooltip: "Switch Profile",
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // --- ACTIVE PROFILE HERO CARD ---
                  FrostedGlass(
                    borderRadius: 24,
                    blur: 20,
                    backgroundColor: AppColors.surfaceDark.withOpacity(0.8),
                    border: Border.all(color: AppColors.glassBorderCyan, width: 1.2),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: activeProfile?.themeColor ?? AppColors.cardSurface,
                            border: Border.all(
                              color: AppColors.glassBorderBright,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            activeProfile?.isKids == true
                                ? Icons.sentiment_satisfied_alt_rounded
                                : Icons.person_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    activeProfile?.name ?? 'Alex R.',
                                    style: AppTypography.h3.copyWith(fontSize: 19, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(width: 8),
                                  if (activeProfile?.isKids == true)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.kidsModeAmber,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'KIDS',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.cardSurface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.glassBorderBright, width: 0.8),
                                      ),
                                      child: const Text(
                                        'VIP ULTRA',
                                        style: TextStyle(
                                          color: AppColors.noirSilver,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9.5,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.currentUser?.identifier ?? '+1 (555) 019-2834',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activeProfile?.contentRating ?? '4K Ultra HD • All Access Pass',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.cyanPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Switch profile button
                        ElevatedButton.icon(
                          onPressed: () => context.go(RouteNames.whoIsWatching),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyanPrimary.withOpacity(0.15),
                            foregroundColor: AppColors.cyanPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.sync_alt_rounded, size: 16),
                          label: const Text('Switch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- VIP SUBSCRIPTION HUB CARD ---
                  FrostedGlass(
                    borderRadius: 20,
                    blur: 14,
                    backgroundColor: AppColors.surfaceDark,
                    border: Border.all(color: AppColors.glassBorder, width: 1.0),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cardSurface,
                                    border: Border.all(color: AppColors.glassBorderBright),
                                  ),
                                  child: const Icon(Icons.workspace_premium_rounded, color: AppColors.noirWhite, size: 19),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Aura Infinite 4K VIP Pass',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'Renews Oct 28, 2027 • Dolby Atmos Included',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.success, width: 0.8),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.glassBorder, height: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.devices_rounded, color: AppColors.cyanPrimary, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '${_connectedDevices.length} of 5 Concurrent Streams In Use',
                                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: _showDevicesSheet,
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Text(
                                  'Manage Devices',
                                  style: TextStyle(
                                    color: AppColors.cyanPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- SECTION 1: STREAMING & AUDIO HARDWARE MASTER CONSOLE ---
                  _buildSectionTitle('STREAMING & HARDWARE CONSOLE', AppColors.cyanPrimary),
                  const SizedBox(height: 12),

                  // Streaming Quality Segmented Pill Selector
                  FrostedGlass(
                    borderRadius: 18,
                    blur: 14,
                    backgroundColor: AppColors.surfaceDark.withOpacity(0.6),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.hd_rounded, color: AppColors.cyanPrimary, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Default Streaming Quality',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _qualityOptions.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final isSelected = _qualityIndex == index;
                              return InkWell(
                                onTap: () => setState(() => _qualityIndex = index),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: isSelected
                                        ? AppColors.cyanPrimary
                                        : AppColors.cardSurface.withOpacity(0.8),
                                    border: Border.all(
                                      color: isSelected ? AppColors.cyanPrimary : AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Text(
                                    _qualityOptions[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Spatial Audio & Dolby Atmos Toggle
                  _buildSwitchTile(
                    icon: Icons.surround_sound_rounded,
                    title: 'Dolby Atmos & Spatial Audio 7.1.4',
                    subtitle: 'Binaural soundstage calibration for high-end headphones & soundbars',
                    value: _spatialAudio,
                    onChanged: (val) {
                      setState(() => _spatialAudio = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surfaceDark,
                          behavior: SnackBarBehavior.floating,
                          content: Text(val ? 'Dolby Atmos 7.1.4 Enabled' : 'Spatial Audio Disabled'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),

                  // Hardware Acceleration
                  _buildSwitchTile(
                    icon: Icons.speed_rounded,
                    title: 'Hardware Acceleration (HEVC / AV1)',
                    subtitle: 'Uses GPU rendering for silky smooth 60 FPS 4K HDR playback',
                    value: _hardwareAcceleration,
                    onChanged: (val) => setState(() => _hardwareAcceleration = val),
                  ),

                  // Auto-Play Next Episode
                  _buildSwitchTile(
                    icon: Icons.skip_next_rounded,
                    title: 'Auto-Play Next Episode',
                    subtitle: 'Automatically plays subsequent episodes at the end credits',
                    value: _autoPlayNext,
                    onChanged: (val) => setState(() => _autoPlayNext = val),
                  ),

                  // Auto-Play Audio Previews
                  _buildSwitchTile(
                    icon: Icons.volume_up_rounded,
                    title: 'Auto-Play Previews with Audio',
                    subtitle: 'Play sound while browsing trailers in the catalog',
                    value: _autoPlayPreviews,
                    onChanged: (val) => setState(() => _autoPlayPreviews = val),
                  ),

                  const SizedBox(height: 28),

                  // --- SECTION 2: PARENTAL SECURITY & MATURITY FILTER ---
                  _buildSectionTitle('PARENTAL CONTROLS & CONTENT RATINGS', AppColors.kidsModeAmber),
                  const SizedBox(height: 12),

                  // Maturity Rating Level Selector Chips
                  FrostedGlass(
                    borderRadius: 18,
                    blur: 14,
                    backgroundColor: AppColors.surfaceDark.withOpacity(0.6),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield_rounded, color: AppColors.kidsModeAmber, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Maturity Content Restriction',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _maturityRatings.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final isSelected = _selectedMaturityIndex == index;
                              return InkWell(
                                onTap: () => setState(() => _selectedMaturityIndex = index),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? AppColors.kidsModeAmber
                                        : AppColors.cardSurface.withOpacity(0.8),
                                    border: Border.all(
                                      color: isSelected ? AppColors.kidsModeAmber : AppColors.glassBorder,
                                    ),
                                  ),
                                  child: Text(
                                    _maturityRatings[index],
                                    style: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white,
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Kids PIN Lock Switch
                  _buildSwitchTile(
                    icon: Icons.pin_rounded,
                    title: 'Kids Mode 4-Digit PIN Lock',
                    subtitle: profileProvider.isKidsPinEnabled
                        ? 'PIN is required to switch away from Kids Profile (Demo: 1234)'
                        : 'Disabled (Anyone can exit kids mode)',
                    value: profileProvider.isKidsPinEnabled,
                    accentColor: AppColors.kidsModeAmber,
                    onChanged: (val) async {
                      if (!val) {
                        final success = await KidsPinDialog.show(
                          context,
                          title: 'Disable PIN',
                          expectedPin: profileProvider.kidsPin,
                        );
                        if (success) {
                          profileProvider.updateKidsPinSettings(isEnabled: false);
                        }
                      } else {
                        profileProvider.updateKidsPinSettings(isEnabled: true);
                      }
                    },
                  ),

                  const SizedBox(height: 28),

                  // --- SECTION 3: APP STORAGE & CACHE CLEANER ---
                  _buildSectionTitle('DATA & LOCAL STORAGE', AppColors.neonPurple),
                  const SizedBox(height: 12),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: FrostedGlass(
                      borderRadius: 18,
                      blur: 14,
                      backgroundColor: AppColors.surfaceDark.withOpacity(0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.cleaning_services_rounded, color: AppColors.neonPurple, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Clear Cache & Shaders',
                                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_cacheSize stored locally • Frees space without removing downloads',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _clearCache,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.neonPurple,
                            ),
                            child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- SECTION 4: ACCOUNT ACTIONS & SIGN OUT ---
                  _buildSectionTitle('ACCOUNT ACTIONS', AppColors.textMuted),
                  const SizedBox(height: 12),

                  AuraGlowButton(
                    label: 'Switch Profile ("Who\'s Watching?")',
                    icon: Icons.switch_account_rounded,
                    isSecondary: true,
                    onPressed: () => context.go(RouteNames.whoIsWatching),
                  ),
                  const SizedBox(height: 12),
                  AuraGlowButton(
                    label: 'Sign Out of Aura Stream',
                    icon: Icons.logout_rounded,
                    isSecondary: true,
                    glowColor: AppColors.error,
                    onPressed: () {
                      authProvider.logout();
                      profileProvider.clearActiveProfile();
                      context.go(RouteNames.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color accent) {
    return Text(
      title,
      style: AppTypography.badge.copyWith(
        color: accent,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color accentColor = AppColors.cyanPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: FrostedGlass(
        borderRadius: 16,
        blur: 14,
        backgroundColor: AppColors.surfaceDark.withOpacity(0.6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: accentColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
