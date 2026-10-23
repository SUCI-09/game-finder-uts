import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWebsite(BuildContext context, String value) async {
  final uri = Uri.tryParse(value);
  bool opened = false;
  if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  } else if (uri != null && uri.scheme == 'http' && uri.host.isNotEmpty) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tautan tidak dapat dibuka.')));
  }
}

class SourceCredit extends StatelessWidget {
  const SourceCredit({super.key});
  @override
  Widget build(BuildContext context) => TextButton.icon(
    onPressed: () => openWebsite(context, 'https://www.freetogame.com/'),
    icon: const Icon(Icons.open_in_new, size: 15),
    label: const Text('Sumber data: FreeToGame.com'),
  );
}

class GameImage extends StatelessWidget {
  final String url;
  const GameImage(this.url, {super.key});
  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 16 / 9,
    child: Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stack) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.videogame_asset_outlined, size: 48),
        ),
      ),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    ),
  );
}

class StatusPanel extends StatelessWidget {
  final String message;
  final VoidCallback? retry;
  final IconData icon;
  const StatusPanel({
    super.key,
    required this.message,
    this.retry,
    this.icon = Icons.cloud_off_outlined,
  });
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (retry != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: retry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ],
      ),
    ),
  );
}
