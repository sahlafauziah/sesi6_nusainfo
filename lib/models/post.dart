class Post {
  final int id;
  final int userId;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
    };
  }
}

/// Model pendukung untuk komentar di Detail Screen.
class Comment {
  final int id;
  final int postId;
  final String name;
  final String email;
  final String body;

  Comment({
    required this.id,
    required this.postId,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      body: json['body'] ?? '',
    );
  }
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

const List<String> kCategories = ['Penting', 'Akademik', 'Kegiatan', 'Umum'];

const List<List<String>> _authors = [
  ['Admin BAAK', 'Biro Administrasi'],
  ['Himpunan Informatika', 'Organisasi Mahasiswa'],
  ['Kemahasiswaan', 'Direktorat Kemahasiswaan'],
  ['Perpustakaan Nusa', 'Layanan Akademik'],
  ['UKM Seni', 'Unit Kegiatan Mahasiswa'],
];

/// Data tambahan untuk tampilan. JSONPlaceholder tidak menyediakan kategori,
/// penulis, gambar, dan jumlah suka, jadi nilainya diturunkan dari id/userId.
extension PostView on Post {
  String get displayTitle => capitalize(title);
  bool get isRemote => id <= 100; // post buatan sendiri memakai id 101
  String get category => kCategories[id % kCategories.length];
  String get authorName => isRemote ? _authors[userId % _authors.length][0] : 'Anda';
  String get authorRole =>
      isRemote ? _authors[userId % _authors.length][1] : 'Warga Nusa';
  int get likes => isRemote ? 12 + (id * 7) % 90 : 0;
  int get commentCount => isRemote ? 5 : 0;
  bool get hasImage => isRemote && id.isOdd;
  String get imageUrl => 'https://picsum.photos/seed/nusa$id/700/360';
}
