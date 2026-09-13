import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/projects_provider.dart';
import '../../core/providers/auth_provider.dart';

class ResearchExpertButton extends StatelessWidget {
  const ResearchExpertButton({super.key});
  @override
  Widget build(BuildContext context) => FloatingActionButton.large(
        heroTag: 'research-expert',
        tooltip: 'Ask Research Expert',
        shape: const CircleBorder(),
        onPressed: () => showDialog(
            context: context, builder: (_) => const ResearchExpertDialog()),
        child: const Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.psychology_outlined),
          Text('Research\nExpert',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 11))
        ]),
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
    return Dialog(
        child: SizedBox(
            width: 600,
            height: MediaQuery.sizeOf(context).height * .82,
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    const Icon(Icons.psychology),
                    const SizedBox(width: 8),
                    const Expanded(
                        child: Text('Research Expert',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
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
                              style: TextStyle(color: Color(0xFF654B00))))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                      initialValue: projectId ?? '',
                      isExpanded: true,
                      decoration:
                          const InputDecoration(labelText: 'Research context'),
                      items: [
                        const DropdownMenuItem(
                            value: '', child: Text('All my projects')),
                        ...projects.map((p) => DropdownMenuItem(
                            value: p.id,
                            child:
                                Text(p.title, overflow: TextOverflow.ellipsis)))
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
                          onPressed: () => input.text = s, child: Text(s))),
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
                                  style: const TextStyle(color: Colors.black87))
                            ]))),
                    if (busy) const LinearProgressIndicator(),
                    if (error != null)
                      Text(error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
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
                            decoration: const InputDecoration(
                                hintText: 'Ask a research question…',
                                counterText: ''),
                            onSubmitted: (_) => send())),
                    IconButton(
                        tooltip: 'Send question',
                        onPressed: busy ? null : send,
                        icon: const Icon(Icons.send))
                  ]),
                ]))));
  }
}
