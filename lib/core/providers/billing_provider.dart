import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionTier { free, plus, pro }

class BillingState {
  const BillingState({
    this.tier = SubscriptionTier.free,
    this.validUntil,
    this.freePublishUsedAt,
    this.isAdmin = false,
    this.isLoading = false,
    this.error,
  });

  final SubscriptionTier tier;
  final DateTime? validUntil;
  final DateTime? freePublishUsedAt;
  final bool isAdmin;
  final bool isLoading;
  final String? error;

  // Go-How Research is free to use; these getters remain for compatibility
  // with existing screens while all in-app features stay available.
  bool get hasAnalytics => true;
  bool get hasExports => true;
  bool get hasUnlimitedProjects => true;
  bool get hasUnlimitedQuestionnaires => true;
  bool get hasUnlimitedStorage => true;
  String get planName => isAdmin
      ? 'Admin'
      : switch (tier) {
          SubscriptionTier.free => 'Free',
          SubscriptionTier.plus => 'Plus',
          SubscriptionTier.pro => 'Pro',
        };

  BillingState copyWith({
    SubscriptionTier? tier,
    DateTime? validUntil,
    DateTime? freePublishUsedAt,
    bool? isAdmin,
    bool? isLoading,
    String? error,
    bool clearDates = false,
  }) =>
      BillingState(
        tier: tier ?? this.tier,
        validUntil: clearDates ? null : validUntil ?? this.validUntil,
        freePublishUsedAt:
            clearDates ? null : freePublishUsedAt ?? this.freePublishUsedAt,
        isAdmin: isAdmin ?? this.isAdmin,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier() : super(const BillingState()) {
    refresh();
  }

  Future<void> refresh() async {
    // Feature access is free for every account. Keep this provider's shape for
    // compatibility with any older widgets, but never consult server billing.
    state = const BillingState();
  }
}

final billingProvider =
    StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  return BillingNotifier();
});
