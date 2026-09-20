import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import '../../core/providers/projects_provider.dart';
import '../../core/providers/auth_provider.dart';

class ResearchExpertButton extends StatelessWidget {
  const ResearchExpertButton({super.key});

  void _openPanel(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close AI panel',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.centerRight,
          child: ResearchExpertDialog(),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => FloatingActionButton(
        heroTag: 'research-expert',
        tooltip: 'Open AI research expert',
        shape: const CircleBorder(),
        onPressed: () => _openPanel(context),
        child: const Text(
          'AI',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      );
}

class ResearchExpertDialog extends ConsumerStatefulWidget {
  const ResearchExpertDialog({super.key});
  @override
  ConsumerState<ResearchExpertDialog> createState() =>
      _ResearchExpertDialogState();
}

class _ResearchExpertDialogState extends ConsumerState<ResearchExpertDialog> {
  final input = TextEditingController();
  final scroll = ScrollController();
  final messages = <Map<String, String>>[];
  String? projectId, error, coverage;
  bool busy = false;
  @override
  void dispose() {
    input.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty || busy) return;
    final history = List<Map<String, String>>.from(messages);
    setState(() {
      messages.add({'role': 'user', 'text': text});
      busy = true;
      error = null;
      input.clear();
    });
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentSession == null)
        throw StateError(
            'Sign in online to use Research Expert. Your offline work remains available.');
      final result = await client.functions.invoke('research-expert',
          body: {'message': text, 'projectId': projectId, 'history': history});
      final data = result.data;
      if (data is! Map || data['answer'] is! String)
        throw StateError(data is Map
            ? data['error']?.toString() ?? 'No answer returned.'
            : 'No answer returned.');
      if (!mounted) return;
      setState(() {
        messages.add({'role': 'model', 'text': data['answer']});
        coverage =
            '${data['projects']} projects • ${data['records']} synced records • ${data['asOf']}';
      });
    } on FunctionException catch (e) {
      if (mounted)
        setState(() => error = e.details is Map
            ? (e.details['error']?.toString() ??
                'Research Expert is unavailable.')
            : 'Research Expert is unavailable. Deploy the server function and sign in online.');
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients)
        scroll.animateTo(scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserProvider)?.id;
    final projects = ref
        .watch(projectsProvider)
        .projects
        .where((p) => p.ownerId == uid)
        .toList();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth = screenWidth < 560 ? screenWidth : 460.0;
    final isCompact = screenWidth < 560;
    final panelRadius = isCompact
        ? BorderRadius.zero
        : const BorderRadius.horizontal(left: Radius.circular(22));

    return Material(
      type: MaterialType.transparency,
      child: ClipRRect(
        borderRadius: panelRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: panelRadius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(-8, 0),
                ),
              ],
            ),
            child: SafeArea(
              left: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SizedBox(
                  width: panelWidth,
                  height: double.infinity,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                      child: Column(children: [
                        Row(children: [
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text('AI',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Research Expert',
                                    style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Ask about your projects and synced findings',
                                    style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                          IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close))
                        ]),
                        const Material(
                            color: Color(0xFFFFF3CD),
                            child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                    'Use Research Expert for confirmation only, and double-check its responses.',
                                    style:
                                        TextStyle(color: Color(0xFF654B00))))),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                            initialValue: projectId ?? '',
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Research context'),
                            items: [
                              const DropdownMenuItem(
                                  value: '', child: Text('All my projects')),
                              ...projects.map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text(p.title,
                                      overflow: TextOverflow.ellipsis)))
                            ],
                            onChanged: busy
                                ? null
                                : (v) => setState(() {
                                      projectId = v == '' ? null : v;
                                      messages.clear();
                                      coverage = null;
                                      error = null;
                                    })),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                                'Uses synced study details and numeric/category summaries. Names, contacts and free-text answers are excluded. Unsynced changes are not included.',
                                style: TextStyle(fontSize: 12))),
                        Expanded(
                            child: ListView(controller: scroll, children: [
                          if (messages.isEmpty) ...[
                            const Text(
                                'Ask about your study, questionnaire or findings.'),
                            ...[
                              'What is missing from my study design?',
                              'Explain the main patterns in my data.',
                              'Which statistical test fits my research questions?'
                            ].map((s) => TextButton(
                                onPressed: () => input.text = s,
                                child: Text(s))),
                          ],
                          ...messages.map((m) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: m['role'] == 'user'
                                      ? const Color(0xFFE3F2FD)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        m['role'] == 'user'
                                            ? 'You'
                                            : 'Research Expert',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87)),
                                    SelectableText(m['text']!,
                                        style: const TextStyle(
                                            color: Colors.black87))
                                  ]))),
                          if (busy) const LinearProgressIndicator(),
                          if (error != null)
                            Text(error!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                        ])),
                        if (coverage != null)
                          Text(coverage!, style: const TextStyle(fontSize: 10)),
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: input,
                                  maxLines: 3,
                                  minLines: 1,
                                  maxLength: 4000,
                                  decoration: InputDecoration(
                                      hintText: 'Ask Research Expert',
                                      filled: true,
                                      fillColor:
                                          Colors.white.withValues(alpha: 0.58),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18)),
                                        borderSide: BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.8)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18)),
                                        borderSide: BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.8)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18)),
                                        borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.7)),
                                      ),
                                      counterText: ''),
                                  onSubmitted: (_) => send())),
                          IconButton(
                              tooltip: 'Send question',
                              onPressed: busy ? null : send,
                              icon: const Icon(Icons.send))
                        ]),
                      ])),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
