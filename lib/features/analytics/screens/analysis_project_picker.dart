import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/projects_provider.dart';

class AnalysisProjectPicker extends ConsumerWidget {
  const AnalysisProjectPicker({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          const Text('Choose a project to analyse',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Text(
              'Explore responses, check statistical relationships, or prepare an Excel / SPSS dataset.'),
          const SizedBox(height: 20),
          if (state.isLoading) const LinearProgressIndicator(),
          if (state.error != null) Text(state.error!),
          if (!state.isLoading && state.projects.isEmpty)
            Card(
                child: ListTile(
                    title: const Text('Start with a research project'),
                    subtitle: const Text(
                        'Create a project, add a questionnaire and collect responses. Your analyses will appear here.'),
                    trailing: FilledButton(
                        onPressed: () => context.go('/projects'),
                        child: const Text('Projects')))),
          ...state.projects.map((p) => Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.title,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('${p.methodology} • ${p.status.name}'),
                        Wrap(spacing: 12, children: [
                          FilledButton.icon(
                              onPressed: () => context.go('/analytics/${p.id}'),
                              icon: const Icon(Icons.insights),
                              label: const Text('Charts & statistics')),
                          OutlinedButton.icon(
                              onPressed: () => context.go('/data/${p.id}'),
                              icon: const Icon(Icons.table_view),
                              label: const Text('Data & exports'))
                        ]),
                      ])))),
        ]);
  }
}
