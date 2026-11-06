import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/projects_provider.dart';
import 'analytics_screen.dart';

class AnalysisProjectPicker extends ConsumerStatefulWidget {
  const AnalysisProjectPicker({super.key});

  @override
  ConsumerState<AnalysisProjectPicker> createState() =>
      _AnalysisProjectPickerState();
}

class _AnalysisProjectPickerState extends ConsumerState<AnalysisProjectPicker> {
  String? _redirectingTo;

  @override
  Widget build(BuildContext context) {
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
    final projectId = projects.first.id;
    if (_redirectingTo != projectId) {
      _redirectingTo = projectId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/analytics/$projectId');
      });
    }
    return AnalyticsScreen(
      key: ValueKey('analytics-project-$projectId'),
      projectId: projectId,
    );
  }
}
