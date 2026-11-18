import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/media_item.dart';
import 'supabase_service.dart';

class SupabaseMediaService {
  final SupabaseService _service = SupabaseService.instance;

  SupabaseClient? get _client => _service.client;

  bool get isReady => _service.isReady && _client != null;

  /// Fetch all movies from the Supabase catalog.
  Future<List<Movie>> fetchMovies() async {
    if (!isReady) return [];

    try {
      final response = await _client!.from('movies').select();
      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => _mapJsonToMovie(json)).toList();
    } catch (e) {
      debugPrint('[SupabaseMediaService] fetchMovies error: $e');
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
      progress: progress,
      remainingTime: remainingTime,
    );
  }
}
