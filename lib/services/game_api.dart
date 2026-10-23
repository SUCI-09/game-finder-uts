import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/game.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class GameApi {
  final http.Client _client;
  GameApi({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.https('www.freetogame.com', '/api/$path', query);
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ApiException(
          response.statusCode == 404
              ? 'Game tidak ditemukan.'
              : 'Server mengalami masalah (HTTP ${response.statusCode}). Coba lagi.',
        );
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException('Waktu koneksi habis. Silakan coba lagi.');
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung. Periksa koneksi internet Anda.',
      );
    } on FormatException {
      throw const ApiException('Format data server tidak dapat dibaca.');
    }
  }

  Future<List<Game>> fetchGames() async {
    final data = await _get('games');
    if (data is! List) {
      throw const ApiException('Format daftar game tidak sesuai.');
    }
    try {
      return data
          .map((item) => Game.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TypeError {
      throw const ApiException(
        'Data daftar game tidak lengkap atau tidak sesuai.',
      );
    }
  }

  Future<GameDetail> fetchDetail(int id) async {
    final data = await _get('game', {'id': '$id'});
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Format detail game tidak sesuai.');
    }
    try {
      return GameDetail.fromJson(data);
    } on TypeError {
      throw const ApiException(
        'Data detail game tidak lengkap atau tidak sesuai.',
      );
    }
  }

  void close() => _client.close();
}
