import 'package:gohow_research/core/providers/participants_provider.dart';
import 'package:gohow_research/features/questionnaires/screens/questionnaire_builder_screen.dart';
import 'package:gohow_research/features/projects/screens/project_detail_screen.dart';
import 'package:gohow_research/features/data/screens/data_table_screen.dart';
import 'package:gohow_research/features/analytics/screens/analytics_screen.dart';
import 'package:gohow_research/features/reports/screens/reports_screen.dart';
import 'package:gohow_research/features/participants/screens/participants_screen.dart';
import 'package:gohow_research/features/dashboard/screens/dashboard_screen.dart';
import 'package:gohow_research/features/auth/screens/register_screen.dart';
import 'package:gohow_research/features/auth/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
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
  GoogleFonts.config.allowRuntimeFetching = false;
  const phoneSize = Size(390, 844);

  Future<AppDatabase> pumpScreen(WidgetTester tester, Widget screen,
      {Size size = phoneSize, double textScale = 1}) async {
    final database = AppDatabase(NativeDatabase.memory());
    final user = AppUser(
      id: 'researcher-1',
      email: 'researcher@example.com',
      name: 'Researcher',
      role: UserRole.student,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final project = ResearchProject(
      id: 'missing',
      title: 'A long research project title that must wrap on a small phone',
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
    await tester.binding.setSurfaceSize(size);
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
        overrides: [
          databaseProvider.overrideWithValue(database),
          currentUserProvider.overrideWithValue(user)
        ],
        child: MaterialApp(
            home: MediaQuery(
                data: MediaQueryData(
                    size: size, textScaler: TextScaler.linear(textScale)),
                child: screen)),
      ),
    );
    // These screens contain progress indicators and background providers that
    // may remain active by design. A bounded pump renders the UI without
    // waiting forever for every animation to become idle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return database;
  }

  for (final width in [320.0, 390.0]) {
    testWidgets('Participant details use phone width at $width',
        (tester) async {
      final database = await pumpScreen(tester, const ParticipantsScreen(),
          size: Size(width, 844));
      const code = 'WEB-f065c683-a78b-4336-b7fe-60432d8131c7';
      await database.insertParticipant(Participant(
        id: 'phone-participant',
        projectId: 'missing',
        code: code,
        name: 'Mary kho',
        hasConsented: true,
        createdAt: DateTime.utc(2026, 9, 20),
        syncStatus: SyncStatus.pending,
      ));
      final container = ProviderScope.containerOf(
          tester.element(find.byType(ParticipantsScreen)));
      await container.read(participantsProvider.notifier).loadParticipants();
      await tester.pump();
      expect(find.text('Mary kho'), findsOneWidget);
      expect(find.text('CONSENTED'), findsOneWidget);
      expect(tester.getSize(find.text(code)).width, greaterThan(width - 60));
      expect(tester.getSize(find.text('Mary kho')).width, greaterThan(200));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets("LoginScreen() fits Size(320, 640)", (tester) async {
    await pumpScreen(tester, const LoginScreen(), size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("LoginScreen() fits Size(390, 844)", (tester) async {
    await pumpScreen(tester, const LoginScreen(), size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("LoginScreen() fits Size(740, 360)", (tester) async {
    await pumpScreen(tester, const LoginScreen(), size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("RegisterScreen() fits Size(320, 640)", (tester) async {
    await pumpScreen(tester, const RegisterScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("RegisterScreen() fits Size(390, 844)", (tester) async {
    await pumpScreen(tester, const RegisterScreen(),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("RegisterScreen() fits Size(740, 360)", (tester) async {
    await pumpScreen(tester, const RegisterScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DashboardScreen() fits Size(320, 640)", (tester) async {
    await pumpScreen(tester, const DashboardScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DashboardScreen() fits Size(390, 844)", (tester) async {
    await pumpScreen(tester, const DashboardScreen(),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DashboardScreen() fits Size(740, 360)", (tester) async {
    await pumpScreen(tester, const DashboardScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ParticipantsScreen() fits Size(320, 640)", (tester) async {
    await pumpScreen(tester, const ParticipantsScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ParticipantsScreen() fits Size(390, 844)", (tester) async {
    await pumpScreen(tester, const ParticipantsScreen(),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ParticipantsScreen() fits Size(740, 360)", (tester) async {
    await pumpScreen(tester, const ParticipantsScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ReportsScreen() fits Size(320, 640)", (tester) async {
    await pumpScreen(tester, const ReportsScreen(), size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ReportsScreen() fits Size(390, 844)", (tester) async {
    await pumpScreen(tester, const ReportsScreen(), size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ReportsScreen() fits Size(740, 360)", (tester) async {
    await pumpScreen(tester, const ReportsScreen(), size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("AnalyticsScreen(projectId: 'missing') fits Size(320, 640)",
      (tester) async {
    await pumpScreen(tester, const AnalyticsScreen(projectId: 'missing'),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("AnalyticsScreen(projectId: 'missing') fits Size(390, 844)",
      (tester) async {
    await pumpScreen(tester, const AnalyticsScreen(projectId: 'missing'),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("AnalyticsScreen(projectId: 'missing') fits Size(740, 360)",
      (tester) async {
    await pumpScreen(tester, const AnalyticsScreen(projectId: 'missing'),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DataTableScreen(projectId: 'missing') fits Size(320, 640)",
      (tester) async {
    await pumpScreen(tester, const DataTableScreen(projectId: 'missing'),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DataTableScreen(projectId: 'missing') fits Size(390, 844)",
      (tester) async {
    await pumpScreen(tester, const DataTableScreen(projectId: 'missing'),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("DataTableScreen(projectId: 'missing') fits Size(740, 360)",
      (tester) async {
    await pumpScreen(tester, const DataTableScreen(projectId: 'missing'),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ProjectDetailScreen(projectId: 'missing') fits Size(320, 640)",
      (tester) async {
    await pumpScreen(tester, const ProjectDetailScreen(projectId: 'missing'),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ProjectDetailScreen(projectId: 'missing') fits Size(390, 844)",
      (tester) async {
    await pumpScreen(tester, const ProjectDetailScreen(projectId: 'missing'),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ProjectDetailScreen(projectId: 'missing') fits Size(740, 360)",
      (tester) async {
    await pumpScreen(tester, const ProjectDetailScreen(projectId: 'missing'),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      "QuestionnaireBuilderScreen(questionnaireId: 'missing') fits Size(320, 640)",
      (tester) async {
    await pumpScreen(
        tester, const QuestionnaireBuilderScreen(questionnaireId: 'missing'),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      "QuestionnaireBuilderScreen(questionnaireId: 'missing') fits Size(390, 844)",
      (tester) async {
    await pumpScreen(
        tester, const QuestionnaireBuilderScreen(questionnaireId: 'missing'),
        size: const Size(390, 844));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      "QuestionnaireBuilderScreen(questionnaireId: 'missing') fits Size(740, 360)",
      (tester) async {
    await pumpScreen(
        tester, const QuestionnaireBuilderScreen(questionnaireId: 'missing'),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("SettingsScreen() fits 320x640", (tester) async {
    await pumpScreen(tester, const SettingsScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("SettingsScreen() fits 740x360", (tester) async {
    await pumpScreen(tester, const SettingsScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ProjectsScreen() fits 320x640", (tester) async {
    await pumpScreen(tester, const ProjectsScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("ProjectsScreen() fits 740x360", (tester) async {
    await pumpScreen(tester, const ProjectsScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("QuestionnairesScreen() fits 320x640", (tester) async {
    await pumpScreen(tester, const QuestionnairesScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("QuestionnairesScreen() fits 740x360", (tester) async {
    await pumpScreen(tester, const QuestionnairesScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("SupervisorScreen() fits 320x640", (tester) async {
    await pumpScreen(tester, const SupervisorScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("SupervisorScreen() fits 740x360", (tester) async {
    await pumpScreen(tester, const SupervisorScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets("InterviewsScreen() fits 320x640", (tester) async {
    await pumpScreen(tester, const InterviewsScreen(),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets("InterviewsScreen() fits 740x360", (tester) async {
    await pumpScreen(tester, const InterviewsScreen(),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      "DataCollectionScreen(questionnaireId: 'missing-questionnaire') fits 320x640",
      (tester) async {
    await pumpScreen(tester,
        const DataCollectionScreen(questionnaireId: 'missing-questionnaire'),
        size: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      "DataCollectionScreen(questionnaireId: 'missing-questionnaire') fits 740x360",
      (tester) async {
    await pumpScreen(tester,
        const DataCollectionScreen(questionnaireId: 'missing-questionnaire'),
        size: const Size(740, 360));
    expect(tester.takeException(), isNull);
  });
  for (final screen in [const LoginScreen(), const RegisterScreen()]) {
    testWidgets('${screen.runtimeType} supports keyboard and larger text',
        (tester) async {
      await pumpScreen(tester, screen,
          size: const Size(320, 640), textScale: 1.3);
      final field = find.byType(TextFormField).first;
      await tester.ensureVisible(field);
      await tester.tap(field);
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();
      await tester.ensureVisible(find.byType(ElevatedButton).last);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('settings tabs stay readable on a phone', (tester) async {
    await pumpScreen(tester, const SettingsScreen());

    expect(find.text('Settings'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(TabBar), const Offset(-600, 0));
    await tester.pump(const Duration(milliseconds: 500));
    final databaseTab = find.text('Database & Storage Health');
    await tester.ensureVisible(databaseTab);
    await tester.tap(databaseTab);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Database Tools & Mock Data'), findsOneWidget);
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
