import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gohow_research/core/router/app_router.dart';
import 'package:gohow_research/features/questionnaires/screens/public_questionnaire_screen.dart';

void main() {
  testWidgets('signed-out participant deep link bypasses researcher login', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/kondwani001');
    await tester.pumpWidget(UncontrolledProviderScope(container:container,
      child:MaterialApp.router(routerConfig:router)));
    await tester.pumpAndSettle();
    expect(find.byType(PublicQuestionnaireScreen),findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path,'/kondwani001');
  });
}
