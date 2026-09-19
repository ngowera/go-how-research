import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gohow_research/core/database/app_database.dart';
import 'package:gohow_research/features/data_collection/screens/data_collection_screen.dart';
import 'package:gohow_research/features/settings/screens/settings_screen.dart';
import 'package:gohow_research/features/supervisor/screens/supervisor_screen.dart';
import 'package:gohow_research/shared/widgets/research_expert.dart';

void main() {
  const phoneSize = Size(390, 844);

  Future<AppDatabase> pumpScreen(
    WidgetTester tester,
    Widget screen,
  ) async {
    final database = AppDatabase();
    addTearDown(database.close);
    await tester.binding.setSurfaceSize(phoneSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pumpAndSettle();
    return database;
  }

  testWidgets('settings tabs stay readable on a phone', (tester) async {
    await pumpScreen(tester, const SettingsScreen());

    expect(find.text('Settings & System Hub'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(TabBar), const Offset(-280, 0));
    await tester.pumpAndSettle();
    final databaseTab = find.text('Database & Storage Health');
    await tester.ensureVisible(databaseTab);
    await tester.tap(databaseTab);
    await tester.pumpAndSettle();

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
        find.text('This questionnaire has no questions yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supervisor screen stays readable on a phone', (tester) async {
    await pumpScreen(tester, const SupervisorScreen());

    expect(find.text('Supervisor Collaboration Portal'), findsOneWidget);
    expect(find.text('Supervised Projects'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Research Expert uses the mobile-safe prompt', (tester) async {
    await pumpScreen(tester, const ResearchExpertDialog());

    expect(find.text('Research Expert'), findsWidgets);
    expect(
        find.widgetWithText(TextField, 'Ask Research Expert'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
