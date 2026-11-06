import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import 'home_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final PostService _service = PostService();

  String? _category;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    try {
      final Post post = await _service.createPost(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, (post, _category!)); // hasil dikirim ke Home
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(e.toString().replaceFirst('Exception: ', '')),
                ),
              ],
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withAlpha(150);

    Widget label(String text, {bool required = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(text,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: scheme.onSurface)),
              if (required)
                Text(' *',
                    style: TextStyle(
                        color: scheme.secondary, fontWeight: FontWeight.w800)),
            ],
          ),
        );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const LogoMark(size: 28),
            const SizedBox(width: 8),
            const Text('Buat Info', style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AuthorAvatar(name: 'Warga Nusa', radius: 17),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // ---------- tips ----------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withAlpha(150),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_rounded, color: scheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tips Pengumuman Efektif',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: scheme.primary)),
                        const SizedBox(height: 4),
                        Text(
                          'Gunakan judul yang singkat, jelas, dan informatif agar maksud pengumuman mudah dipahami seluruh warga kampus.',
                          style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: scheme.onSurface.withAlpha(180)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ---------- kategori (divalidasi lewat FormField) ----------
            FormField<String>(
              validator: (_) =>
                  _category == null ? 'Pilih satu kategori informasi' : null,
              builder: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: label('Kategori Informasi', required: true)),
                      Text('Pilih 1 kategori',
                          style: TextStyle(fontSize: 11.5, color: muted)),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kCategories
                        .map((c) => CategoryChip(
                              label: c,
                              icon: categoryIcon(c),
                              selected: _category == c,
                              onTap: () {
                                setState(() => _category = c);
                                state.didChange(c);
                              },
                            ))
                        .toList(),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(state.errorText!,
                          style: TextStyle(
                              color: Colors.red.shade400, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ---------- judul ----------
            label('Judul Pengumuman', required: true),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                hintText: 'Contoh: Perubahan Jadwal Kuliah Umum Hari Kamis',
                hintStyle: TextStyle(fontSize: 13.5),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                if (value.trim().length < 5) {
                  return 'Judul minimal 5 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ---------- isi ----------
            label('Isi Pengumuman', required: true),
            TextFormField(
              controller: _bodyController,
              maxLength: 1000,
              maxLines: 7,
              decoration: const InputDecoration(
                hintText:
                    'Tuliskan rincian lengkap pengumuman: waktu, pelaksanaan, serta kontak yang dapat dihubungi...',
                hintStyle: TextStyle(fontSize: 13.5),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Isi tidak boleh kosong';
                }
                if (value.trim().length < 10) {
                  return 'Isi minimal 10 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // ---------- tombol ----------
            FilledButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                  _isSubmitting ? 'Mengirim...' : 'Terbitkan Pengumuman'),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, size: 14, color: muted),
                const SizedBox(width: 6),
                Text('Form tervalidasi via GlobalKey<FormState>',
                    style: TextStyle(fontSize: 11.5, color: muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
