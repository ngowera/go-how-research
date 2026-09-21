import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/projects_provider.dart';
import 'analytics_screen.dart';

class AnalysisProjectPicker extends ConsumerWidget {
  const AnalysisProjectPicker({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(projectsProvider);
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text(state.error!));
    }
    if (state.projects.isEmpty) {
      return Center(
        child: FilledButton.icon(
          onPressed: () => context.go('/projects'),
          icon: const Icon(Icons.add),
          label: const Text('Create a project to begin analytics'),
        ),
      );
    }
    final projects = [...state.projects]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return AnalyticsScreen(projectId: projects.first.id);
  }
}
