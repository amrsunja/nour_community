import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/islamic_tools/islamic_tools.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_post_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_profile_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_header.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_prayers_tab.dart';

import '../state_management/mosque_admin_mosque_provider.dart';
import '../widgets/audience_picker.dart';

/// Typed post form (Figma 1142:5343 "Post an event" — same layout for
/// volunteering / highlight / janaza). `postId` = edit mode.
@RoutePage()
class MosqueAdminPostFormPage extends HookConsumerWidget {
  const MosqueAdminPostFormPage({super.key, @PathParam('type') required this.type, this.postId});

  final String type;
  final int? postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final appEvents = ref.read(appEventProvider);
    final lang = Localizations.localeOf(context).languageCode;
    final mosque = ref.watch(myMosqueProvider).mosque;
    final admin = ref.read(mosqueAdminMosqueProvider.notifier);
    final quota = ref.watch(mosqueAdminMosqueProvider.select((s) => s.quota));
    final postType = MosquePostType.fromDb(type);

    final title = useTextEditingController();
    final body = useTextEditingController();
    final location = useTextEditingController(text: l10n.mosque_post_location_default);
    final volunteers = useTextEditingController();
    final language = useTextEditingController();
    final cover = useState<String?>(null);
    final audience = useState(MosquePostAudience.public);
    final date = useState<DateTime?>(null);
    final time = useState<TimeOfDay?>(null);
    final afterPrayer = useState<PrayerSlot?>(postType == MosquePostType.janaza ? PrayerSlot.dhuhr : null);
    final notify = useState(true);
    final urgent = useState(false);
    final busy = useState(false);
    final loaded = useState(postId == null);
    useListenable(title);

    useEffect(() {
      admin.loadQuota();
      if (postId != null) {
        ref.read(mosqueRepoProvider).getPost(postId!).then((res) => res.when((p) {
              title.text = p.title;
              body.text = p.body ?? '';
              location.text = p.location ?? '';
              volunteers.text = p.volunteersNeeded?.toString() ?? '';
              language.text = p.language ?? '';
              cover.value = p.coverUrl;
              audience.value = p.audience;
              date.value = p.eventDate;
              time.value = p.eventTime;
              afterPrayer.value = p.afterPrayer;
              urgent.value = p.isUrgent;
              notify.value = false;
              loaded.value = true;
            }, (e) => appEvents.send(ShowErrorEvent(e))));
      }
      return null;
    }, const []);

    final isEvent = postType == MosquePostType.event;
    final isVolunteering = postType == MosquePostType.volunteering;
    final isHighlight = postType == MosquePostType.highlight;
    final isJanaza = postType == MosquePostType.janaza;
    final needsDate = isEvent || isVolunteering || isJanaza;

    Future<void> pickCover() async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
      if (x == null) return;
      busy.value = true;
      cover.value = await admin.upload(File(x.path), folder: 'posts');
      busy.value = false;
    }

    Future<void> submit() async {
      if (mosque == null) return;
      if (title.text.trim().isEmpty) return;
      if (needsDate && date.value == null) {
        snackbar.showError(l10n.mosque_post_date_required);
        return;
      }
      if (isHighlight && cover.value == null) {
        snackbar.showError(l10n.mosque_post_cover_required);
        return;
      }
      busy.value = true;
      final repo = ref.read(mosqueRepoProvider);
      final draft = MosquePostDraft(
        mosqueId: mosque.id,
        type: postType,
        audience: audience.value,
        title: title.text,
        body: body.text,
        coverUrl: cover.value,
        isUrgent: urgent.value,
        eventDate: date.value,
        eventTime: time.value,
        location: location.text.trim().isEmpty ? null : location.text.trim(),
        afterPrayer: isJanaza ? afterPrayer.value : null,
        language: language.text.trim().isEmpty ? null : language.text.trim(),
        volunteersNeeded: int.tryParse(volunteers.text.trim()),
      );
      final res = postId == null
          ? await repo.createPost(draft)
          : await repo.updatePost(postId!, draft.toJson()..remove('status')..remove('mosque_id'));
      await res.when(
        (p) async {
          if (notify.value && postId == null) {
            final n = await admin.notifyPost(p);
            if (n != null) snackbar.showSuccess(l10n.mosque_post_notified(n));
          } else {
            snackbar.showSuccess(l10n.mosque_post_published);
          }
          ref.read(mosqueProfileProvider(mosque.id).notifier).loadPosts();
          busy.value = false;
          if (context.mounted) await context.router.maybePop();
        },
        (error) async {
          busy.value = false;
          appEvents.send(ShowErrorEvent(error));
        },
      );
    }

    final pageTitle = switch (postType) {
      MosquePostType.event => l10n.mosque_post_form_event,
      MosquePostType.volunteering => l10n.mosque_post_form_volunteering,
      MosquePostType.highlight => l10n.mosque_post_form_highlight,
      MosquePostType.janaza => l10n.mosque_post_form_janaza,
      MosquePostType.announcement => l10n.mosque_admin_create_post,
    };

    Widget label(String t, {bool optional = false}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(t, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
              if (optional) Text(' · ${l10n.common_optional}', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
        );

    Widget pickerBox(IconData icon, String text, VoidCallback onTap) => UITap(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(icon, size: 18, color: UIColorsToken.textParagraph),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: theme.typo.inter.body.copyWith(color: UIColorsToken.white))),
              ],
            ),
          ),
        );

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: pageTitle,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          UIButton.primary(label: l10n.mosque_admin_tab_post, isSmall: true, isBusy: busy.value, onTap: title.text.trim().isEmpty || !loaded.value ? null : submit),
        ],
      ),
      body: !loaded.value
          ? const Center(child: UICircularProgressBar())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (mosque != null) MosqueLogo(mosque: mosque, size: 40, radius: 20),
                      const SizedBox(width: 10),
                      Expanded(child: Text(mosque?.name ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white))),
                      AudiencePicker(value: audience.value, onChanged: (a) => audience.value = a, l10n: l10n),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (!isJanaza) ...[
                    label(l10n.mosque_post_cover_photo, optional: !isHighlight),
                    UITap(
                      onTap: pickCover,
                      child: Container(
                        height: cover.value == null ? 150 : 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .4)),
                          image: cover.value == null ? null : DecorationImage(image: NetworkImage(cover.value!), fit: BoxFit.cover),
                        ),
                        child: cover.value != null
                            ? null
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_outlined, color: UIColorsToken.textParagraph),
                                  const SizedBox(height: 6),
                                  Text(l10n.mosque_post_add_cover, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  UIInputField(
                    controller: title,
                    labelText: isEvent ? l10n.mosque_post_event_name : isJanaza ? l10n.mosque_post_janaza_name : l10n.mosque_post_title_label,
                    hintText: isEvent ? 'Friday Khutbah' : '',
                  ),
                  const SizedBox(height: 16),
                  label(l10n.mosque_post_description, optional: true),
                  TextField(
                    controller: body,
                    minLines: 3,
                    maxLines: 8,
                    style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: UIColorsToken.bgSurface,
                      hintText: l10n.mosque_post_description_hint,
                      hintStyle: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  if (needsDate) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(l10n.mosque_post_date),
                              pickerBox(
                                Icons.calendar_today_outlined,
                                date.value == null ? '—' : DateFormat('MMM d, yyyy', lang).format(date.value!),
                                () async {
                                  final d = await showDatePicker(context: context, initialDate: date.value ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
                                  if (d != null) date.value = d;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(l10n.mosque_post_time),
                              pickerBox(Icons.access_time, MosqueFormat.hhmm(time.value), () async {
                                final t = await showTimePicker(context: context, initialTime: time.value ?? const TimeOfDay(hour: 14, minute: 0));
                                if (t != null) time.value = t;
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isJanaza) ...[
                    const SizedBox(height: 16),
                    label(l10n.mosque_post_after_prayer_label),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in PrayerSlot.values)
                          ChoiceChip(
                            label: Text(MosquePrayersTab.slotTitle(l10n, s)),
                            selected: afterPrayer.value == s,
                            selectedColor: UIColorsToken.textYellow,
                            backgroundColor: UIColorsToken.bgSurface,
                            labelStyle: theme.typo.inter.bodyMedium.copyWith(color: afterPrayer.value == s ? UIColorsToken.black : UIColorsToken.white),
                            onSelected: (_) => afterPrayer.value = s,
                          ),
                      ],
                    ),
                  ],
                  if (isEvent || isVolunteering) ...[
                    const SizedBox(height: 16),
                    UIInputField(controller: location, labelText: l10n.mosque_post_location, hintText: l10n.mosque_post_location_default),
                  ],
                  if (isVolunteering) ...[
                    const SizedBox(height: 16),
                    UIInputField(controller: volunteers, labelText: l10n.mosque_post_volunteers_needed, hintText: '3', keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
                  ],
                  if (isEvent) ...[
                    const SizedBox(height: 16),
                    UIInputField(controller: language, labelText: '${l10n.mosque_post_language} · ${l10n.common_optional}', hintText: 'fr'),
                  ],
                  const SizedBox(height: 24),
                  if (postId == null)
                    _ToggleRow(
                      icon: Icons.notifications_none,
                      title: l10n.mosque_post_notify_followers,
                      subtitle: quota != null && quota.exhausted
                          ? l10n.error_api_mosque_broadcast_quota_exceeded
                          : l10n.mosque_post_send_push(mosque?.followersCount ?? 0),
                      value: notify.value && !(quota?.exhausted ?? false),
                      enabled: !(quota?.exhausted ?? false),
                      onChanged: (v) => notify.value = v,
                    ),
                  const SizedBox(height: 12),
                  _ToggleRow(
                    icon: Icons.warning_amber_outlined,
                    iconColor: UIColorsToken.red,
                    title: l10n.mosque_post_mark_urgent,
                    subtitle: l10n.mosque_post_mark_urgent_hint,
                    value: urgent.value,
                    onChanged: (v) => urgent.value = v,
                  ),
                ],
              ),
            ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.icon, this.iconColor, required this.title, required this.subtitle, required this.value, required this.onChanged, this.enabled = true});
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Row(
      children: [
        Icon(icon, color: iconColor ?? UIColorsToken.textYellow, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
              Text(subtitle, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
            ],
          ),
        ),
        UIToggle(checked: value, disabled: !enabled, onCheck: onChanged),
      ],
    );
  }
}
