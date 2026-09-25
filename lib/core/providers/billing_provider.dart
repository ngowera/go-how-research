import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'auth_provider.dart';

enum SubscriptionTier { free, plus, pro }

class BillingState {
  const BillingState({
    this.tier = SubscriptionTier.free,
    this.validUntil,
    this.freePublishUsedAt,
    this.isLoading = false,
    this.error,
  });

  final SubscriptionTier tier;
  final DateTime? validUntil;
  final DateTime? freePublishUsedAt;
  final bool isLoading;
  final String? error;

  bool get hasAnalytics =>
      tier == SubscriptionTier.plus || tier == SubscriptionTier.pro;
  bool get hasExports => tier == SubscriptionTier.pro;
  bool get hasUnlimitedProjects => tier != SubscriptionTier.free;
  bool get hasUnlimitedQuestionnaires => tier != SubscriptionTier.free;
  String get planName => switch (tier) {
        SubscriptionTier.free => 'Free',
        SubscriptionTier.plus => 'Plus',
        SubscriptionTier.pro => 'Pro',
      };

  BillingState copyWith({
    SubscriptionTier? tier,
    DateTime? validUntil,
    DateTime? freePublishUsedAt,
    bool? isLoading,
    String? error,
    bool clearDates = false,
  }) =>
      BillingState(
        tier: tier ?? this.tier,
        validUntil: clearDates ? null : validUntil ?? this.validUntil,
        freePublishUsedAt:
            clearDates ? null : freePublishUsedAt ?? this.freePublishUsedAt,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class BillingNotifier extends StateNotifier<BillingState> {
  BillingNotifier(this._ref) : super(const BillingState()) {
    refresh();
  }

  final Ref _ref;

  Future<void> refresh() async {
    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = const BillingState();
      return;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      final row = await Supabase.instance.client
          .from('user_entitlements')
          .select('tier, valid_until, free_publish_used_at')
          .eq('user_id', user.id)
          .maybeSingle();
      final validUntil = row?['valid_until'] == null
          ? null
          : DateTime.tryParse(row!['valid_until'] as String)?.toLocal();
      final paidIsActive =
          validUntil != null && validUntil.isAfter(DateTime.now());
      final tierName = paidIsActive ? (row?['tier'] as String?) : null;
      state = BillingState(
        tier: tierName == 'pro'
            ? SubscriptionTier.pro
            : tierName == 'plus'
                ? SubscriptionTier.plus
                : SubscriptionTier.free,
        validUntil: paidIsActive ? validUntil : null,
        freePublishUsedAt: row?['free_publish_used_at'] == null
            ? null
            : DateTime.tryParse(row!['free_publish_used_at'] as String)
                ?.toLocal(),
      );
    } catch (_) {
      state = const BillingState(
        error: 'Connect to the internet to refresh your subscription.',
      );
    }
  }

  Future<void> purchase(SubscriptionTier tier) async {
    if (tier == SubscriptionTier.free) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'paychangu-checkout',
        body: {'tier': tier.name},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      final checkoutUrl = Uri.tryParse(data['checkoutUrl'] as String? ?? '');
      if (checkoutUrl == null ||
          !await launchUrl(checkoutUrl, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open PayChangu checkout.');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
    state = state.copyWith(isLoading: false);
  }
}

final billingProvider =
    StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  ref.watch(currentUserProvider.select((user) => user?.id));
  return BillingNotifier(ref);
});
