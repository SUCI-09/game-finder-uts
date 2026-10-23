import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';
import 'pages/detail_page.dart';
import 'services/game_api.dart';

void main() => runApp(const GameFinderApp());

class GameFinderApp extends StatefulWidget {
  final GameApi? api;
  const GameFinderApp({super.key, this.api});
  @override
  State<GameFinderApp> createState() => _GameFinderAppState();
}

class _GameFinderAppState extends State<GameFinderApp> {
  late final GameApi _api = widget.api ?? GameApi();
  @override
  void dispose() {
    if (widget.api == null) _api.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'GameFinder',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF45496A),
        primary: const Color(0xFF45496A),
        onPrimary: Colors.white,
        secondary: const Color(0xFF7D8BAE),
        onSecondary: const Color(0xFF202338),
        tertiary: const Color(0xFFE5857B),
        onTertiary: const Color(0xFF202338),
        surface: Colors.white,
        onSurface: const Color(0xFF45496A),
        onSurfaceVariant: const Color(0xFF555B73),
        outline: const Color(0xFF7D8BAE),
        outlineVariant: const Color(0xFFE8CCC7),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF45496A),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: Color(0xFF45496A),
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Color(0xFF45496A),
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: Color(0xFF45496A),
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: Color(0xFF45496A)),
        bodyMedium: TextStyle(color: Color(0xFF45496A)),
        bodySmall: TextStyle(color: Color(0xFF555B73)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF555B73)),
        prefixIconColor: const Color(0xFF7D8BAE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8CCC7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE8CCC7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7D8BAE), width: 2),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF45496A),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1B2B2),
        selectedColor: const Color(0xFFE5857B),
        labelStyle: const TextStyle(color: Color(0xFF45496A)),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    initialRoute: '/',
    onGenerateRoute: (settings) {
      if (settings.name == '/') {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => HomePage(api: _api),
        );
      }
      if (settings.name == '/detail' && settings.arguments is int) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) =>
              DetailPage(api: _api, gameId: settings.arguments! as int),
        );
      }
      return MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
          body: const Center(child: Text('Rute atau ID game tidak valid.')),
        ),
      );
    },
  );
}
