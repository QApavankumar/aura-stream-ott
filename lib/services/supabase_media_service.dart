import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';
import '../widgets/feed/modern_hero_banner.dart';
import '../widgets/feed/live_match_card.dart';
import '../widgets/feed/popular_4k_card.dart';
import 'supabase_service.dart';

class SupabaseMediaService {
  final SupabaseService _service = SupabaseService.instance;

  SupabaseClient? get _client => _service.client;

  bool get isReady => _service.isReady && _client != null;

  /// Stream changes to the movies table for real-time live synchronization.
  Stream<List<Map<String, dynamic>>>? watchMovies() {
    if (!isReady) return null;
    try {
      return _client!.from('movies').stream(primaryKey: ['id']);
    } catch (e) {
      debugPrint('[SupabaseMediaService] watchMovies error: $e');
      return null;
    }
  }

  /// Fetch all movies from the Supabase catalog.
  Future<List<Movie>> fetchMovies() async {
    if (!isReady) return [];

    try {
      final response = await _client!
          .from('movies')
          .select()
          .order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => _mapJsonToMovie(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchMovies error: $e');
      return [];
    }
  }

  /// Fetch dynamic Hero items for the Top Hero Banner from Supabase.
  Future<List<ModernHeroItem>> fetchHeroItems() async {
    if (!isReady) return [];

    try {
      var response = await _client!
          .from('movies')
          .select()
          .eq('is_hero', true)
          .order('created_at', ascending: false);

      var List<dynamic> data = response as List<dynamic>;
      // If no movies explicitly flagged is_hero, grab first available titles
      if (data.isEmpty) {
        response = await _client!
            .from('movies')
            .select()
            .order('created_at', ascending: false)
            .limit(3);
        data = response as List<dynamic>;
      }

      if (data.isEmpty) return [];

      return data.map((json) {
        return ModernHeroItem(
          id: json['id'] as String? ?? 'hero',
          title: json['title'] as String? ?? 'Untitled',
          subtitle: json['synopsis'] as String? ?? '',
          badgeText: json['badge'] as String? ?? 'LIVE PREMIERE',
          formatInfo: '4K Ultra HD • Dolby Atmos',
          imageUrl: json['backdrop_url'] as String? ?? json['poster_url'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchHeroItems error: $e');
      return [];
    }
  }

  /// Fetch Rail 1: Live Channels & Matches from Supabase.
  Future<List<LiveMatchItem>> fetchLiveMatches() async {
    if (!isReady) return [];

    try {
      final response = await _client!
          .from('movies')
          .select()
          .eq('is_live_match', true)
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) return [];

      return data.map((json) {
        final title = json['title'] as String? ?? 'Live Match';
        final isRed = title.toLowerCase().contains('premier') || title.toLowerCase().contains('finals');

        return LiveMatchItem(
          id: json['id'] as String? ?? 'match',
          title: title,
          subtitle: json['synopsis'] as String? ?? 'Live Broadcast',
          imageUrl: json['backdrop_url'] as String? ?? json['poster_url'] as String? ?? '',
          isRedBadge: isRed,
          statusText: 'LIVE',
          channel: 'Aura Sport 4K',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchLiveMatches error: $e');
      return [];
    }
  }

  /// Fetch Rail 2: Popular in 4K UHD from Supabase.
  Future<List<Popular4kItem>> fetchPopular4k() async {
    if (!isReady) return [];

    try {
      var response = await _client!
          .from('movies')
          .select()
          .eq('is_popular_4k', true)
          .order('rating', ascending: false);

      var List<dynamic> data = response as List<dynamic>;
      // Fallback: If no movies are flagged is_popular_4k, return any movies in catalog
      if (data.isEmpty) {
        response = await _client!
            .from('movies')
            .select()
            .order('created_at', ascending: false)
            .limit(10);
        data = response as List<dynamic>;
      }

      if (data.isEmpty) return [];

      return data.map((json) {
        return Popular4kItem(
          id: json['id'] as String? ?? 'pop',
          title: json['title'] as String? ?? 'Untitled',
          subtitle: json['synopsis'] as String? ?? '4K Ultra HD',
          tag: json['badge'] as String? ?? '4K HDR',
          imageUrl: json['poster_url'] as String? ?? json['backdrop_url'] as String? ?? '',
          rating: json['rating'] as String? ?? '9.5',
          year: json['year'] as String? ?? '2026',
        );
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchPopular4k error: $e');
      return [];
    }
  }

  /// Fetch Top 10 movies ordered by rating.
  Future<List<Movie>> fetchTop10() async {
    if (!isReady) return [];

    try {
      final response = await _client!
          .from('movies')
          .select()
          .order('rating', ascending: false)
          .limit(10);

      final List<dynamic> data = response as List<dynamic>;
      return data.asMap().entries.map((entry) {
        final index = entry.key;
        final json = entry.value as Map<String, dynamic>;
        return _mapJsonToMovie(json, rank: index + 1);
      }).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchTop10 error: $e');
      return [];
    }
  }

  /// Filter movies by genre from Supabase.
  Future<List<Movie>> fetchMoviesByGenre(String genre) async {
    if (!isReady) return [];

    try {
      final response = await _client!
          .from('movies')
          .select()
          .contains('genres', [genre]);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => _mapJsonToMovie(json)).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchMoviesByGenre error: $e');
      return [];
    }
  }

  /// Check if a movie is bookmarked in My List.
  Future<bool> isMovieInWatchlist({
    required String profileId,
    required String movieId,
  }) async {
    if (!isReady) return false;

    try {
      final response = await _client!
          .from('watchlist')
          .select('id')
          .eq('profile_id', profileId)
          .eq('movie_id', movieId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('[SupabaseMediaService] isMovieInWatchlist error: $e');
      return false;
    }
  }

  /// Toggle a movie in My List (inserts if not present, deletes if present).
  Future<bool> toggleWatchlist({
    required String profileId,
    required String movieId,
  }) async {
    if (!isReady) return false;

    try {
      final userId = _client!.auth.currentUser?.id;
      final isSaved = await isMovieInWatchlist(
        profileId: profileId,
        movieId: movieId,
      );

      if (isSaved) {
        await _client!
            .from('watchlist')
            .delete()
            .eq('profile_id', profileId)
            .eq('movie_id', movieId);
        return false; // Removed
      } else {
        await _client!.from('watchlist').insert({
          'user_id': userId,
          'profile_id': profileId,
          'movie_id': movieId,
        });
        return true; // Added
      }
    } catch (e) {
      debugPrint('[SupabaseMediaService] toggleWatchlist error: $e');
      return false;
    }
  }

  /// Save playback progress for cross-device "Continue Watching".
  Future<void> saveWatchProgress({
    required String profileId,
    required String movieId,
    required double progress,
    required String remainingTime,
  }) async {
    if (!isReady) return;

    try {
      final userId = _client!.auth.currentUser?.id;
      await _client!.from('watch_history').upsert({
        'user_id': userId,
        'profile_id': profileId,
        'movie_id': movieId,
        'progress': progress,
        'remaining_time': remainingTime,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'profile_id,movie_id');
    } catch (e) {
      debugPrint('[SupabaseMediaService] saveWatchProgress error: $e');
    }
  }

  /// Fetch all "Continue Watching" items for the active profile.
  Future<List<Movie>> fetchContinueWatching({required String profileId}) async {
    if (!isReady) return [];

    try {
      final response = await _client!
          .from('watch_history')
          .select('progress, remaining_time, movies(*)')
          .eq('profile_id', profileId)
          .order('updated_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      final List<Movie> list = [];

      for (final item in data) {
        final movieData = item['movies'] as Map<String, dynamic>?;
        if (movieData != null) {
          final movie = _mapJsonToMovie(
            movieData,
            progress: (item['progress'] as num?)?.toDouble(),
            remainingTime: item['remaining_time'] as String?,
          );
          list.add(movie);
        }
      }

      return list;
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchContinueWatching error: $e');
      return [];
    }
  }

  Movie _mapJsonToMovie(
    Map<String, dynamic> json, {
    double? progress,
    String? remainingTime,
    int? rank,
  }) {
    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List).map((g) => g.toString()).toList();
    }

    return Movie(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      synopsis: json['synopsis'] as String? ?? '',
      backdropUrl: json['backdrop_url'] as String? ?? '',
      posterUrl: json['poster_url'] as String? ?? '',
      genres: parsedGenres,
      rating: json['rating'] as String? ?? '9.0',
      year: json['year'] as String? ?? '2026',
      maturityRating: json['maturity_rating'] as String? ?? '16+',
      duration: json['duration'] as String? ?? '2h 15m',
      badge: json['badge'] as String?,
      rank: rank,
      progress: progress,
      remainingTime: remainingTime,
    );
  }
}
