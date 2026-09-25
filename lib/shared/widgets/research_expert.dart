import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:ui';
import 'dart:math' as math;

import '../../core/providers/projects_provider.dart';
import '../../core/providers/auth_provider.dart';

class ResearchAssistantButton extends StatelessWidget {
  const ResearchAssistantButton({super.key});

  void _openPanel(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Research Assistant panel',
      barrierColor: const Color(0xFF2A160F).withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const Align(
          alignment: Alignment.centerRight,
          child: ResearchAssistantPanel(),
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
        heroTag: 'research-assistant',
        tooltip: 'Open Research Assistant',
        backgroundColor: Colors.transparent,
        elevation: 10,
        shape: const CircleBorder(),
        onPressed: () => _openPanel(context),
        child: ClipOval(
          child: Image.asset(
            'kuphanda.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            semanticLabel: 'Research Assistant',
          ),
        ),
      );
}

class ResearchAssistantPanel extends ConsumerStatefulWidget {
  const ResearchAssistantPanel({super.key});
  @override
  ConsumerState<ResearchAssistantPanel> createState() =>
      _ResearchAssistantPanelState();
}

class _ResearchAssistantPanelState
    extends ConsumerState<ResearchAssistantPanel> {
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
          'Sign in online to use Research Assistant. Your offline work remains available.',
        );
      final result = await client.functions.invoke(
        'research-expert',
        body: {'message': text, 'projectId': projectId, 'history': history},
      );
      final data = result.data;
      if (data is! Map || data['answer'] is! String)
        throw StateError(
          data is Map
              ? data['error']?.toString() ?? 'No answer returned.'
              : 'No answer returned.',
        );
      if (!mounted) return;
      setState(() {
        messages.add({'role': 'model', 'text': data['answer']});
        coverage =
            '${data['projects']} projects • ${data['records']} synced records • ${data['asOf']}';
      });
    } on FunctionException catch (e) {
      if (mounted)
        setState(
          () => error = e.details is Map
              ? (e.details['error']?.toString() ??
                  'Research Assistant is unavailable.')
              : 'Research Assistant is unavailable. Deploy the server function and sign in online.',
        );
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && scroll.hasClients)
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelWidth = screenWidth < 560 ? screenWidth - 20 : 430.0;
    final isCompact = screenWidth < 560;
    final panelRadius = BorderRadius.circular(isCompact ? 26 : 32);
    const cream = Color(0xFFFFF4EA);
    const mutedCream = Color(0xFFE7CFC0);
    const warmBrown = Color(0xFF321C15);

    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 10 : 18),
        child: ClipRRect(
          borderRadius: panelRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: warmBrown.withValues(alpha: 0.91),
                borderRadius: panelRadius,
                border: Border.all(color: cream.withValues(alpha: 0.20)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A0B07).withValues(alpha: 0.42),
                    blurRadius: 36,
                    spreadRadius: 2,
                    offset: const Offset(-10, 12),
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
                    height: isCompact
                        ? double.infinity
                        : math.min(screenHeight - 36, 760),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: cream.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: cream.withValues(alpha: 0.28),
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'kuphanda.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                    semanticLabel: 'Research Assistant',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Research Assistant',
                                      style: TextStyle(
                                        color: cream,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'AI support for your research',
                                      style: TextStyle(
                                        color: mutedCream,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Close',
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: cream.withValues(
                                    alpha: 0.12,
                                  ),
                                  foregroundColor: cream,
                                ),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  initialValue: projectId ?? '',
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF4B2A1D),
                                  style: const TextStyle(color: cream),
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.folder_open_outlined,
                                      color: mutedCream,
                                      size: 19,
                                    ),
                                    labelText: 'Project context',
                                    labelStyle:
                                        const TextStyle(color: mutedCream),
                                    filled: true,
                                    fillColor: cream.withValues(alpha: 0.08),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem(
                                      value: '',
                                      child: Text('All projects'),
                                    ),
                                    ...projects.map(
                                      (p) => DropdownMenuItem(
                                        value: p.id,
                                        child: Text(
                                          p.title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: busy
                                      ? null
                                      : (v) => setState(() {
                                            projectId = v == '' ? null : v;
                                            messages.clear();
                                            coverage = null;
                                            error = null;
                                          }),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Tooltip(
                                message:
                                    'Uses synced numeric and categorical summaries only. Verify important conclusions.',
                                child: IconButton(
                                  onPressed: () => showDialog<void>(
                                    context: context,
                                    builder: (context) => const AlertDialog(
                                      title: Text('About Research Assistant'),
                                      content: Text(
                                        'Research Assistant helps researchers with study design, questionnaires and interpreting findings. It uses synced study details and numeric or categorical summaries. Names, contacts and free-text answers are excluded. Verify important conclusions before reporting them.',
                                      ),
                                    ),
                                  ),
                                  color: mutedCream,
                                  icon: const Icon(Icons.info_outline),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView(
                              controller: scroll,
                              children: [
                                if (messages.isEmpty) ...[
                                  const Text(
                                    'Ask about your study, questionnaire or findings.',
                                    style: TextStyle(color: cream),
                                  ),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      'What is missing from my study design?',
                                      'Explain the main patterns in my data.',
                                      'Which statistical test fits my research questions?',
                                    ]
                                        .map(
                                          (s) => ActionChip(
                                            backgroundColor:
                                                cream.withValues(alpha: 0.10),
                                            side: BorderSide(
                                              color:
                                                  cream.withValues(alpha: 0.18),
                                            ),
                                            label: Text(
                                              s,
                                              style: const TextStyle(
                                                color: mutedCream,
                                                fontSize: 11,
                                              ),
                                            ),
                                            onPressed: () => input.text = s,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                                ...messages.map(
                                  (m) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: m['role'] == 'user'
                                          ? cream.withValues(alpha: 0.16)
                                          : Colors.black.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['role'] == 'user'
                                              ? 'You'
                                              : 'Research Assistant',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: cream,
                                          ),
                                        ),
                                        SelectableText(
                                          m['text']!,
                                          style: const TextStyle(color: cream),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (busy) const LinearProgressIndicator(),
                                if (error != null)
                                  Text(
                                    error!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (coverage != null)
                            Text(
                              coverage!,
                              style: const TextStyle(
                                color: mutedCream,
                                fontSize: 10,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: input,
                                  maxLines: 3,
                                  minLines: 1,
                                  maxLength: 4000,
                                  decoration: InputDecoration(
                                    hintText: 'Ask Research Assistant',
                                    hintStyle: const TextStyle(
                                      color: mutedCream,
                                    ),
                                    filled: true,
                                    fillColor: cream.withValues(alpha: 0.10),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color: cream.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color: cream.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color: cream.withValues(alpha: 0.7),
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                  style: const TextStyle(color: cream),
                                  textInputAction: TextInputAction.send,
                                  onChanged: (value) {
                                    // Desktop Enter inserts a newline in a
                                    // multi-line field, so submit it here too.
                                    if (value.endsWith('\n')) send();
                                  },
                                  onSubmitted: (_) => send(),
                                ),
                              ),
                              IconButton.filled(
                                tooltip: 'Send question',
                                onPressed: busy ? null : send,
                                style: IconButton.styleFrom(
                                  backgroundColor: cream,
                                  foregroundColor: warmBrown,
                                  disabledBackgroundColor: cream.withValues(
                                    alpha: 0.20,
                                  ),
                                ),
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
