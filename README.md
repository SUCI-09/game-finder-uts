# GameFinder — UTS Pemrograman Mobile

Aplikasi mobile Flutter/Dart untuk menjelajahi katalog game gratis melalui FreeToGame API. Data berasal dari server, bukan daftar statis di dalam kode.

## Fitur
- Daftar game dengan gambar, genre, platform, dan deskripsi singkat.
- Pencarian judul, filter genre/platform, urutan alfabet atau tanggal rilis.
- Detail game melalui named route dan ID: deskripsi, developer, publisher, tanggal rilis, kebutuhan sistem, screenshot.
- Loading, pesan error, coba lagi, pull-to-refresh, dan fallback gambar.
- Tautan situs game serta atribusi aktif ke FreeToGame.

## Persiapan dan menjalankan
Gunakan Flutter 3.35 atau lebih baru (Dart 3.9+), Android SDK, dan emulator atau ponsel Android dengan USB debugging.

~~~sh
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run
~~~

Buka folder proyek ini di VS Code/Android Studio. Jalankan perintah dari folder yang memiliki pubspec.yaml. Aktifkan internet pada perangkat. Tidak membutuhkan API key.

~~~sh
flutter build apk --release
~~~

Hasil APK: build/app/outputs/flutter-apk/app-release.apk. Konfigurasi release bawaan menggunakan signing debug untuk keperluan demonstrasi tugas; distribusi Play Store memerlukan signing sendiri.

Target proyek ini Android. Pengujian Flutter Web memerlukan penanganan CORS sesuai kebijakan penyedia API; utamakan emulator/ponsel Android.

## API dan pengolahan data
- GET https://www.freetogame.com/api/games
- GET https://www.freetogame.com/api/game?id=ID_GAME
- Dokumentasi: https://www.freetogame.com/api-doc
- Sumber data: [FreeToGame.com](https://www.freetogame.com/)

GameApi mengirim request dengan timeout 20 detik dan memeriksa status HTTP. JSON diubah menjadi Game/GameDetail. Future disimpan pada initState agar perubahan pencarian tidak mengirim ulang request. Pencarian, filter, dan pengurutan berjalan pada salinan data hasil API. Detail diambil ulang berdasarkan ID yang dikirim sebagai arguments named route /detail. Requirements dan screenshot yang tidak tersedia ditangani tanpa indeks tetap.

## Struktur
- lib/main.dart: tema, lifecycle API client, dan named route.
- lib/model/game.dart: model dan parsing JSON.
- lib/services/game_api.dart: HTTP, timeout, dan penanganan respons.
- lib/pages/home_page.dart: daftar, pencarian, filter, pengurutan, muat ulang.
- lib/pages/detail_page.dart: pengambilan dan tampilan detail.
- lib/widgets/shared.dart: gambar, status, tautan, dan atribusi.
- test/widget_test.dart: model, API mock, pencarian, navigasi, retry.

## Kesesuaian UTS
Flutter/Dart; dua halaman GUI; data dinamis dari FreeToGame; data diolah dan ditampilkan sesuai tujuan katalog game. Materi mengacu pada Modul 08 (navigasi), Modul 09 (state), dan Modul 10 (GUI/API/JSON). Tidak menggunakan GPS atau CRUD karena tidak diperlukan untuk katalog.

## Mengunggah ke GitHub
Buat repositori PUBLIC kosong, lalu jalankan dari folder proyek:

~~~sh
git init
git add .
git commit -m "Implement GameFinder Flutter UTS"
git branch -M main
git remote add origin https://github.com/USERNAME/game-finder-uts.git
git push -u origin main
~~~

Ganti USERNAME dengan akun Anda. Jangan unggah local.properties, folder build, .dart_tool, atau kredensial. File tersebut diabaikan melalui .gitignore. Sertakan pubspec.lock agar versi package konsisten. Verifikasi tautan repositori dapat dibuka tanpa login.

## Pengumpulan akhir
Kode proyek ini merupakan bagian implementasi UTS. Laporan PDF belum dibuat dan repositori belum diunggah otomatis. Laporan mengikuti BAB I Pendahuluan (1.1, 1.2), BAB II Pembahasan (2.1, 2.2, 2.3), BAB III Penutup (3.1, 3.2). Gunakan screenshot asli hasil menjalankan aplikasi. Upload PDF ke Google Drive dengan akses Anyone with the link / Viewer. Kumpulkan tautan GitHub public dan tautan PDF Drive.
