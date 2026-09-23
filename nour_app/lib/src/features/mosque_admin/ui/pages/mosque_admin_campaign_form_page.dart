import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/routing/navigation_services_provider.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../state_management/mosque_admin_mosque_provider.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// Create / edit a fundraising campaign (devis B3). Max 3 active campaigns
/// (enforced server-side too). On creation the admin can push followers.
///
/// A campaign carries ITS OWN amounts / frequencies / tax badge: a new one is
/// seeded from the mosque's fundraising settings (never from the Sadaqa card)
/// and can then diverge. The frequencies a campaign may offer are still capped
/// by what the mosque enabled in the fundraising settings.
@RoutePage()
class MosqueAdminCampaignFormPage extends HookConsumerWidget {
  const MosqueAdminCampaignFormPage({super.key, @QueryParam('campaignId') this.campaignId});

  final int? campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final nav = ref.read(navigationServicesProvider);
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosqueAdmin = ref.read(mosqueAdminMosqueProvider.notifier);
    final quota = ref.watch(mosqueAdminMosqueProvider.select((s) => s.quota));
    final canIssueReceipts = ref.watch(myMosqueProvider.select((s) => s.mosque?.canIssueTaxReceipts ?? false));

    final existing = campaignId == null ? null : state.campaigns.where((c) => c.id == campaignId).firstOrNull;
    final isEdit = existing != null;
    final settings = state.campaignSettings;

    final draft = useState<MosqueCampaignDraft>(
      existing != null ? MosqueCampaignDraft.fromModel(existing) : MosqueCampaignDraft.fromSettings(settings),
    );
    final title = useTextEditingController(text: existing?.title ?? '');
    final description = useTextEditingController(text: existing?.description ?? '');
    final goal = useTextEditingController(text: existing == null ? '' : existing.goalAmount.round().toString());
    final amounts = useState<List<int>>(List.of(existing?.amountsOrDefault ?? settings?.amountsOrDefault ?? kDefaultCampaignAmounts));
    final notify = useState(!isEdit);
    final uploading = useState(false);
    useListenable(title);
    useListenable(goal);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        presenter.init();
        mosqueAdmin.loadQuota();
      });
      return null;
    }, const []);

    // The fundraising settings land after the first build on a cold start: a
    // NEW campaign re-seeds from them, an edited one keeps its own values.
    useEffect(() {
      if (!isEdit && settings != null) {
        draft.value = MosqueCampaignDraft.fromSettings(settings).copyWith(
          title: draft.value.title,
          description: draft.value.description,
          coverUrl: draft.value.coverUrl,
          goalAmount: draft.value.goalAmount,
          endsAt: draft.value.endsAt,
        );
        amounts.value = List.of(settings.amountsOrDefault);
      }
      return null;
    }, [settings]);

    // Same for the campaign itself (the list may still be loading).
    useEffect(() {
      if (existing != null) {
        draft.value = MosqueCampaignDraft.fromModel(existing);
        title.text = existing.title;
        description.text = existing.description ?? '';
        goal.text = existing.goalAmount.round().toString();
        amounts.value = List.of(existing.amountsOrDefault);
      }
      return null;
    }, [existing?.id]);

    // A campaign can only START offering what the mosque enabled globally — but
    // one it already offers stays available, so turning a frequency off
    // mosque-wide never silently strips a running campaign on an unrelated edit
    // (its donors may already have a subscription on it).
    final canOneTime = (settings?.allowOneTime ?? true) || (existing?.allowOneTime ?? false);
    final canMonthly = (settings?.allowMonthly ?? false) || (existing?.allowMonthly ?? false);
    final canYearly = (settings?.allowYearly ?? false) || (existing?.allowYearly ?? false);

    Future<void> pickCover() async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
      if (x == null) return;
      uploading.value = true;
      final url = await mosqueAdmin.upload(File(x.path), folder: 'campaigns');
      uploading.value = false;
      if (url != null) draft.value = draft.value.copyWith(coverUrl: url);
    }

    Future<void> pickEnd() async {
      final d = await UIPickers.date(
        context,
        initialDate: draft.value.endsAt.isAfter(DateTime.now()) ? draft.value.endsAt : DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d != null) draft.value = draft.value.copyWith(endsAt: DateTime(d.year, d.month, d.day, 23, 59));
    }

    Future<void> submit() async {
      final g = double.tryParse(goal.text.replaceAll(',', '.')) ?? 0;
      final suggested = (amounts.value.where((a) => a > 0).toSet().toList()..sort()).take(kCampaignMaxAmounts).toList();
      final d = draft.value.copyWith(
        title: title.text,
        description: description.text,
        goalAmount: g,
        suggestedAmounts: suggested.isEmpty ? (settings?.amountsOrDefault ?? kDefaultCampaignAmounts) : suggested,
        // Never send a frequency this campaign may not offer.
        allowOneTime: draft.value.allowOneTime && canOneTime,
        allowMonthly: draft.value.allowMonthly && canMonthly,
        allowYearly: draft.value.allowYearly && canYearly,
        showTaxBadge: draft.value.showTaxBadge && canIssueReceipts,
      );
      if (!d.hasFrequency) {
        snackbar.showError(l10n.mosque_admin_sadaqa_frequency_required);
        return;
      }
      if (!d.isValid) {
        snackbar.showError(l10n.mosque_admin_campaign_invalid);
        return;
      }
      if (!isEdit && !state.canCreateCampaign) {
        snackbar.showError(l10n.error_api_mosque_campaign_limit_reached);
        return;
      }
      final saved = await presenter.saveCampaign(d);
      if (saved == null) return;
      if (!isEdit && notify.value) await presenter.announceCampaign(saved);
      snackbar.showSuccess(isEdit ? l10n.mosque_admin_profile_saved : l10n.mosque_admin_campaign_created);
      if (context.mounted) context.router.maybePop();
    }

    return Scaffold(
      appBar: UIAppBar(
        title: isEdit ? l10n.mosque_admin_campaign_edit : l10n.mosque_admin_campaign_new,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          SizedBox(
            height: 35,
            child: UIButton.primary(
              label: isEdit ? l10n.common_save : l10n.mosque_admin_campaign_launch,
              isSmall: true,
              isBusy: state.busy || uploading.value,
              onTap: title.text.trim().isEmpty || goal.text.trim().isEmpty ? null : submit,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminLabel(l10n.mosque_post_cover_photo, optional: true, l10n: l10n),
            AdminCoverBox(url: draft.value.coverUrl, onTap: pickCover, placeholder: l10n.mosque_post_add_cover, busy: uploading.value),
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_admin_campaign_title_label),
            UIInputField(controller: title, hintText: l10n.mosque_admin_campaign_title_hint),
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_post_description, optional: true, l10n: l10n),
            AdminTextArea(controller: description, hint: l10n.mosque_admin_campaign_description_hint),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminLabel(l10n.mosque_admin_campaign_goal),
                      UIInputField(
                        controller: goal,
                        hintText: '5000',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdminLabel(l10n.mosque_admin_campaign_ends),
                      AdminPickerBox(icon: Icons.calendar_today_outlined, text: MosqueFormat.longDate(draft.value.endsAt, lang), onTap: pickEnd),
                    ],
                  ),
                ),
              ],
            ),

            // ── This campaign's amounts (seeded from the fundraising settings) ──
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: AdminLabel(l10n.mosque_admin_sadaqa_amounts)),
                if (settings != null)
                  UIButton.textual(
                    label: l10n.mosque_admin_campaign_amounts_reset,
                    isSmall: true,
                    onTap: () => amounts.value = List.of(settings.amountsOrDefault),
                  ),
              ],
            ),
            AdminAmountsEditor(
              values: amounts.value,
              onChanged: (v) => amounts.value = v,
              addLabel: l10n.mosque_admin_sadaqa_add_amount,
              maxItems: kCampaignMaxAmounts,
            ),
            const SizedBox(height: 8),
            Text(l10n.mosque_admin_campaign_amounts_hint, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),

            // ── This campaign's frequencies ─────────────────────────────────
            const SizedBox(height: 20),
            AdminLabel(l10n.mosque_admin_fundraising_frequencies),
            AdminToggleRow(
              title: l10n.donate_frequency_one_time,
              subtitle: canOneTime ? l10n.mosque_admin_fundraising_one_time_hint : l10n.mosque_admin_campaign_frequency_locked,
              value: draft.value.allowOneTime && canOneTime,
              enabled: canOneTime,
              onChanged: (v) => draft.value = draft.value.copyWith(allowOneTime: v),
            ),
            const SizedBox(height: 8),
            AdminToggleRow(
              title: l10n.mosque_admin_fundraising_monthly,
              subtitle: canMonthly ? l10n.mosque_admin_fundraising_monthly_hint : l10n.mosque_admin_campaign_frequency_locked,
              value: draft.value.allowMonthly && canMonthly,
              enabled: canMonthly,
              onChanged: (v) => draft.value = draft.value.copyWith(allowMonthly: v),
            ),
            const SizedBox(height: 8),
            AdminToggleRow(
              title: l10n.mosque_admin_fundraising_yearly,
              subtitle: canYearly ? l10n.mosque_admin_fundraising_yearly_hint : l10n.mosque_admin_campaign_frequency_locked,
              value: draft.value.allowYearly && canYearly,
              enabled: canYearly,
              onChanged: (v) => draft.value = draft.value.copyWith(allowYearly: v),
            ),
            const SizedBox(height: 8),
            UIButton.textual(
              label: l10n.mosque_admin_fundraising_settings_title,
              isSmall: true,
              onTap: nav.toMosqueAdminFundraisingSettings,
            ),

            // ── Tax badge ───────────────────────────────────────────────────
            const SizedBox(height: 12),
            AdminToggleRow(
              title: l10n.mosque_admin_sadaqa_tax_badge,
              subtitle: canIssueReceipts ? l10n.mosque_admin_sadaqa_tax_badge_hint : l10n.mosque_admin_sadaqa_tax_badge_locked,
              value: draft.value.showTaxBadge && canIssueReceipts,
              enabled: canIssueReceipts,
              onChanged: (v) => draft.value = draft.value.copyWith(showTaxBadge: v),
            ),

            if (!isEdit) ...[
              const SizedBox(height: 20),
              AdminToggleRow(
                title: l10n.mosque_admin_campaign_notify,
                subtitle: quota == null
                    ? l10n.mosque_admin_campaign_notify_hint
                    : quota.exhausted
                        ? l10n.error_api_mosque_broadcast_quota_exceeded
                        : l10n.mosque_post_quota_left(quota.remaining, quota.limit),
                value: notify.value && !(quota?.exhausted ?? false),
                enabled: !(quota?.exhausted ?? false),
                onChanged: (v) => notify.value = v,
              ),
            ],
            const SizedBox(height: 16),
            Text(l10n.mosque_admin_campaign_limit_note, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
          ],
        ),
      ),
    );
  }
}
