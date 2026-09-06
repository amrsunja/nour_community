import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/routing/app_router.gr.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/data/models/mosque_post_model.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';
import 'package:nour/src/features/mosques/ui/state_management/mosque_profile_provider.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_header.dart';

import '../state_management/mosque_admin_mosque_provider.dart';
import '../widgets/audience_picker.dart';

/// "Create a post" (Figma 1140:2046): free announcement (title + body +
/// optional photo, audience Public / Followers) or pick a category → typed
/// form ([MosqueAdminPostFormPage]).
@RoutePage()
class MosqueAdminCreatePostPage extends HookConsumerWidget {
  const MosqueAdminCreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final appEvents = ref.read(appEventProvider);
    final mosque = ref.watch(myMosqueProvider).mosque;
    final admin = ref.read(mosqueAdminMosqueProvider.notifier);

    final title = useTextEditingController();
    useListenable(title); // rebuild the Post button enabled state
    final body = useTextEditingController();
    final audience = useState(MosquePostAudience.public);
    final photo = useState<String?>(null);
    final urgent = useState(false);
    final busy = useState(false);

    Future<void> pickPhoto() async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 82);
      if (x == null) return;
      busy.value = true;
      photo.value = await admin.upload(File(x.path), folder: 'posts');
      busy.value = false;
    }

    Future<void> post() async {
      if (mosque == null || title.text.trim().isEmpty) return;
      busy.value = true;
      final res = await ref.read(mosqueRepoProvider).createPost(MosquePostDraft(
            mosqueId: mosque.id,
            type: photo.value != null && body.text.trim().isNotEmpty ? MosquePostType.highlight : MosquePostType.announcement,
            audience: audience.value,
            title: title.text,
            body: body.text,
            coverUrl: photo.value,
            isUrgent: urgent.value,
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          ));
      busy.value = false;
      await res.when(
        (p) async {
          ref.read(mosqueProfileProvider(mosque.id).notifier).loadPosts();
          snackbar.showSuccess(l10n.mosque_post_published);
          if (context.mounted) await context.router.maybePop();
        },
        (error) async => appEvents.send(ShowErrorEvent(error)),
      );
    }

    final categories = [
      (MosquePostType.event, l10n.mosque_post_type_event, l10n.mosque_post_type_event_hint, Icons.event, const Color(0xff1F6FEB)),
      (MosquePostType.volunteering, l10n.mosque_post_type_volunteering, l10n.mosque_post_type_volunteering_hint, Icons.volunteer_activism_outlined, const Color(0xff1F8A5B)),
      (MosquePostType.highlight, l10n.mosque_post_type_highlight, l10n.mosque_post_type_highlight_hint, Icons.photo_outlined, const Color(0xff7C4DFF)),
      (MosquePostType.janaza, l10n.mosque_post_type_janaza, l10n.mosque_post_type_janaza_hint, Icons.nights_stay_outlined, const Color(0xff3A4A6B)),
    ];

    return UIGradientLinedScaffold(
      appBar: UIAppBar(
        title: l10n.mosque_admin_create_post,
        onBack: () => context.router.maybePop(),
        leadingIcons: [
          UIButton.primary(label: l10n.mosque_admin_tab_post, isSmall: true, isBusy: busy.value, onTap: title.text.trim().isEmpty ? null : post),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 24),
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
                  TextField(
                    controller: title,
                    style: theme.typo.inter.display.copyWith(color: UIColorsToken.white),
                    decoration: InputDecoration(border: InputBorder.none, hintText: l10n.mosque_post_title_hint, hintStyle: theme.typo.inter.display.copyWith(color: UIColorsToken.textParagraph)),
                  ),
                  TextField(
                    controller: body,
                    minLines: 4,
                    maxLines: 12,
                    style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                    decoration: InputDecoration(border: InputBorder.none, hintText: l10n.mosque_post_body_hint, hintStyle: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
                  ),
                  if (photo.value != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: AspectRatio(aspectRatio: 4 / 3, child: Image.network(photo.value!, fit: BoxFit.cover))),
                  ],
                  const SizedBox(height: 16),
                  Text(l10n.mosque_post_add_to_post, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      UITap(onTap: pickPhoto, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.image_outlined, color: UIColorsToken.white))),
                      const SizedBox(width: 12),
                      UITap(
                        onTap: () => urgent.value = !urgent.value,
                        child: Row(
                          children: [
                            Icon(urgent.value ? Icons.warning_amber_rounded : Icons.warning_amber_outlined, color: urgent.value ? UIColorsToken.red : UIColorsToken.white),
                            const SizedBox(width: 4),
                            Text(l10n.mosque_post_mark_urgent, style: theme.typo.inter.caption.copyWith(color: urgent.value ? UIColorsToken.red : UIColorsToken.textParagraph)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(l10n.mosque_post_choose_category, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (final c in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: UITap(
                              onTap: () => context.router.replace(MosqueAdminPostFormRoute(type: c.$1.dbValue)),
                              child: Container(
                                width: 150,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: c.$5, borderRadius: BorderRadius.circular(14)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(c.$4, color: UIColorsToken.white),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(c.$2, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white)),
                                        Text(c.$3, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.white.withValues(alpha: .8))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
