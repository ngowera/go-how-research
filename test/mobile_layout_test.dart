import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';

import 'package:gohow_research/core/database/app_database.dart';
import 'package:gohow_research/features/data_collection/screens/data_collection_screen.dart';
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

  testWidgets('supervisor screen stays readable on a phone', (tester) async {
    await pumpScreen(tester, const SupervisorScreen());

    expect(find.text('Supervisor Collaboration Portal'), findsOneWidget);
    expect(find.text('Supervised Projects'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Research Assistant uses the mobile-safe prompt', (tester) async {
    await pumpScreen(tester, const ResearchAssistantPanel());

    expect(find.text('Research Assistant'), findsWidgets);
    expect(find.widgetWithText(TextField, 'Ask RA'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

    expect(find.text('RA'), findsOneWidget);
    await tester.tap(find.text('RA'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Current research screen'), findsOneWidget);
    expect(find.text('Research Assistant'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Ask RA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
