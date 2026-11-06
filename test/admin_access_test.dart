import 'package:flutter_test/flutter_test.dart';
import 'package:gohow_research/core/config/admin_access.dart';
import 'package:gohow_research/core/providers/billing_provider.dart';

void main() {
  test('admin email matching ignores case and surrounding spaces', () {
    expect(isAdminAccountEmail(' NGOWELAK@GMAIL.COM '), isTrue);
    expect(isAdminAccountEmail('someone@example.com'), isFalse);
    expect(isAdminAccountEmail(null), isFalse);
  });

  test('admin billing state unlocks every commercial feature', () {
    const billing = BillingState(isAdmin: true);

    expect(billing.planName, 'Admin');
    expect(billing.hasAnalytics, isTrue);
    expect(billing.hasExports, isTrue);
    expect(billing.hasUnlimitedProjects, isTrue);
    expect(billing.hasUnlimitedQuestionnaires, isTrue);
    expect(billing.hasUnlimitedStorage, isTrue);
  });
}
