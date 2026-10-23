// Model JSON dipisahkan dari antarmuka agar mudah dipelajari dan diuji.
class Game {
  final int id;
  final String title, thumbnail, shortDescription, genre, platform;
  final String publisher, developer, releaseDate, gameUrl;

  const Game({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.shortDescription,
    required this.genre,
    required this.platform,
    required this.publisher,
    required this.developer,
    required this.releaseDate,
    required this.gameUrl,
  });

  factory Game.fromJson(Map<String, dynamic> json) => Game(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String? ?? 'Tanpa judul',
    thumbnail: json['thumbnail'] as String? ?? '',
    shortDescription: json['short_description'] as String? ?? '',
    genre: json['genre'] as String? ?? 'Lainnya',
    platform: json['platform'] as String? ?? '',
    publisher: json['publisher'] as String? ?? '',
    developer: json['developer'] as String? ?? '',
    releaseDate: json['release_date'] as String? ?? '',
    gameUrl: json['game_url'] as String? ?? '',
  );
}

class GameDetail {
  final Game game;
  final String description, status;
  final Map<String, String> requirements;
  final List<String> screenshots;

  const GameDetail({
    required this.game,
    required this.description,
    required this.status,
    required this.requirements,
    required this.screenshots,
  });

  factory GameDetail.fromJson(Map<String, dynamic> json) {
    final rawRequirements = json['minimum_system_requirements'];
    final rawScreenshots = json['screenshots'];
    return GameDetail(
      game: Game.fromJson(json),
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      requirements: rawRequirements is Map
          ? rawRequirements.map(
              (key, value) => MapEntry(
                key.toString(),
                value?.toString() ?? 'Tidak tersedia',
              ),
            )
          : {},
      screenshots: rawScreenshots is List
          ? rawScreenshots
                .whereType<Map>()
                .map((item) => item['image'])
                .whereType<String>()
                .where((url) => url.isNotEmpty)
                .toList()
          : [],
    );
  }
}
