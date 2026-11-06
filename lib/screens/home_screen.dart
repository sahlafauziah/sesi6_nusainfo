import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'add_post_screen.dart';
import 'detail_screen.dart';

// ======================= Widget bersama =======================

IconData categoryIcon(String c) {
  switch (c) {
    case 'Penting':
      return Icons.priority_high_rounded;
    case 'Akademik':
      return Icons.school_rounded;
    case 'Kegiatan':
      return Icons.event_rounded;
    case 'Umum':
      return Icons.campaign_rounded;
    default:
      return Icons.apps_rounded;
  }
}

class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
      ),
      child: Icon(Icons.campaign_rounded, color: Colors.white, size: size * 0.55),
    );
  }
}

class AuthorAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const AuthorAvatar({super.key, required this.name, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final initials = parts.take(2).map((e) => e[0].toUpperCase()).join();
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }
}

class CategoryBadge extends StatelessWidget {
  final String category;
  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcon(category), size: 12, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            category.toUpperCase(),
            style: TextStyle(
              color: scheme.primary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? scheme.primary : scheme.primaryContainer,
            width: 1.3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 14, color: selected ? Colors.white : scheme.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostImage extends StatelessWidget {
  final Post post;
  final double height;
  const PostImage({super.key, required this.post, this.height = 170});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget placeholder() => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [scheme.primaryContainer, scheme.secondary.withAlpha(140)],
            ),
          ),
          child: Icon(Icons.image_rounded, color: scheme.primary, size: 36),
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          post.imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (c, child, progress) =>
              progress == null ? child : placeholder(),
          errorBuilder: (c, e, s) => placeholder(),
        ),
      ),
    );
  }
}

// ======================= Home Screen =======================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostService _service = PostService();
  late Future<List<Post>> _postsFuture;

  // JSONPlaceholder tidak menyimpan data, jadi post baru ditampung lokal.
  final List<Post> _localPosts = [];
  final Map<Post, String> _localCategories = {};

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _query = '';
  String _category = 'Semua';
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _postsFuture = _service.fetchPosts(); // dipanggil di initState, bukan build
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _postsFuture = _service.fetchPosts();
      _refreshing = true;
    });
    void done() {
      if (mounted) setState(() => _refreshing = false);
    }

    _postsFuture.then((_) => done(), onError: (_) => done());
  }

  Future<void> _onRefresh() async {
    _reload();
    try {
      await _postsFuture;
    } catch (_) {
      // error ditampilkan oleh FutureBuilder
    }
  }

  String _categoryOf(Post p) => _localCategories[p] ?? p.category;

  List<Post> _filter(List<Post> all) {
    return all.where((p) {
      final okCategory = _category == 'Semua' || _categoryOf(p) == _category;
      final okQuery = _query.isEmpty ||
          p.title.toLowerCase().contains(_query) ||
          p.body.toLowerCase().contains(_query);
      return okCategory && okQuery;
    }).toList();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openAddPost() async {
    final result = await Navigator.push<(Post, String)>(
      context,
      MaterialPageRoute<(Post, String)>(
        builder: (_) => const AddPostScreen(),
      ),
    );

    if (result != null && mounted) {
      final (post, category) = result;
      setState(() {
        _localPosts.insert(0, post);
        _localCategories[post] = category;
      });
      _scrollToTop();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Pengumuman baru berhasil diterbitkan!')),
              ],
            ),
          ),
        );
    }
  }

  void _showCategorySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Kategori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              ...['Semua', ...kCategories].map(
                (c) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(categoryIcon(c),
                      color: Theme.of(ctx).colorScheme.primary),
                  title: Text(c),
                  trailing: _category == c
                      ? Icon(Icons.check_rounded,
                          color: Theme.of(ctx).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _category = c);
                    Navigator.pop(ctx);
                    _scrollToTop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(int resultCount) {
    final scheme = Theme.of(context).colorScheme;
    final filtering = _query.isNotEmpty || _category != 'Semua';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_refreshing) const _RefreshPill(),
        const _Greeting(),
        const SizedBox(height: 14),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Cari pengumuman, agenda, atau kata kunci',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: scheme.secondary),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded, color: scheme.primary),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text('Kategori Warta',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: scheme.onSurface)),
            const Spacer(),
            Text('Geser untuk filter',
                style: TextStyle(
                    fontSize: 11.5, color: scheme.onSurface.withAlpha(130))),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['Semua', ...kCategories]
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: c,
                        selected: _category == c,
                        onTap: () => setState(() => _category = c),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (filtering)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '$resultCount hasil ditemukan',
              style: TextStyle(
                  color: scheme.onSurface.withAlpha(150),
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const LogoMark(),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('NusaInfo',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                Text('Beranda',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: scheme.secondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _toast('Tidak ada notifikasi baru'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: AuthorAvatar(name: 'Warga Nusa', radius: 17),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        onHome: _scrollToTop,
        onAdd: _openAddPost,
        onCategory: _showCategorySheet,
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // loading pertama / coba lagi
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // error (misalnya internet mati) + tombol Coba Lagi
          if (snapshot.hasError) {
            final message =
                snapshot.error.toString().replaceFirst('Exception: ', '');
            return RefreshIndicator(
              color: scheme.primary,
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  const _Greeting(),
                  const SizedBox(height: 16),
                  _ErrorCard(message: message, onRetry: _reload),
                ],
              ),
            );
          }

          final all = [..._localPosts, ...?snapshot.data];
          final results = _filter(all);

          return RefreshIndicator(
            color: scheme.primary,
            backgroundColor: Colors.white,
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: results.isEmpty ? 2 : results.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _header(results.length);
                if (results.isEmpty) {
                  return _EmptyState(query: _searchController.text);
                }
                final post = results[index - 1];
                final category = _categoryOf(post);
                return _PostCard(
                  post: post,
                  category: category,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DetailScreen(post: post, category: category),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ======================= Bagian-bagian Home =======================

class _RefreshPill extends StatelessWidget {
  const _RefreshPill();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primaryContainer),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: scheme.primary),
            ),
            const SizedBox(width: 8),
            Text('Memperbarui pengumuman...',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, Colors.white],
        ),
        border: Border.all(color: scheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, Warga Nusa 👋',
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface)),
                const SizedBox(height: 6),
                Text(
                  'Pengumuman resmi & kabar penting terkini seputar kampus.',
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: scheme.onSurface.withAlpha(160)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 7, color: Color(0xFF7CE0A0)),
                SizedBox(width: 5),
                Text('Kampus Aktif',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primaryContainer, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.wifi_off_rounded, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Koneksi Terputus',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface)),
                    const SizedBox(height: 3),
                    Text(message,
                        style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurface.withAlpha(160))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.search_off_rounded, size: 44, color: scheme.primary),
          ),
          const SizedBox(height: 16),
          Text('Pengumuman tidak ditemukan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface)),
          const SizedBox(height: 6),
          Text(
            query.trim().isEmpty
                ? 'Belum ada pengumuman di kategori ini'
                : 'Tidak ada hasil untuk "${query.trim()}"',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurface.withAlpha(150)),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final String category;
  final VoidCallback onTap;
  const _PostCard(
      {required this.post, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha(150);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CategoryBadge(category: category),
                    const Spacer(),
                    Text('#${post.id}',
                        style: TextStyle(fontSize: 12, color: muted)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  post.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.body.replaceAll('\n', ' '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.5, height: 1.4, color: muted),
                ),
                if (post.hasImage) ...[
                  const SizedBox(height: 12),
                  PostImage(post: post, height: 150),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    AuthorAvatar(name: post.authorName, radius: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.authorName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface)),
                          Text(post.authorRole,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: muted)),
                        ],
                      ),
                    ),
                    Icon(Icons.favorite_border_rounded,
                        size: 16, color: scheme.secondary),
                    const SizedBox(width: 4),
                    Text('${post.likes}',
                        style: TextStyle(fontSize: 12, color: muted)),
                    const SizedBox(width: 12),
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: scheme.secondary),
                    const SizedBox(width: 4),
                    Text('${post.commentCount}',
                        style: TextStyle(fontSize: 12, color: muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onAdd;
  final VoidCallback onCategory;
  const _BottomBar(
      {required this.onHome, required this.onAdd, required this.onCategory});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  active: true,
                  onTap: onHome),
              GestureDetector(
                onTap: onAdd,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [scheme.primary, scheme.secondary]),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 3),
                    Text('Buat Info',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary)),
                  ],
                ),
              ),
              _NavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Kategori',
                  active: false,
                  onTap: onCategory),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem(
      {required this.icon,
      required this.label,
      required this.active,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = active ? scheme.primary : scheme.onSurface.withAlpha(130);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
