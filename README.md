# NusaInfo

Aplikasi pengumuman sederhana (Flutter) yang mengambil data dari
[JSONPlaceholder](https://jsonplaceholder.typicode.com) menggunakan package `http`.

## Fitur
- Pencarian pengumuman berdasarkan judul dan isi
- Daftar pengumuman (`GET /posts`) dengan `FutureBuilder`, `ListView.builder`, loading, error, tombol "Coba Lagi", dan `RefreshIndicator`
- Detail pengumuman + komentar (`GET /posts/{id}/comments`)
- Buat pengumuman (`POST /posts`) dengan validasi form dan `SnackBar` konfirmasi

## Struktur
```
lib/
├── models/post.dart
├── services/post_service.dart
├── screens/{home_screen,detail_screen,add_post_screen}.dart
└── main.dart
```

## Cara menjalankan
```
flutter pub get
flutter run
```

## Screenshot
| Home | Detail | Tambah Pengumuman |
|---|---|---|
| ![Home](screenshots/home.png) | ![Detail](screenshots/detail.png) | ![Add](screenshots/add.png) |

| Error (internet mati) | SnackBar berhasil | Pencarian |
|---|---|---|
| ![Error](screenshots/error.png) | ![SnackBar](screenshots/snackbar.png) | ![Search](screenshots/search.png) |
