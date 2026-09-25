import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' show AppDatabase, databaseProvider;
import '../models/app_models.dart';
import 'auth_provider.dart';
import 'billing_provider.dart';
import 'sync_provider.dart';

class ProjectsState {
  final List<ResearchProject> projects;
  final bool isLoading;
  final String? error;

  const ProjectsState({
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectsState copyWith({
    List<ResearchProject>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final AppDatabase _db;
  final Ref _ref;
  static const _uuid = Uuid();

  ProjectsNotifier(this._db, this._ref) : super(const ProjectsState()) {
    loadProjects();
    _ref.listen<DateTime?>(
      syncProvider.select((sync) => sync.lastAttemptTime),
      (previous, next) {
        if (next != null && next != previous) loadProjects();
      },
    );
  }

  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _db.getProjects();
      state = state.copyWith(projects: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createProject({
    required String title,
    required String description,
    required String objectives,
    required List<String> researchQuestions,
    required String methodology,
    required String population,
    required int sampleSize,
    required List<String> sites,
    DateTime? startDate,
    DateTime? endDate,
    String? supervisorId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentUser = _ref.read(currentUserProvider);
      final billing = _ref.read(billingProvider);
      if (!billing.hasUnlimitedProjects && state.projects.length >= 2) {
        throw StateError(
            'The Free plan supports up to 2 projects. Upgrade in Settings to create more.');
      }
      final now = DateTime.now();
      final project = ResearchProject(
        id: _uuid.v4(),
        title: title,
        description: description,
        objectives: objectives,
        researchQuestions: researchQuestions,
        methodology: methodology,
        population: population,
        sampleSize: sampleSize,
        sites: sites,
        startDate: startDate,
        endDate: endDate,
        status: ResearchStatus.active,
        ownerId: currentUser?.id ?? 'local_user',
        supervisorId: supervisorId,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );

      await _db.insertProject(project);
      await loadProjects();
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProject(ResearchProject project) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = project.copyWith(
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await _db.updateProject(updated);
      await loadProjects();
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteProject(String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _db.deleteProject(id);
      await loadProjects();
      _ref.read(syncProvider.notifier).refreshPendingCount();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> archiveProject(String id) async {
    final proj = await _db.getProjectById(id);
    if (proj != null) {
      await updateProject(proj.copyWith(status: ResearchStatus.archived));
    }
  }

  Future<void> duplicateProject(String id) async {
    final billing = _ref.read(billingProvider);
    if (!billing.hasUnlimitedProjects && state.projects.length >= 2) {
      state = state.copyWith(
          error:
              'The Free plan supports up to 2 projects. Upgrade in Settings to duplicate more.');
      return;
    }
    final proj = await _db.getProjectById(id);
    if (proj != null) {
      final now = DateTime.now();
      final dup = proj.copyWith(
        id: _uuid.v4(),
        title: '${proj.title} (Copy)',
        status: ResearchStatus.draft,
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
      );
      await _db.insertProject(dup);
      await loadProjects();
    }
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  final db = ref.watch(databaseProvider);
  return ProjectsNotifier(db, ref);
});

final projectByIdProvider =
    Provider.family<ResearchProject?, String>((ref, id) {
  final projects = ref.watch(projectsProvider).projects;
  try {
    return projects.firstWhere((p) => p.id == id);
  } catch (_) {
    return null;
  }
});
