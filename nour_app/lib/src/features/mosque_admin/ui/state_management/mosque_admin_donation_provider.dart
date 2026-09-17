import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';

/// Admin "Donation" tab + sub-pages (devis B1–B7): Stripe Connect status,
/// Sadaqa settings, campaigns, analytics.
class MosqueAdminDonationState extends Equatable {
  final bool isLoading;
  final bool loaded;
  final MosqueStripeAccount stripe;
  final MosqueDonationSettings? settings;
  final MosqueCampaignSettings? campaignSettings;
  final List<MosqueCampaignModel> campaigns;
  final MosqueDonationStats? stats;

  /// What the mosque's country allows for tax receipts + what is still missing.
  /// docs/TAX_RECEIPTS_MULTI_COUNTRY.md
  final MosqueTaxReadiness? taxReadiness;
  final int year;
  final bool busy;

  const MosqueAdminDonationState({
    this.isLoading = false,
    this.loaded = false,
    this.stripe = const MosqueStripeAccount(),
    this.settings,
    this.campaignSettings,
    this.campaigns = const [],
    this.stats,
    this.taxReadiness,
    this.year = 0,
    this.busy = false,
  });

  bool get donationsReady => stripe.chargesEnabled;
  List<MosqueCampaignModel> get activeCampaigns => campaigns.where((c) => c.status == MosqueCampaignStatus.active).toList();
  List<MosqueCampaignModel> get pastCampaigns => campaigns.where((c) => c.status != MosqueCampaignStatus.active).toList();
  bool get canCreateCampaign => activeCampaigns.length < 3;

  MosqueAdminDonationState copyWith({
    bool? isLoading,
    bool? loaded,
    MosqueStripeAccount? stripe,
    MosqueDonationSettings? settings,
    MosqueCampaignSettings? campaignSettings,
    List<MosqueCampaignModel>? campaigns,
    MosqueDonationStats? stats,
    MosqueTaxReadiness? taxReadiness,
    int? year,
    bool? busy,
  }) =>
      MosqueAdminDonationState(
        isLoading: isLoading ?? this.isLoading,
        loaded: loaded ?? this.loaded,
        stripe: stripe ?? this.stripe,
        settings: settings ?? this.settings,
        campaignSettings: campaignSettings ?? this.campaignSettings,
        campaigns: campaigns ?? this.campaigns,
        stats: stats ?? this.stats,
        taxReadiness: taxReadiness ?? this.taxReadiness,
        year: year ?? this.year,
        busy: busy ?? this.busy,
      );

  @override
  List<Object?> get props =>
      [isLoading, loaded, stripe, settings, campaignSettings, campaigns, stats, taxReadiness, year, busy];
}

final mosqueAdminDonationProvider = StateNotifierProvider<MosqueAdminDonationPresenter, MosqueAdminDonationState>((ref) {
  return MosqueAdminDonationPresenter(ref: ref, repo: ref.read(mosqueRepoProvider), appEvents: ref.read(appEventProvider));
});

class MosqueAdminDonationPresenter extends Presenter<MosqueAdminDonationState> {
  MosqueAdminDonationPresenter({required this.ref, required this.repo, required this.appEvents})
      : super(MosqueAdminDonationState(year: DateTime.now().year));

  final Ref ref;
  final MosqueRepo repo;
  final AppEvents appEvents;

  int? get _mosqueId => ref.read(myMosqueProvider).mosque?.id;

  Future<void> init() async {
    if (state.loaded || state.isLoading) return;
    await refresh();
  }

  Future<void> refresh({bool syncStripe = false}) async {
    final id = _mosqueId;
    if (id == null) return;
    state = state.copyWith(isLoading: true);

    // Stripe: the DB row is the cheap truth; a live sync is requested after
    // returning from the hosted onboarding.
    final stripeRes = syncStripe ? await repo.refreshStripeStatus(id) : await repo.getStripeAccount(id);
    if (!mounted) return;
    final stripe = stripeRes.when((v) => v, (e) {
      if (syncStripe) appEvents.send(ShowErrorEvent(e));
      return state.stripe;
    });
    if (syncStripe && stripe.chargesEnabled) {
      // donations_enabled flipped server-side → refresh the cached mosque.
      await ref.read(myMosqueProvider.notifier).load();
    }

    final settingsRes = await repo.getDonationSettings(id);
    final campaignSettingsRes = await repo.getCampaignSettings(id);
    final readinessRes = await repo.getTaxReadiness(id);
    final campaignsRes = await repo.getCampaigns(id);
    final statsRes = stripe.hasAccount ? await repo.getDonationStats(id, year: state.year) : null;
    if (!mounted) return;

    state = state.copyWith(
      isLoading: false,
      loaded: true,
      stripe: stripe,
      settings: settingsRes.when((v) => v, (_) => state.settings ?? MosqueDonationSettings(mosqueId: id)),
      campaignSettings: campaignSettingsRes.when((v) => v, (_) => state.campaignSettings ?? MosqueCampaignSettings(mosqueId: id)),
      campaigns: campaignsRes.when((v) => v, (_) => state.campaigns),
      taxReadiness: readinessRes.when((v) => v, (e) {
        talker.error('[mosque-admin] tax readiness', e);
        return state.taxReadiness;
      }),
      stats: statsRes?.when((v) => v, (e) {
        talker.error('[mosque-admin] stats', e);
        return state.stats;
      }),
    );
  }

  Future<void> setYear(int year) async {
    final id = _mosqueId;
    if (id == null) return;
    state = state.copyWith(year: year);
    final res = await repo.getDonationStats(id, year: year);
    if (!mounted) return;
    res.when((v) => state = state.copyWith(stats: v), (e) => appEvents.send(ShowErrorEvent(e)));
  }

  /// Returns the hosted onboarding URL (Stripe Express).
  ///
  /// It no longer carries the tax-receipt right: that is a legal attribute with
  /// its own audited entry point ([setTaxReceipts]), not a payments one.
  Future<String?> startStripeOnboarding() async {
    final id = _mosqueId;
    if (id == null || state.busy) return null;
    state = state.copyWith(busy: true);
    final res = await repo.startStripeOnboarding(id);
    if (!mounted) return null;
    state = state.copyWith(busy: false);
    return res.when((url) => url, (e) {
      appEvents.send(ShowErrorEvent(e));
      return null;
    });
  }

  // ── Tax receipts ──────────────────────────────────────────────────────────

  Future<void> refreshTaxReadiness() async {
    final id = _mosqueId;
    if (id == null) return;
    final res = await repo.getTaxReadiness(id);
    if (!mounted) return;
    res.when((v) => state = state.copyWith(taxReadiness: v), (e) => talker.error('[mosque-admin] tax readiness', e));
  }

  /// Declares (or withdraws) the right to issue tax receipts. Every call is
  /// recorded server-side with the caller and the version of the legal text
  /// they accepted; [declarationVersion] is that version.
  Future<bool> setTaxReceipts(bool enabled, {required String declarationVersion}) async {
    final id = _mosqueId;
    if (id == null || state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.setTaxReceipts(id, enabled, declarationVersion: declarationVersion);
    if (!mounted) return false;
    state = state.copyWith(busy: false);
    return await res.when((_) async {
      // The flag lives on the mosque row and gates several screens.
      await ref.read(myMosqueProvider.notifier).load(silent: true);
      await refreshTaxReadiness();
      return true;
    }, (e) async {
      appEvents.send(ShowErrorEvent(e));
      return false;
    });
  }

  Future<bool> saveSignatory({String? name, String? role, String? signaturePath}) async {
    final id = _mosqueId;
    if (id == null || state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.saveSignatory(id, name: name, role: role, signaturePath: signaturePath);
    if (!mounted) return false;
    state = state.copyWith(busy: false);
    return await res.when((_) async {
      await ref.read(myMosqueProvider.notifier).load(silent: true);
      await refreshTaxReadiness();
      return true;
    }, (e) async {
      appEvents.send(ShowErrorEvent(e));
      return false;
    });
  }

  /// Uploads the signature image and stores its path in one go.
  Future<bool> uploadSignature(File file, {String? name, String? role}) async {
    final id = _mosqueId;
    if (id == null || state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.uploadSignature(mosqueId: id, file: file);
    if (!mounted) return false;
    final path = res.when((p) => p, (e) {
      appEvents.send(ShowErrorEvent(e));
      return null;
    });
    state = state.copyWith(busy: false);
    if (path == null) return false;
    return saveSignatory(name: name, role: role, signaturePath: path);
  }

  Future<MosqueTaxYearSummary?> taxYearSummary(int year) async {
    final id = _mosqueId;
    if (id == null) return null;
    final res = await repo.getTaxYearSummary(id, year);
    return res.when((v) => v, (e) {
      appEvents.send(ShowErrorEvent(e));
      return null;
    });
  }

  Future<bool> saveSettings(MosqueDonationSettings s) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.saveDonationSettings(s);
    if (!mounted) return false;
    return res.when((saved) {
      state = state.copyWith(busy: false, settings: saved);
      return true;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(busy: false);
      return false;
    });
  }

  /// Fundraising settings — the campaigns' own configuration. Saving them does
  /// NOT touch the campaigns already running: an active campaign keeps the
  /// amounts / frequencies it was launched with until it is edited.
  Future<bool> saveCampaignSettings(MosqueCampaignSettings s) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.saveCampaignSettings(s);
    if (!mounted) return false;
    return res.when((saved) {
      state = state.copyWith(busy: false, campaignSettings: saved);
      return true;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(busy: false);
      return false;
    });
  }

  Future<MosqueCampaignModel?> saveCampaign(MosqueCampaignDraft d) async {
    final id = _mosqueId;
    if (id == null || state.busy) return null;
    state = state.copyWith(busy: true);
    final res = d.id == null ? await repo.createCampaign(id, d) : await repo.updateCampaign(id, d);
    if (!mounted) return null;
    return res.when((c) {
      _upsert(c);
      state = state.copyWith(busy: false);
      return c;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(busy: false);
      return null;
    });
  }

  Future<MosqueCampaignModel?> extendCampaign(int campaignId, DateTime endsAt) async {
    if (state.busy) return null;
    state = state.copyWith(busy: true);
    final res = await repo.extendCampaign(campaignId, endsAt);
    if (!mounted) return null;
    return res.when((c) {
      _upsert(c);
      state = state.copyWith(busy: false);
      return c;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(busy: false);
      return null;
    });
  }

  Future<MosqueCampaignModel?> closeCampaign(int campaignId) async {
    if (state.busy) return null;
    state = state.copyWith(busy: true);
    final res = await repo.closeCampaign(campaignId);
    if (!mounted) return null;
    return res.when((c) {
      _upsert(c);
      state = state.copyWith(busy: false);
      return c;
    }, (e) {
      appEvents.send(ShowErrorEvent(e));
      state = state.copyWith(busy: false);
      return null;
    });
  }

  /// Posts a progress update and (optionally) notifies followers — the push
  /// counts against the weekly broadcast quota.
  Future<bool> postCampaignUpdate({required int campaignId, required String body, String? imageUrl, bool notify = false}) async {
    final id = _mosqueId;
    if (id == null || state.busy) return false;
    state = state.copyWith(busy: true);
    final res = await repo.postCampaignUpdate(mosqueId: id, campaignId: campaignId, body: body, imageUrl: imageUrl);
    if (!mounted) return false;
    final ok = res.when((_) => true, (e) {
      appEvents.send(ShowErrorEvent(e));
      return false;
    });
    if (ok && notify) {
      final c = state.campaigns.where((c) => c.id == campaignId).firstOrNull;
      final n = await repo.notifyFollowers(mosqueId: id, campaignId: campaignId, title: c?.title, body: body);
      n.when((_) {}, (e) => appEvents.send(ShowErrorEvent(e)));
    }
    if (mounted) state = state.copyWith(busy: false);
    return ok;
  }

  /// Push "campaign launched" to followers (called right after creation).
  Future<void> announceCampaign(MosqueCampaignModel c) async {
    final id = _mosqueId;
    if (id == null) return;
    final res = await repo.notifyFollowers(mosqueId: id, campaignId: c.id);
    res.when((_) {}, (e) => appEvents.send(ShowErrorEvent(e)));
  }

  void _upsert(MosqueCampaignModel c) {
    final list = [...state.campaigns];
    final i = list.indexWhere((e) => e.id == c.id);
    if (i >= 0) {
      list[i] = c;
    } else {
      list.insert(0, c);
    }
    state = state.copyWith(campaigns: list);
  }
}
