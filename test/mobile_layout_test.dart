import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:gohow_research/core/database/app_database.dart';
import 'package:gohow_research/core/models/app_models.dart';
import 'package:gohow_research/core/providers/auth_provider.dart';
import 'package:gohow_research/features/data_collection/screens/data_collection_screen.dart';
import 'package:gohow_research/features/interviews/interviews_screen.dart';
import 'package:gohow_research/features/projects/screens/projects_screen.dart';
import 'package:gohow_research/features/questionnaires/screens/questionnaires_screen.dart';
import 'package:gohow_research/features/settings/screens/settings_screen.dart';
import 'package:gohow_research/features/supervisor/screens/supervisor_screen.dart';
import 'package:gohow_research/shared/widgets/research_expert.dart';

void main() {
  const phoneSize = Size(390, 844);

  Future<AppDatabase> pumpScreen(WidgetTester tester, Widget screen) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.binding.setSurfaceSize(phoneSize);
    addTearDown(() async {
      // Unmount ProviderScope before closing the database so its active
      // streams and notifiers can dispose cleanly.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
      await tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: screen),
      ),
    );
    // These screens contain progress indicators and background providers that
    // may remain active by design. A bounded pump renders the UI without
    // waiting forever for every animation to become idle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return database;
  }

  testWidgets('settings tabs stay readable on a phone', (tester) async {
    await pumpScreen(tester, const SettingsScreen());

    expect(find.text('Settings & System Hub'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(TabBar), const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 500));
    final databaseTab = find.text('Database & Storage Health');
    await tester.ensureVisible(databaseTab);
    await tester.tap(databaseTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Database Tools & Mock Data Generator'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Participants'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('data collection stays readable on a phone', (tester) async {
    await pumpScreen(
      tester,
      const DataCollectionScreen(questionnaireId: 'missing-questionnaire'),
    );

    expect(
      find.text('This questionnaire has no questions yet'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('questionnaire workspace stays readable on a phone',
      (tester) async {
    await pumpScreen(tester, const QuestionnairesScreen());

    expect(find.text('Questionnaires & Data Collection'), findsOneWidget);
    expect(find.text('Questionnaire Builder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supervisor screen stays readable on a phone', (tester) async {
    await pumpScreen(tester, const SupervisorScreen());

    expect(find.text('Supervisor Collaboration Portal'), findsOneWidget);
    expect(find.text('Supervised Projects'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Data Capture exposes project asset controls on a phone',
      (tester) async {
    await pumpScreen(tester, const InterviewsScreen());

    expect(find.text('Data Capture'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Photos, video & documents'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Photos, video & documents'), findsOneWidget);
    expect(find.text('Upload PDF, Word or Excel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Research Assistant uses the mobile-safe prompt', (tester) async {
    await pumpScreen(tester, const ResearchAssistantPanel());

    expect(find.text('Research Assistant'), findsWidgets);
    expect(find.widgetWithText(TextField, 'Ask Research Assistant'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Research Assistant sends a desktop message when Enter is pressed',
      (tester) async {
    await pumpScreen(tester, const ResearchAssistantPanel());

    final prompt = find.widgetWithText(TextField, 'Ask Research Assistant');
    await tester.enterText(prompt, 'Help me plan my research');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(find.text('Help me plan my research'), findsOneWidget);
  });

  testWidgets('Research Assistant launcher opens over the current screen',
      (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(
        body: Center(child: Text('Current research screen')),
        floatingActionButton: ResearchAssistantButton(),
      ),
    );

    expect(find.bySemanticsLabel('Research Assistant'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Research Assistant'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Current research screen'), findsOneWidget);
    expect(find.text('Research Assistant'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ask Research Assistant'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Projects screen renders dashboard projects and confirms deletion',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final user = AppUser(
      id: 'researcher-1',
      email: 'researcher@example.com',
      name: 'Researcher',
      role: UserRole.student,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final project = ResearchProject(
      id: 'project-1',
      title: 'Visible dashboard project',
      description: 'A project that must appear in the project list.',
      objectives: 'Test project visibility',
      researchQuestions: const ['Is the project visible?'],
      methodology: 'Quantitative',
      population: 'Students',
      sampleSize: 50,
      sites: const ['Campus'],
      status: ResearchStatus.active,
      ownerId: user.id,
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
      syncStatus: SyncStatus.pending,
    );
    await database.insertProject(project);
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await database.close();
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentUserProvider.overrideWithValue(user),
        ],
        child: const MaterialApp(home: ProjectsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Visible dashboard project'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, 'Delete'));
    await tester.pump();
    expect(find.text('Delete this project?'), findsOneWidget);
    expect(find.textContaining('cannot be recovered'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
