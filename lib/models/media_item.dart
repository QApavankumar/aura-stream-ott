library;

/// Cast member profile for Movie & Episode credits.
class CastMember {
  final String name;
  final String character;
  final String avatarUrl;

  const CastMember({
    required this.name,
    required this.character,
    required this.avatarUrl,
  });

  factory CastMember.fromJson(Map<String, dynamic> json) {
    return CastMember(
      name: json['name'] as String? ?? 'Actor',
      character: json['character'] as String? ?? 'Role',
      avatarUrl: json['avatarUrl'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'character': character,
        'avatarUrl': avatarUrl,
      };
}

/// Episode model for serialized shows.
class Episode {
  final int episodeNumber;
  final String title;
  final String duration;
  final String synopsis;
  final String thumbnailUrl;

  const Episode({
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.synopsis,
    required this.thumbnailUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episodeNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Episode',
      duration: json['duration'] as String? ?? '45m',
      synopsis: json['synopsis'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }
}

/// Season model holding episodes.
class Season {
  final int seasonNumber;
  final String seasonTitle;
  final List<Episode> episodes;

  const Season({
    required this.seasonNumber,
    required this.seasonTitle,
    required this.episodes,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['seasonNumber'] as int? ?? 1,
      seasonTitle: json['seasonTitle'] as String? ?? 'Season 1',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Circular Story Hub item (Studios, Franchises, Live Channels).
class StoryHub {
  final String id;
  final String title;
  final String iconName;
  final String gradientStart;
  final String gradientEnd;
  final String imageUrl;

  const StoryHub({
    required this.id,
    required this.title,
    required this.iconName,
    required this.gradientStart,
    required this.gradientEnd,
    required this.imageUrl,
  });

  factory StoryHub.fromJson(Map<String, dynamic> json) {
    return StoryHub(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'movie',
      gradientStart: json['gradientStart'] as String? ?? '#00F2FE',
      gradientEnd: json['gradientEnd'] as String? ?? '#9D4EDD',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}

/// Backward compatibility alias for Member 2 code.
typedef HubItem = StoryHub;

/// Primary content entity (Movie, Series, Live Title).
class Movie {
  final String id;
  final String title;
  final String synopsis;
  final String backdropUrl;
  final String posterUrl;
  final List<String> genres;
  final String rating;
  final String year;
  final String maturityRating;
  final String duration;
  final int? rank;
  final double? progress;
  final String? episodeLabel;
  final String? remainingTime;
  final String? badge;
  final List<Season> seasons;
  final List<CastMember> cast;

  const Movie({
    required this.id,
    required this.title,
    required this.synopsis,
    required this.backdropUrl,
    required this.posterUrl,
    required this.genres,
    required this.rating,
    required this.year,
    required this.maturityRating,
    required this.duration,
    this.rank,
    this.progress,
    this.episodeLabel,
    this.remainingTime,
    this.badge,
    this.seasons = const [],
    this.cast = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      backdropUrl: json['backdropUrl'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
      rating: json['rating'] as String? ?? '8.0',
      year: json['year'] as String? ?? '2026',
      maturityRating: json['maturityRating'] as String? ?? '16+',
      duration: json['duration'] as String? ?? '1h 45m',
      rank: json['rank'] as int?,
      progress: (json['progress'] as num?)?.toDouble(),
      episodeLabel: json['episodeLabel'] as String?,
      remainingTime: json['remainingTime'] as String?,
      badge: json['badge'] as String?,
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((s) => Season.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      cast: (json['cast'] as List<dynamic>?)
              ?.map((c) => CastMember.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Backward compatibility alias for Member 2 code.
typedef MediaItem = Movie;

/// Category rail representing horizontal lists of movies (e.g. Trending Now, Action & Sci-Fi).
class Category {
  final String id;
  final String title;
  final String? subtitle;
  final List<Movie> movies;

  const Category({
    required this.id,
    required this.title,
    this.subtitle,
    required this.movies,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      movies: (json['movies'] as List<dynamic>?)
              ?.map((m) => Movie.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Full feed data parsed from mock_data.json.
class HomeFeedData {
  final Movie hero;
  final List<Movie> featuredHeroes;
  final List<StoryHub> hubs;
  final List<Movie> continueWatching;
  final List<Movie> top10;
  final List<Category> categories;

  const HomeFeedData({
    required this.hero,
    this.featuredHeroes = const [],
    required this.hubs,
    required this.continueWatching,
    required this.top10,
    this.categories = const [],
  });

  factory HomeFeedData.fromJson(Map<String, dynamic> json) {
    final hero = Movie.fromJson(json['hero'] as Map<String, dynamic>);
    final featuredHeroes = (json['featuredHeroes'] as List<dynamic>?)
            ?.map((h) => Movie.fromJson(h as Map<String, dynamic>))
            .toList() ??
        [hero];

    return HomeFeedData(
      hero: hero,
      featuredHeroes: featuredHeroes,
      hubs: (json['hubs'] as List<dynamic>?)
              ?.map((h) => StoryHub.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      continueWatching: (json['continueWatching'] as List<dynamic>?)
              ?.map((c) => Movie.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      top10: (json['top10'] as List<dynamic>?)
              ?.map((t) => Movie.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)
              ?.map((cat) => Category.fromJson(cat as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
