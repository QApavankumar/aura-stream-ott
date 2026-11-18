import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/media_item.dart';

class MockDataService {
  static HomeFeedData? _cachedData;

  /// Loads the full home feed from assets/data/mock_data.json
  /// (with fallback to assets/mock_data.json and in-memory mock catalog).
  static Future<HomeFeedData> loadHomeFeed() async {
    if (_cachedData != null) return _cachedData!;

    try {
      String jsonString;
      try {
        jsonString = await rootBundle.loadString('assets/data/mock_data.json');
      } catch (_) {
        jsonString = await rootBundle.loadString('assets/mock_data.json');
      }

      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      _cachedData = HomeFeedData.fromJson(data);
      return _cachedData!;
    } catch (e) {
      // Graceful fallback to default in-memory feed if asset is temporarily inaccessible
      _cachedData = _createFallbackData();
      return _cachedData!;
    }
  }

  static void invalidateCache() {
    _cachedData = null;
  }

  static HomeFeedData _createFallbackData() {
    const defaultCast = [
      CastMember(
        name: 'Takeshi Kaneshiro',
        character: 'Det. Ren Vance',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      ),
      CastMember(
        name: 'Elena Rostova',
        character: 'Aura AI / Nexus-9',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      ),
      CastMember(
        name: 'Marcus Vance',
        character: 'Director Vance',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      ),
      CastMember(
        name: 'Aoi Miyazaki',
        character: 'Special Agent Hana',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      ),
    ];

    const hero = Movie(
      id: 'hero_01',
      title: 'CYBERPUNK: NEO HORIZON',
      synopsis: 'In the submerged megacity of Neo-Bangkok, a rogue synthetics detective unravels a corporate conspiracy.',
      backdropUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=1280&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600&q=80',
      genres: ['Sci-Fi', 'Cyberpunk', 'Action'],
      rating: '9.6',
      year: '2026',
      maturityRating: '18+',
      duration: '2h 35m',
      badge: 'STREAMING NOW IN 4K HDR',
      cast: defaultCast,
    );

    const movieQuantum = Movie(
      id: 'top_01',
      title: 'Quantum Singularity',
      synopsis: 'A team of theoretical physicists accidentally open a stable microscopic wormhole in the Swiss Alps.',
      backdropUrl: 'https://images.unsplash.com/photo-1506703719100-a0f3a48c0f86?w=1080&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=600&q=80',
      genres: ['Sci-Fi', 'Thriller'],
      rating: '9.8',
      year: '2026',
      maturityRating: '16+',
      duration: '2h 42m',
      badge: 'CRITICALLY ACCLAIMED #1',
      rank: 1,
      cast: defaultCast,
    );

    const movieRonin = Movie(
      id: 'top_02',
      title: 'Blade of the Ronin',
      synopsis: 'In feudal Japan intertwined with supernatural tech, an exiled swordsman wields an ancient plasma katana.',
      backdropUrl: 'https://images.unsplash.com/photo-1514539079130-25950c84af65?w=1080&q=80',
      posterUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=600&q=80',
      genres: ['Action', 'Anime', 'Fantasy'],
      rating: '9.4',
      year: '2025',
      maturityRating: '18+',
      duration: '1h 58m',
      badge: 'GLOBAL BLOCKBUSTER PREMIERE',
      rank: 2,
      cast: defaultCast,
    );

    final hubs = [
      const StoryHub(
        id: 'hub_sports',
        title: 'Live Sports',
        iconName: 'sports_soccer',
        gradientStart: '#00F2FE',
        gradientEnd: '#0072FF',
        imageUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=300&q=80',
      ),
      const StoryHub(
        id: 'hub_scifi',
        title: 'Sci-Fi',
        iconName: 'rocket_launch',
        gradientStart: '#9D4EDD',
        gradientEnd: '#EC4899',
        imageUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=300&q=80',
      ),
      const StoryHub(
        id: 'hub_anime',
        title: 'Anime',
        iconName: 'auto_awesome',
        gradientStart: '#F43F5E',
        gradientEnd: '#FB923C',
        imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300&q=80',
      ),
      const StoryHub(
        id: 'hub_cinema',
        title: 'Cinema',
        iconName: 'movie_creation',
        gradientStart: '#00F2FE',
        gradientEnd: '#9D4EDD',
        imageUrl: 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?w=300&q=80',
      ),
    ];

    const continueWatching = [
      Movie(
        id: 'cw_01',
        title: 'Orbital Descent',
        episodeLabel: 'S1 : E4 • The Void Protocol',
        progress: 0.72,
        remainingTime: '18m remaining',
        backdropUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&q=80',
        posterUrl: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=600&q=80',
        genres: ['Sci-Fi', 'Suspense'],
        rating: '8.9',
        year: '2025',
        maturityRating: '16+',
        duration: '54m',
        synopsis: 'As the station breaches atmospheric equilibrium, Dr. Vance races against thermal cascade failure.',
        cast: defaultCast,
      ),
      Movie(
        id: 'cw_02',
        title: 'Chrono Drift: Tokyo',
        episodeLabel: 'S2 : E1 • Neon Velocity',
        progress: 0.45,
        remainingTime: '32m remaining',
        backdropUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&q=80',
        posterUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=600&q=80',
        genres: ['Action', 'Sci-Fi'],
        rating: '9.1',
        year: '2026',
        maturityRating: '16+',
        duration: '58m',
        synopsis: 'Midnight racers discover an experimental hyper-drive chip that warps local spacetime.',
        cast: defaultCast,
      ),
    ];

    const top10 = [
      movieQuantum,
      movieRonin,
    ];

    final categories = [
      const Category(
        id: 'cat_trending',
        title: 'Trending Now',
        subtitle: 'Most popular picks across all universes',
        movies: [movieQuantum, movieRonin, hero],
      ),
      const Category(
        id: 'cat_action_scifi',
        title: 'Action & Sci-Fi',
        subtitle: 'High-octane synth futures and interstellar thrillers',
        movies: [hero, movieQuantum, movieRonin],
      ),
    ];

    return HomeFeedData(
      hero: hero,
      featuredHeroes: const [hero, movieQuantum, movieRonin],
      hubs: hubs,
      continueWatching: continueWatching,
      top10: top10,
      categories: categories,
    );
  }
}
