import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';

import '../state_management/mosque_admin_donation_provider.dart';
import '../state_management/mosque_admin_mosque_provider.dart';
import '../widgets/mosque_admin_form_widgets.dart';

/// Create / edit a fundraising campaign (devis B3). Max 3 active campaigns
/// (enforced server-side too). On creation the admin can push followers.
@RoutePage()
class MosqueAdminCampaignFormPage extends HookConsumerWidget {
  const MosqueAdminCampaignFormPage({super.key, @QueryParam('campaignId') this.campaignId});

  final int? campaignId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final snackbar = ref.read(snackbarProvider);
    final presenter = ref.read(mosqueAdminDonationProvider.notifier);
    final state = ref.watch(mosqueAdminDonationProvider);
    final mosqueAdmin = ref.read(mosqueAdminMosqueProvider.notifier);
    final quota = ref.watch(mosqueAdminMosqueProvider.select((s) => s.quota));

    final existing = campaignId == null ? null : state.campaigns.where((c) => c.id == campaignId).firstOrNull;
    final isEdit = existing != null;

    final draft = useState<MosqueCampaignDraft>(
      existing != null ? MosqueCampaignDraft.fromModel(existing) : MosqueCampaignDraft(endsAt: DateTime.now().add(const Duration(days: 30))),
    );
    final title = useTextEditingController(text: existing?.title ?? '');
    final description = useTextEditingController(text: existing?.description ?? '');
    final goal = useTextEditingController(text: existing == null ? '' : existing.goalAmount.round().toString());
    final amounts = useTextEditingController(text: (existing?.suggestedAmounts ?? const [10, 50, 100, 150]).join(', '));
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

    Future<void> pickCover() async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
      if (x == null) return;
      uploading.value = true;
      final url = await mosqueAdmin.upload(File(x.path), folder: 'campaigns');
      uploading.value = false;
      if (url != null) draft.value = draft.value.copyWith(coverUrl: url);
    }

    Future<void> pickEnd() async {
      final d = await showDatePicker(
        context: context,
        initialDate: draft.value.endsAt.isAfter(DateTime.now()) ? draft.value.endsAt : DateTime.now().add(const Duration(days: 7)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (d != null) draft.value = draft.value.copyWith(endsAt: DateTime(d.year, d.month, d.day, 23, 59));
    }

    List<int> parseAmounts(String s) =>
        s.split(RegExp(r'[,\s;]+')).map((e) => int.tryParse(e.trim())).whereType<int>().where((e) => e > 0).toSet().toList()..sort();

    Future<void> submit() async {
      final g = double.tryParse(goal.text.replaceAll(',', '.')) ?? 0;
      final d = draft.value.copyWith(
        title: title.text,
        description: description.text,
        goalAmount: g,
        suggestedAmounts: parseAmounts(amounts.text).isEmpty ? const [10, 50, 100, 150] : parseAmounts(amounts.text).take(6).toList(),
      );
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

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: isEdit ? l10n.mosque_admin_campaign_edit : l10n.mosque_admin_campaign_new,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          UIButton.primary(
            label: isEdit ? l10n.common_save : l10n.mosque_admin_campaign_launch,
            isSmall: true,
            isBusy: state.busy || uploading.value,
            onTap: title.text.trim().isEmpty || goal.text.trim().isEmpty ? null : submit,
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
            const SizedBox(height: 16),
            AdminLabel(l10n.mosque_admin_sadaqa_amounts),
            UIInputField(
              controller: amounts,
              hintText: '10, 50, 100, 150',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,\s]'))],
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
