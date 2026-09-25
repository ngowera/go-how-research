import 'dart:convert';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/app_settings_provider.dart';
import '../../../shared/widgets/profile_avatar.dart';

class AppearanceCard extends ConsumerStatefulWidget {
  const AppearanceCard({super.key});
  @override
  ConsumerState<AppearanceCard> createState() => _AppearanceCardState();
}

class _AppearanceCardState extends ConsumerState<AppearanceCard> {
  bool busy = false;
  String? error;
  Future<void> pickPhoto() async {
    setState(() => busy = true);
    try {
      final files = await FilePicker.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
          withData: true);
      if (files.isEmpty) return;
      final bytes = await files.single.readAsBytes();
      if (bytes == null || bytes.length > 5000000)
        throw StateError('Choose a PNG, JPEG or WebP image smaller than 5 MB.');
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 192);
      final frame = await codec.getNextFrame();
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      codec.dispose();
      if (png == null || png.lengthInBytes > 250000)
        throw StateError('Please choose a smaller profile image.');
      await ref.read(authStateProvider.notifier).updateProfile(
          avatarUrl:
              'data:image/png;base64,${base64Encode(png.buffer.asUint8List())}');
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _showPhotoActions() async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose another profile image'),
              onTap: () => Navigator.pop(context, 'choose'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove photo'),
              onTap: () => Navigator.pop(context, 'remove'),
            ),
          ],
        ),
      ),
    );
    if (!mounted) return;
    if (action == 'choose') {
      await pickPhoto();
    } else if (action == 'remove') {
      await ref.read(authStateProvider.notifier).updateProfile(avatarUrl: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider),
        settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Your profile',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Center(
                  child: InkWell(
                      onTap: busy ? null : _showPhotoActions,
                      customBorder: const CircleBorder(),
                      child: ProfileAvatar(
                          name: user?.name ?? '',
                          image: user?.avatarUrl,
                          radius: 48))),
              const SizedBox(height: 10),
              Center(
                  child: Text(user?.name ?? 'Researcher',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700))),
              if (error != null)
                Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 14),
              const Text('Accent colour'),
              Wrap(
                  spacing: 8,
                  children: [0xFF1565C0, 0xFF00897B, 0xFF7B1FA2, 0xFFAD4B00]
                      .map((color) => ChoiceChip(
                          label: Text(color == 0xFF1565C0
                              ? 'Blue'
                              : color == 0xFF00897B
                                  ? 'Teal'
                                  : color == 0xFF7B1FA2
                                      ? 'Purple'
                                      : 'Amber'),
                          avatar: CircleAvatar(
                              backgroundColor: Color(color), radius: 7),
                          selected: settings.accentColor == color,
                          onSelected: (_) =>
                              notifier.updateAppearance(accentColor: color)))
                      .toList()),
              const SizedBox(height: 12),
              const Text('Sidebar colour'),
              Wrap(
                spacing: 8,
                children: (const [
                  0xFFFFFFFF,
                  0xFF000000,
                  0xFF1565C0,
                  0xFF00897B,
                ])
                    .map((color) => ChoiceChip(
                          label: Text(color == 0xFFFFFFFF
                              ? 'White'
                              : color == 0xFF000000
                                  ? 'Black'
                                  : color == 0xFF1565C0
                                      ? 'Blue'
                                      : 'Teal'),
                          avatar: CircleAvatar(
                              backgroundColor: Color(color), radius: 7),
                          selected: settings.sidebarColor == color,
                          onSelected: (_) => notifier.updateSidebarColor(color),
                        ))
                    .toList(),
              ),
            ])));
  }
}
