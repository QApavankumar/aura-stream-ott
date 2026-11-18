import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/otp_verification_screen.dart';
import '../../screens/profile/who_is_watching_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/shell/main_app_shell.dart';
import '../../screens/home/home_screen_feed.dart';
import '../../screens/details/movie_detail_screen.dart';
import '../../screens/player/video_player_screen.dart';
import '../../models/media_item.dart';
import '../../screens/explore/live_tv_screen.dart';
import '../../screens/placeholders/downloads_screen.dart';

// Navigator Keys for Root & Shell Branches
final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'rootNav');
final GlobalKey<NavigatorState> shellHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> shellExploreKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellExplore');
final GlobalKey<NavigatorState> shellDownloadsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellDownloads');
final GlobalKey<NavigatorState> shellProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: RouteNames.splash,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Auth Flow: Login & OTP Verification
      GoRoute(
        path: RouteNames.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            parentNavigatorKey: rootNavigatorKey,
            builder: (context, state) => const OtpVerificationScreen(),
          ),
        ],
      ),

      // 3. Profile Selection: "Who's Watching?"
      GoRoute(
        path: RouteNames.whoIsWatching,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WhoIsWatchingScreen(),
      ),

      // 4. Movie / Series Details Screen (Full-Screen Overlay above Bottom Dock)
      GoRoute(
        path: RouteNames.movieDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final item = state.extra is Movie ? state.extra as Movie : null;
          final movieId = state.pathParameters['id'];
          return MovieDetailScreen(
            item: item,
            movieId: movieId,
            onPlayPressed: (movie) {
              context.push(RouteNames.player, extra: movie);
            },
          );
        },
      ),

      // 5. Video Player Screen (Member 1 - Full-Screen Overlay above Bottom Dock)
      GoRoute(
        path: RouteNames.player,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          if (state.extra is Movie) {
            final movie = state.extra as Movie;
            return VideoPlayerScreen(
              streamUrl: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
              title: movie.title,
              subtitle: '${movie.year} • ${movie.rating} • ${movie.genres.isNotEmpty ? movie.genres.first : 'Action'}',
              thumbnailUrl: movie.backdropUrl.isNotEmpty
                  ? movie.backdropUrl
                  : movie.posterUrl,
            );
          }
          return const VideoPlayerScreen();
        },
      ),

      // 6. Main App Shell with StatefulShellRoute for Bottom Dock
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainAppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home Tab (Member 2 Feed)
          StatefulShellBranch(
            navigatorKey: shellHomeKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                builder: (context, state) => HomeScreenFeed(
                  showAppBar: false,
                  onMovieSelected: (movie) {
                    context.push('/movie/${movie.id}', extra: movie);
                  },
                  onPlayMovie: (movie) {
                    context.push(RouteNames.player, extra: movie);
                  },
                ),
              ),
            ],
          ),

          // Branch 1: Live TV & Channels (Explore Tab)
          StatefulShellBranch(
            navigatorKey: shellExploreKey,
            routes: [
              GoRoute(
                path: RouteNames.explore,
                builder: (context, state) => const LiveTvScreen(),
              ),
            ],
          ),

          // Branch 2: Downloads Tab
          StatefulShellBranch(
            navigatorKey: shellDownloadsKey,
            routes: [
              GoRoute(
                path: RouteNames.downloads,
                builder: (context, state) => const DownloadsScreen(),
              ),
            ],
          ),

          // Branch 3: Profile & Settings Tab
          StatefulShellBranch(
            navigatorKey: shellProfileKey,
            routes: [
              GoRoute(
                path: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
