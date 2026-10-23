import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/game.dart';
import '../services/game_api.dart';
import '../widgets/shared.dart';

class HomePage extends StatefulWidget {
  final GameApi api;

  const HomePage({super.key, required this.api});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Palet Iced Watercolor.
  static const _purple = Color(0xFF45496A);
  static const _blueGrey = Color(0xFF7D8BAE);
  static const _coral = Color(0xFFE5857B);
  static const _pink = Color(0xFFF1B2B2);
  static const _blush = Color(0xFFE8CCC7);
  static const _secondaryText = Color(0xFF555B73);

  final _search = TextEditingController();

  late Future<List<Game>> _future;

  String _query = '';
  String _genre = 'Semua';
  String _platform = 'Semua platform';
  String _sort = 'Terbaru';

  bool get _isSearching =>
      _query.trim().isNotEmpty ||
      _genre != 'Semua' ||
      _platform != 'Semua platform';

  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchGames();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final next = widget.api.fetchGames();

    setState(() {
      _future = next;
    });

    try {
      await next;
    } catch (_) {
      // Kesalahan ditampilkan oleh FutureBuilder.
    }
  }

  void _openDetail(Game game) {
    FocusScope.of(context).unfocus();

    Navigator.pushNamed(context, '/detail', arguments: game.id);
  }

  void _resetFilters() {
    _search.clear();

    setState(() {
      _query = '';
      _genre = 'Semua';
      _platform = 'Semua platform';
      _sort = 'Terbaru';
    });
  }

  List<Game> _filter(List<Game> source) {
    final query = _query.trim().toLowerCase();

    final result = source.where((game) {
      final matchesTitle = game.title.toLowerCase().contains(query);

      final matchesGenre = _genre == 'Semua' || game.genre == _genre;

      final platform = game.platform.toLowerCase();

      final matchesPlatform =
          _platform == 'Semua platform' ||
          (_platform == 'PC' && platform.contains('pc')) ||
          (_platform == 'Browser' && platform.contains('browser'));

      return matchesTitle && matchesGenre && matchesPlatform;
    }).toList();

    result.sort((a, b) {
      if (_sort == 'Terbaru') {
        final dateOrder = b.releaseDate.compareTo(a.releaseDate);

        if (dateOrder != 0) {
          return dateOrder;
        }
      }

      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: FutureBuilder<List<Game>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _purple),
                );
              }

              if (snapshot.hasError) {
                return StatusPanel(
                  message: snapshot.error.toString(),
                  retry: _reload,
                );
              }

              final allGames = snapshot.data ?? [];

              if (allGames.isEmpty) {
                return StatusPanel(
                  message: 'Belum ada game dari server.',
                  retry: _reload,
                );
              }

              final genres = allGames.map((game) => game.genre).toSet().toList()
                ..sort();

              final games = _filter(allGames);

              // Pilihan dari hasil API, bukan peringkat popularitas.
              final featured = games.take(6).toList();

              return RefreshIndicator(
                color: _purple,
                backgroundColor: Colors.white,
                onRefresh: _reload,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(allGames.length)),

                    SliverToBoxAdapter(child: _buildCategories(genres)),

                    if (!_isSearching && featured.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: _sectionTitle(
                          'Pilihan Game',
                          subtitle: 'Geser untuk menjelajah',
                        ),
                      ),
                      SliverToBoxAdapter(child: _buildFeatured(featured)),
                    ],

                    SliverToBoxAdapter(
                      child: _buildListHeading(games.length, allGames.length),
                    ),

                    if (games.isEmpty)
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const StatusPanel(
                              message:
                                  'Game tidak ditemukan. Coba judul atau kategori lain.',
                              icon: Icons.search_off,
                            ),
                            TextButton.icon(
                              onPressed: _resetFilters,
                              icon: const Icon(
                                Icons.restart_alt,
                                color: _purple,
                              ),
                              label: const Text(
                                'Reset pencarian dan filter',
                                style: TextStyle(color: _purple),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.builder(
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          return _buildGameCard(games[index]);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 24),
                        child: Center(child: SourceCredit()),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: const BoxDecoration(
        color: _purple,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: _pink,
                child: Icon(Icons.sports_esports_rounded, color: _purple),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'GameFinder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang',
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Selamat datang!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jelajahi $total game gratis untuk PC dan browser.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _search,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              FocusScope.of(context).unfocus();
            },
            style: const TextStyle(color: _purple),
            cursorColor: _purple,
            decoration: InputDecoration(
              hintText: 'Mau cari game apa?',
              hintStyle: const TextStyle(color: _secondaryText),
              prefixIcon: const Icon(Icons.search_rounded, color: _blueGrey),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close_rounded, color: _purple),
                      onPressed: () {
                        _search.clear();

                        setState(() {
                          _query = '';
                        });
                      },
                    ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _pink, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<String> genres) {
    final categories = ['Semua', ...genres];
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final extraHeight = textScale > 1 ? (textScale - 1) * 36 : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: SizedBox(
        height: 108 + extraHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, index) {
            return const SizedBox(width: 10);
          },
          itemBuilder: (context, index) {
            final genre = categories[index];
            final selected = _genre == genre;

            return SizedBox(
              width: 78,
              child: Semantics(
                button: true,
                selected: selected,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    setState(() {
                      _genre = genre;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: selected ? _coral : _pink,
                            borderRadius: BorderRadius.circular(17),
                            border: Border.all(
                              color: selected ? _purple : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _genreIcon(genre),
                            color: _purple,
                            size: 27,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          genre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _purple,
                            fontSize: 11,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _genreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'semua':
        return Icons.apps_rounded;

      case 'shooter':
        return Icons.gps_fixed_rounded;

      case 'racing':
        return Icons.sports_motorsports_rounded;

      case 'strategy':
        return Icons.psychology_rounded;

      case 'sports':
        return Icons.sports_soccer_rounded;

      case 'fighting':
        return Icons.sports_mma_rounded;

      case 'mmorpg':
        return Icons.groups_rounded;

      case 'rpg':
      case 'arpg':
      case 'action rpg':
        return Icons.auto_fix_high_rounded;

      case 'action':
        return Icons.bolt_rounded;

      case 'card':
      case 'card game':
        return Icons.style_rounded;

      case 'moba':
        return Icons.shield_rounded;

      case 'battle royale':
        return Icons.radar_rounded;

      default:
        return Icons.sports_esports_rounded;
    }
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _purple,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: _secondaryText, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatured(List<Game> games) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return SizedBox(
      height: 220 + (textScale > 1 ? (textScale - 1) * 70 : 0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: games.length,
        separatorBuilder: (_, index) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (context, index) {
          final game = games[index];

          return SizedBox(
            width: 250,
            child: Card(
              margin: EdgeInsets.zero,
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: _blush),
              ),
              child: InkWell(
                onTap: () => _openDetail(game),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GameImage(game.thumbnail),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                      child: Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _purple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Text(
                        game.genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListHeading(int count, int total) {
    final title = _isSearching
        ? 'Hasil Pencarian'
        : _sort == 'Terbaru'
        ? 'Game Terbaru'
        : 'Daftar Game';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _purple,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count dari $total game',
            style: const TextStyle(color: _secondaryText, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<String>(
                initialValue: _platform,
                tooltip: 'Pilih platform',
                color: Colors.white,
                onSelected: (value) {
                  setState(() {
                    _platform = value;
                  });
                },
                itemBuilder: (_) {
                  return ['Semua platform', 'PC', 'Browser']
                      .map(
                        (value) => PopupMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList();
                },
                child: _filterBadge(Icons.devices_rounded, _platform),
              ),
              PopupMenuButton<String>(
                initialValue: _sort,
                tooltip: 'Urutkan game',
                color: Colors.white,
                onSelected: (value) {
                  setState(() {
                    _sort = value;
                  });
                },
                itemBuilder: (_) {
                  return ['Terbaru', 'A-Z']
                      .map(
                        (value) => PopupMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ),
                      )
                      .toList();
                },
                child: _filterBadge(Icons.sort_rounded, _sort),
              ),
              if (_isSearching)
                TextButton(
                  onPressed: _resetFilters,
                  style: TextButton.styleFrom(foregroundColor: _purple),
                  child: const Text('Reset'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _blush),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: _blueGrey),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: _purple, fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 17,
            color: _purple,
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(Game game) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _blush),
      ),
      child: InkWell(
        onTap: () => _openDetail(game),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child: Image.network(
                    game.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, error, stack) {
                      return const ColoredBox(
                        color: _pink,
                        child: Icon(
                          Icons.sports_esports_rounded,
                          color: _purple,
                          size: 30,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _purple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.genre,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(game.releaseDate),
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => _openDetail(game),
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Lihat detail',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return 'Tanggal rilis belum tersedia';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
