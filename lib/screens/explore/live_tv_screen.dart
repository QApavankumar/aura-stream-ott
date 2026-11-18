import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/route_names.dart';
import '../../models/live_tv_channel.dart';
import '../../models/media_item.dart';
import '../../services/live_tv_service.dart';
import '../../widgets/feed/soundwave_visualizer.dart';

class LiveTvScreen extends StatefulWidget {
  const LiveTvScreen({super.key});

  @override
  State<LiveTvScreen> createState() => _LiveTvScreenState();
}

class _LiveTvScreenState extends State<LiveTvScreen> {
  late List<LiveChannel> _allChannels;
  String _selectedCategory = 'All Channels';
  String _searchQuery = '';
  late LiveChannel _activeChannel;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _allChannels = LiveTvService.getChannels();
    _activeChannel = _allChannels.first;
  }

  List<LiveChannel> get _filteredChannels {
    return _allChannels.where((ch) {
      final matchesCategory = _selectedCategory == 'All Channels' ||
          ch.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          _selectedCategory.toLowerCase().contains(ch.category.toLowerCase());
      final matchesSearch = _searchQuery.isEmpty ||
          ch.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ch.number.contains(_searchQuery) ||
          (ch.currentProgram?.title.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _tuneChannel(LiveChannel channel) {
    setState(() {
      _activeChannel = channel;
    });
  }

  void _watchFullscreen(LiveChannel channel) {
    final prog = channel.currentProgram;
    final movie = Movie(
      id: channel.id,
      title: '${channel.name}: ${prog?.title ?? "Live Stream"}',
      synopsis: prog?.description ?? 'Broadcasting live in 4K UHD with Dolby Atmos.',
      backdropUrl: channel.logoUrl,
      posterUrl: channel.logoUrl,
      genres: [channel.category, 'Live TV'],
      rating: '10.0',
      year: '2026',
      duration: 'Live',
      maturityRating: prog?.maturityRating ?? 'All',
      badge: '🔴 LIVE 4K UHD',
    );

    try {
      context.push(RouteNames.player, extra: movie);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceDark,
          content: Text('Tuning into ${channel.name}...'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeProgram = _activeChannel.currentProgram;

    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header & Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'LIVE TV & CHANNELS',
                                  style: AppTypography.brandLogo(fontSize: 20, letterSpacing: 1.5),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.liveRed,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.liveRed.withOpacity(0.6),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    '4K UHD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Over 200+ premium live feeds with real-time EPG scheduling',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        // Quick Guide Refresh Button
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: AppColors.cyanPrimary, size: 22),
                          onPressed: () {
                            setState(() {
                              _allChannels = LiveTvService.getChannels();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.surfaceDark,
                                duration: const Duration(milliseconds: 900),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: AppColors.cyanPrimary, width: 0.8),
                                ),
                                content: const Text('Live EPG guide updated with current feeds!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Pill
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(21),
                        border: Border.all(color: Colors.white.withOpacity(0.16)),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        cursorColor: AppColors.cyanPrimary,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.cyanPrimary, size: 20),
                          hintText: 'Search channel name, number, or program title...',
                          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6), fontSize: 12.5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Category Filter Pills Row
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: LiveTvService.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final cat = LiveTvService.categories[index];
                    final isSelected = cat == _selectedCategory;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isSelected
                              ? AppColors.cyanPrimary.withOpacity(0.18)
                              : Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: isSelected ? AppColors.cyanPrimary : Colors.white.withOpacity(0.14),
                            width: 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.cyanPrimary.withOpacity(0.35),
                                    blurRadius: 10,
                                    spreadRadius: -1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? AppColors.cyanPrimary : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 3. Featured Spotlight Live Stream Banner (Picture-in-Picture Preview)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSpotlightPlayer(context, _activeChannel, activeProgram),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // 4. Quick Channels Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tuned Channels (${_filteredChannels.length})',
                      style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 115,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredChannels.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final ch = _filteredChannels[index];
                    final isCurrent = ch.id == _activeChannel.id;

                    return GestureDetector(
                      onTap: () => _tuneChannel(ch),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 160,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isCurrent
                              ? const Color(0xFF141F32)
                              : AppColors.cardSurface,
                          border: Border.all(
                            color: isCurrent ? AppColors.cyanPrimary : Colors.white.withOpacity(0.12),
                            width: isCurrent ? 1.8 : 1.0,
                          ),
                          boxShadow: [
                            if (isCurrent)
                              BoxShadow(
                                color: AppColors.cyanPrimary.withOpacity(0.3),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'CH ${ch.number}',
                                  style: TextStyle(
                                    color: isCurrent ? AppColors.cyanPrimary : AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.liveRed,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              ch.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 12, color: AppColors.cyanPrimary),
                                const SizedBox(width: 4),
                                Text(
                                  '${ch.currentViewers} watching',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // 5. Electronic Program Guide (EPG) Schedule Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Electronic Program Guide (EPG)',
                          style: AppTypography.titleLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cyanPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Live Timeline',
                              style: TextStyle(color: AppColors.cyanPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Time scale indicator bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: Text(
                              'CHANNEL',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('10:00 AM', style: TextStyle(color: AppColors.cyanPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                                Text('11:00 AM', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                Text('12:00 PM', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                Text('01:00 PM', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 10)),

            // 6. EPG Schedule Rows
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ch = _filteredChannels[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: _buildEpgChannelRow(ch),
                  );
                },
                childCount: _filteredChannels.length,
              ),
            ),

            // Bottom clearance for floating frosted dock
            const SliverToBoxAdapter(
              child: SizedBox(height: 130),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotlightPlayer(BuildContext context, LiveChannel channel, LiveProgram? program) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cyanPrimary.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyanPrimary.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop broadcast image
            Image.network(
              channel.logoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.live_tv_rounded, color: AppColors.cyanPrimary, size: 50),
                ),
              ),
            ),

            // Vignette Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Top Status Bar in Spotlight
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.liveRed.withOpacity(0.7),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'LIVE FEED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            color: Colors.black.withOpacity(0.4),
                            child: Text(
                              'CH ${channel.number} • ${channel.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Mute / Unmute & Fullscreen icons
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _isMuted = !_isMuted),
                      ),
                      IconButton(
                        icon: const Icon(Icons.fullscreen_rounded, color: AppColors.cyanPrimary, size: 24),
                        onPressed: () => _watchFullscreen(channel),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Content & Actions
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    program?.title ?? 'Live Feed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program?.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.9),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Live Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: program?.progress ?? 0.5,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyanPrimary),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${program?.startTime ?? ''} - ${program?.endTime ?? ''}',
                        style: const TextStyle(color: AppColors.cyanPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons Row
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyanPrimary,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                        ),
                        onPressed: () => _watchFullscreen(channel),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text(
                          'Tune In Live',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surfaceDark,
                              content: Text('Audio stream: Dolby Atmos 5.1 set for ${channel.name}'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.surround_sound_rounded, size: 16, color: AppColors.cyanPrimary),
                        label: const Text('Dolby Atmos', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEpgChannelRow(LiveChannel channel) {
    final isSelected = channel.id == _activeChannel.id;
    final currentProg = channel.currentProgram;
    final upcomingProg = channel.schedule.length > 1 ? channel.schedule[1] : null;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF111827) : const Color(0xFF0C101A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.cyanPrimary.withOpacity(0.6) : Colors.white.withOpacity(0.08),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Left: Channel Brand Column
          GestureDetector(
            onTap: () => _tuneChannel(channel),
            child: Container(
              width: 140,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.cyanPrimary.withOpacity(0.12) : Colors.white.withOpacity(0.02),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                border: Border(
                  right: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: channel.themeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: channel.themeColor, width: 0.8),
                        ),
                        child: Text(
                          channel.number,
                          style: TextStyle(
                            color: channel.themeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isSelected)
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: SoundwaveVisualizer(
                            barCount: 4,
                            height: 12,
                            primaryColor: AppColors.cyanPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    channel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right: Programs Timeline
          Expanded(
            child: Row(
              children: [
                // Current Program (takes 60% of row)
                if (currentProg != null)
                  Expanded(
                    flex: 6,
                    child: GestureDetector(
                      onTap: () {
                        _tuneChannel(channel);
                        _watchFullscreen(channel);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.cyanPrimary.withOpacity(0.12) : Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.cyanPrimary.withOpacity(0.4) : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.liveRed,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('NOW', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    currentProg.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentProg.startTime} - ${currentProg.endTime} • ${currentProg.resolution}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 9.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Upcoming Program (takes 40% of row)
                if (upcomingProg != null)
                  Expanded(
                    flex: 4,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceDark,
                            behavior: SnackBarBehavior.floating,
                            content: Text('Reminder set for "${upcomingProg.title}" on ${channel.name} at ${upcomingProg.startTime}'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              upcomingProg.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              upcomingProg.startTime,
                              style: const TextStyle(color: AppColors.cyanPrimary, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
