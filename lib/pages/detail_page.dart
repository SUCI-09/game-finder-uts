import 'package:flutter/material.dart';
import '../model/game.dart';
import '../services/game_api.dart';
import '../widgets/shared.dart';

class DetailPage extends StatefulWidget {
  final GameApi api;
  final int gameId;
  const DetailPage({super.key, required this.api, required this.gameId});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<GameDetail> _future;
  @override
  void initState() {
    super.initState();
    _future = widget.api.fetchDetail(widget.gameId);
  }

  void _retry() => setState(() {
    _future = widget.api.fetchDetail(widget.gameId);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Detail game')),
    body: SafeArea(
      child: FutureBuilder<GameDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return StatusPanel(
              message: snapshot.error.toString(),
              retry: _retry,
            );
          }
          final detail = snapshot.data;
          if (detail == null) {
            return StatusPanel(
              message: 'Detail tidak tersedia.',
              retry: _retry,
            );
          }
          final game = detail.game;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GameImage(game.thumbnail),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Chip(label: Text(game.genre)),
                              Chip(label: Text(game.platform)),
                              if (detail.status.isNotEmpty)
                                Chip(label: Text(detail.status)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _info('Developer', game.developer),
                          _info('Publisher', game.publisher),
                          _info('Tanggal rilis', game.releaseDate),
                          const SizedBox(height: 20),
                          _heading(context, 'Tentang game'),
                          SelectableText(
                            detail.description.isEmpty
                                ? game.shortDescription
                                : detail.description,
                            style: const TextStyle(height: 1.6),
                          ),
                          const SizedBox(height: 24),
                          _heading(context, 'Kebutuhan sistem minimum'),
                          if (detail.requirements.isEmpty)
                            const Text(
                              'Informasi kebutuhan sistem tidak tersedia untuk game ini.',
                            )
                          else
                            ...detail.requirements.entries.map(
                              (e) => _info(_label(e.key), e.value),
                            ),
                          const SizedBox(height: 24),
                          _heading(context, 'Screenshot'),
                          if (detail.screenshots.isEmpty)
                            const Text('Screenshot belum tersedia.')
                          else
                            SizedBox(
                              height: 180,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: detail.screenshots.length,
                                separatorBuilder: (_, index) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, index) => SizedBox(
                                  width: 300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: GameImage(detail.screenshots[index]),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (game.gameUrl.isNotEmpty)
                            FilledButton.icon(
                              onPressed: () =>
                                  openWebsite(context, game.gameUrl),
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Buka situs resmi game'),
                            ),
                          const SizedBox(height: 12),
                          const Center(child: SourceCredit()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text('$label: ${value.isEmpty ? 'Tidak tersedia' : value}'),
  );

  String _label(String key) =>
      const {
        'os': 'Sistem operasi',
        'processor': 'Prosesor',
        'memory': 'RAM',
        'graphics': 'Grafis',
        'storage': 'Penyimpanan',
      }[key] ??
      key;
}
