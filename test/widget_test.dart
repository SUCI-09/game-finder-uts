import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:game_finder/main.dart';
import 'package:game_finder/model/game.dart';
import 'package:game_finder/services/game_api.dart';

Map<String, dynamic> game(int id, String title, String genre) => {
  'id': id,
  'title': title,
  'genre': genre,
  'platform': 'PC (Windows)',
  'thumbnail': '',
  'short_description': 'Deskripsi game',
  'developer': 'Developer',
  'publisher': 'Publisher',
  'release_date': '2026-01-01',
};

void main() {
  test('Detail menerima requirements null dan screenshot kosong', () {
    final detail = GameDetail.fromJson({
      ...game(1, 'Alpha', 'Shooter'),
      'minimum_system_requirements': null,
      'screenshots': [],
    });
    expect(detail.requirements, isEmpty);
    expect(detail.screenshots, isEmpty);
  });

  test('API membentuk endpoint daftar dan detail yang benar', () async {
    final api = GameApi(
      client: MockClient((request) async {
        expect(request.url.host, 'www.freetogame.com');
        if (request.url.path == '/api/games') {
          return http.Response(jsonEncode([game(7, 'Alpha', 'Shooter')]), 200);
        }
        expect(request.url.path, '/api/game');
        expect(request.url.queryParameters['id'], '7');
        return http.Response(jsonEncode(game(7, 'Alpha', 'Shooter')), 200);
      }),
    );
    addTearDown(api.close);
    expect((await api.fetchGames()).single.id, 7);
    expect((await api.fetchDetail(7)).game.title, 'Alpha');
  });

  test('API menolak status gagal dan bentuk JSON salah', () async {
    final failing = GameApi(
      client: MockClient((_) async => http.Response('error', 503)),
    );
    final malformed = GameApi(
      client: MockClient((_) async => http.Response('{}', 200)),
    );
    addTearDown(failing.close);
    addTearDown(malformed.close);
    await expectLater(failing.fetchGames(), throwsA(isA<ApiException>()));
    await expectLater(malformed.fetchGames(), throwsA(isA<ApiException>()));
  });

  testWidgets('Pencarian dan navigasi detail memakai data API', (tester) async {
    var listRequests = 0;
    final api = GameApi(
      client: MockClient((request) async {
        if (request.url.path == '/api/games') {
          listRequests++;
          return http.Response(
            jsonEncode([
              game(1, 'Alpha', 'Shooter'),
              game(2, 'Beta', 'Strategy'),
            ]),
            200,
          );
        }
        expect(request.url.queryParameters['id'], '1');
        return http.Response(
          jsonEncode({
            ...game(1, 'Alpha', 'Shooter'),
            'description': 'Deskripsi lengkap Alpha',
          }),
          200,
        );
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(GameFinderApp(api: api));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Alpha');
    await tester.pumpAndSettle();
    expect(find.text('1 dari 2 game'), findsOneWidget);
    expect(listRequests, 1);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -550));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Alpha').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alpha').last);
    await tester.pumpAndSettle();
    expect(find.text('Detail game'), findsOneWidget);
    expect(find.text('Deskripsi lengkap Alpha'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kegagalan API dapat dicoba kembali', (tester) async {
    var attempts = 0;
    final api = GameApi(
      client: MockClient((_) async {
        attempts++;
        return attempts == 1
            ? http.Response('error', 500)
            : http.Response(jsonEncode([game(1, 'Alpha', 'Shooter')]), 200);
      }),
    );
    addTearDown(api.close);
    await tester.pumpWidget(GameFinderApp(api: api));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('1 dari 1 game'), findsOneWidget);
    expect(attempts, 2);
  });
}


