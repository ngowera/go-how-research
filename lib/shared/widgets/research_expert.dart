import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:ui';
import 'dart:math' as math;
import '../../core/providers/app_settings_provider.dart';

class ResearchAssistantButton extends StatefulWidget {
  final bool phoneOverlay;

  const ResearchAssistantButton({super.key, this.phoneOverlay = false});

  @override
  State<ResearchAssistantButton> createState() =>
      _ResearchAssistantButtonState();
}

class _ResearchAssistantButtonState extends State<ResearchAssistantButton> {
  Offset? _position;

  void _openPanel(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close Research Assistant panel',
      barrierColor: const Color(0xFF2A160F).withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: constraints.maxWidth < 560
                ? Alignment.center
                : Alignment.centerRight,
            child: const ResearchAssistantPanel(),
          ),
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

  Widget _button(BuildContext context) => FloatingActionButton(
        heroTag: 'research-assistant',
        tooltip: 'Open Research Assistant',
        backgroundColor: Colors.transparent,
        elevation: 10,
        shape: const CircleBorder(),
        onPressed: () => _openPanel(context),
        child: ClipOval(
          child: Image.asset(
            'app_logo.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            semanticLabel: 'Research Assistant',
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (!widget.phoneOverlay) return _button(context);

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          const buttonSize = 56.0;
          const horizontalMargin = 12.0;
          const verticalMargin = 12.0;
          final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
          final bottomClearance = math.max(108.0, safeBottom + 84.0);
          final maxX = math.max(horizontalMargin,
              constraints.maxWidth - buttonSize - horizontalMargin);
          final maxY = math.max(verticalMargin,
              constraints.maxHeight - bottomClearance - buttonSize);
          final defaultPosition = Offset(maxX, maxY);
          final current = _position ?? defaultPosition;
          final position = Offset(
            current.dx.clamp(horizontalMargin, maxX).toDouble(),
            current.dy.clamp(verticalMargin, maxY).toDouble(),
          );

          return Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: position.dx,
                top: position.dy,
                width: buttonSize,
                height: buttonSize,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      final latest = _position ?? position;
                      _position = Offset(
                        (latest.dx + details.delta.dx)
                            .clamp(horizontalMargin, maxX)
                            .toDouble(),
                        (latest.dy + details.delta.dy)
                            .clamp(verticalMargin, maxY)
                            .toDouble(),
                      );
                    });
                  },
                  onPanEnd: (_) {
                    final dropped = _position ?? position;
                    final snapped = <Offset>[
                      Offset(horizontalMargin, dropped.dy),
                      Offset(maxX, dropped.dy),
                      Offset(dropped.dx, verticalMargin),
                      Offset(dropped.dx, maxY),
                    ].reduce((best, candidate) {
                      final bestDistance = (best.dx - dropped.dx).abs() +
                          (best.dy - dropped.dy).abs();
                      final candidateDistance =
                          (candidate.dx - dropped.dx).abs() +
                              (candidate.dy - dropped.dy).abs();
                      return candidateDistance < bestDistance
                          ? candidate
                          : best;
                    });
                    setState(() => _position = snapped);
                  },
                  child: _button(context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
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
  String? error, coverage;
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
        body: {'message': text, 'history': history},
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final panelWidth = screenWidth < 560 ? screenWidth - 32 : 430.0;
    final isCompact = screenWidth < 560;
    final panelRadius = BorderRadius.circular(isCompact ? 26 : 32);
    final settings = ref.watch(appSettingsProvider);
    final darkPanel = settings.darkResearchAssistant;
    final panelText = darkPanel ? Colors.white : const Color(0xFF1E293B);
    final mutedText =
        darkPanel ? const Color(0xFFD5DCE8) : const Color(0xFF64748B);
    final panelSurface = darkPanel
        ? const Color(0xFF1B2230).withValues(alpha: .64)
        : Colors.white.withValues(alpha: .62);
    final screenReaderText = panelText;

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
                color: panelSurface,
                borderRadius: panelRadius,
                border: Border.all(color: panelText.withValues(alpha: 0.20)),
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
                        ? math.min(screenHeight * .72, 620.0)
                        : math.min(screenHeight - 36, 760),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          isCompact ? 14 : 18,
                          isCompact ? 12 : 16,
                          isCompact ? 14 : 18,
                          isCompact ? 10 : 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: panelText.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: panelText.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'app_logo.png',
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                    semanticLabel: 'Research Assistant',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Research Assistant',
                                      style: TextStyle(
                                        color: panelText,
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton.filledTonal(
                                tooltip: 'Close',
                                onPressed: () => Navigator.pop(context),
                                style: IconButton.styleFrom(
                                  backgroundColor: panelText.withValues(
                                    alpha: 0.12,
                                  ),
                                  foregroundColor: panelText,
                                ),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          SizedBox(height: isCompact ? 8 : 12),
                          Expanded(
                            child: ListView(
                              controller: scroll,
                              children: [
                                ...messages.map(
                                  (m) => Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: m['role'] == 'user'
                                          ? panelText.withValues(alpha: 0.13)
                                          : Colors.black.withValues(
                                              alpha: darkPanel ? 0.12 : 0.04,
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
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: panelText,
                                          ),
                                        ),
                                        SelectableText(
                                          m['text']!,
                                          style: TextStyle(color: panelText),
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
                              style: TextStyle(
                                color: mutedText,
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
                                    hintStyle: TextStyle(
                                      color: mutedText,
                                    ),
                                    filled: true,
                                    fillColor:
                                        panelText.withValues(alpha: 0.08),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color:
                                            panelText.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color:
                                            panelText.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(18),
                                      ),
                                      borderSide: BorderSide(
                                        color:
                                            panelText.withValues(alpha: 0.72),
                                      ),
                                    ),
                                    counterText: '',
                                  ),
                                  style: TextStyle(color: screenReaderText),
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
                                  backgroundColor: panelText,
                                  foregroundColor: darkPanel
                                      ? const Color(0xFF1B2230)
                                      : Colors.white,
                                  disabledBackgroundColor: panelText.withValues(
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
