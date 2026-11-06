import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'home_screen.dart';

class DetailScreen extends StatefulWidget {
  final Post post;
  final String category;
  const DetailScreen({super.key, required this.post, required this.category});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final PostService _service = PostService();
  late Future<List<Comment>> _commentsFuture;

  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  final List<Comment> _myComments = []; // komentar lokal (tidak dikirim ke API)
  final Set<int> _likedComments = {};
  bool _liked = false;
  bool _bookmarked = false;
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    _commentsFuture = _service.fetchComments(widget.post.id);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _commentsFuture = _service.fetchComments(widget.post.id);
    });
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _share() {
    Clipboard.setData(ClipboardData(
      text: 'https://jsonplaceholder.typicode.com/posts/${widget.post.id}',
    ));
    _toast('Tautan pengumuman disalin');
  }

  void _sendComment() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _myComments.insert(
        0,
        Comment(
          id: -(_myComments.length + 1),
          postId: widget.post.id,
          name: 'Anda',
          email: 'warga@nusa.ac.id',
          body: text,
        ),
      );
      _inputController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _reply(Comment c) {
    _inputController.text = '@${capitalize(c.name.split(' ').first)} ';
    _inputController.selection =
        TextSelection.collapsed(offset: _inputController.text.length);
    _inputFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final post = widget.post;
    final muted = scheme.onSurface.withAlpha(150);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const LogoMark(size: 28),
            const SizedBox(width: 8),
            const Text('Detail Pengumuman', style: TextStyle(fontSize: 17)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _bookmarked = !_bookmarked);
              _toast(_bookmarked
                  ? 'Pengumuman disimpan'
                  : 'Pengumuman dihapus dari simpanan');
            },
            icon: Icon(_bookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded),
          ),
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                // ---------- isi pengumuman ----------
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CategoryBadge(category: widget.category),
                      const SizedBox(height: 14),
                      Text(
                        post.displayTitle,
                        style: TextStyle(
                          fontSize: 22,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          AuthorAvatar(name: post.authorName, radius: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(post.authorName,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: scheme.onSurface)),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.verified_rounded,
                                        size: 15, color: scheme.primary),
                                  ],
                                ),
                                Text(
                                    '${post.authorRole}  •  Pengumuman #${post.id}',
                                    style: TextStyle(
                                        fontSize: 11.5, color: muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (post.hasImage) ...[
                        const SizedBox(height: 16),
                        PostImage(post: post, height: 190),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        post.body,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: scheme.onSurface.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: scheme.primaryContainer),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _ActionPill(
                            icon: _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: '${post.likes + (_liked ? 1 : 0)} Suka',
                            active: _liked,
                            onTap: () => setState(() => _liked = !_liked),
                          ),
                          const SizedBox(width: 10),
                          _ActionPill(
                            icon: Icons.chat_bubble_outline_rounded,
                            label:
                                '${post.commentCount + _myComments.length} Komentar',
                            active: false,
                            onTap: () => _inputFocus.requestFocus(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // ---------- komentar (GET /posts/{id}/comments) ----------
                FutureBuilder<List<Comment>>(
                  future: _commentsFuture,
                  builder: (context, snapshot) {
                    final loading =
                        snapshot.connectionState == ConnectionState.waiting;
                    final fetched = snapshot.data ?? <Comment>[];
                    var merged = [..._myComments, ...fetched];
                    if (!_newestFirst) merged = merged.reversed.toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _commentsHeader(
                            scheme, snapshot.hasData ? merged.length : null),
                        const SizedBox(height: 12),
                        if (loading)
                          const Padding(
                            padding: EdgeInsets.all(28),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snapshot.hasError)
                          _commentsError(
                            scheme,
                            snapshot.error
                                .toString()
                                .replaceFirst('Exception: ', ''),
                          )
                        else if (merged.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text('Belum ada komentar.',
                                style: TextStyle(color: muted)),
                          )
                        else
                          ...merged.map(_commentTile),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ---------- kolom komentar ----------
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withAlpha(25),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      focusNode: _inputFocus,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                      decoration: const InputDecoration(
                        hintText: 'Tulis komentar balasan...',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendComment,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentsHeader(ColorScheme scheme, int? count) {
    return Row(
      children: [
        Text('Komentar Warga',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface)),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary)),
          ),
        ],
        const Spacer(),
        PopupMenuButton<bool>(
          onSelected: (v) => setState(() => _newestFirst = v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: true, child: Text('Terbaru')),
            PopupMenuItem(value: false, child: Text('Terlama')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.primaryContainer),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_newestFirst ? 'Terbaru' : 'Terlama',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary)),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: scheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _commentsError(ColorScheme scheme, String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primaryContainer, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded, color: scheme.primary, size: 34),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(Comment c) {
    final scheme = Theme.of(context).colorScheme;
    final liked = _likedComments.contains(c.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorAvatar(name: c.name, radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(capitalize(c.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: scheme.onSurface)),
                const SizedBox(height: 2),
                Text(c.email,
                    style: TextStyle(fontSize: 12, color: scheme.secondary)),
                const SizedBox(height: 8),
                Text(c.body,
                    style: TextStyle(
                        height: 1.45,
                        fontSize: 14,
                        color: scheme.onSurface.withAlpha(185))),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() {
                        liked
                            ? _likedComments.remove(c.id)
                            : _likedComments.add(c.id);
                      }),
                      child: Row(
                        children: [
                          Icon(
                            liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 15,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(liked ? 'Disukai' : 'Suka',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: scheme.onSurface.withAlpha(150))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    GestureDetector(
                      onTap: () => _reply(c),
                      child: Text('Balas',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: scheme.primary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ActionPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.primaryContainer, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 17, color: scheme.primary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary)),
          ],
        ),
      ),
    );
  }
}
