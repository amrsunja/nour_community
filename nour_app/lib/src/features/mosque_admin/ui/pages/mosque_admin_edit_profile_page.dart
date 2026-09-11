import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/mosques/ui/state_management/my_mosque_provider.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_header.dart';

import '../state_management/mosque_admin_mosque_provider.dart';

/// "Edit" from the admin header: public identity & contact fields, logo and
/// cover pictures, address (geocoded to `location`), opening status.
@RoutePage()
class MosqueAdminEditProfilePage extends HookConsumerWidget {
  const MosqueAdminEditProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final mosque = ref.watch(myMosqueProvider).mosque;
    final admin = ref.read(mosqueAdminMosqueProvider.notifier);
    final saving = ref.watch(mosqueAdminMosqueProvider.select((s) => s.isSaving));

    final name = useTextEditingController(text: mosque?.name ?? '');
    final description = useTextEditingController(text: mosque?.description ?? '');
    final address = useTextEditingController(text: mosque?.addressLine ?? '');
    final postal = useTextEditingController(text: mosque?.postalCode ?? '');
    final city = useTextEditingController(text: mosque?.city ?? '');
    final phone = useTextEditingController(text: mosque?.phone ?? '');
    final email = useTextEditingController(text: mosque?.email ?? '');
    final website = useTextEditingController(text: mosque?.website ?? '');
    final instagram = useTextEditingController(text: mosque?.socials['instagram'] ?? '');
    final facebook = useTextEditingController(text: mosque?.socials['facebook'] ?? '');
    final youtube = useTextEditingController(text: mosque?.socials['youtube'] ?? '');
    final logo = useState<String?>(mosque?.logoUrl);
    final covers = useState<List<String>>(mosque?.coverImages ?? const []);
    final opening = useState<String?>(mosque?.openingStatus);
    final uploading = useState(false);

    if (mosque == null) return const UIGradientLinedScaffold(body: Center(child: UICircularProgressBar()));

    Future<String?> pick(String folder, {double maxWidth = 1600}) async {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: maxWidth, imageQuality: 82);
      if (x == null) return null;
      uploading.value = true;
      final url = await admin.upload(File(x.path), folder: folder);
      uploading.value = false;
      return url;
    }

    Future<void> save() async {
      double? lat = mosque.lat;
      double? lng = mosque.lng;
      final fullAddress = [address.text.trim(), postal.text.trim(), city.text.trim()].where((e) => e.isNotEmpty).join(', ');
      final addressChanged = address.text.trim() != (mosque.addressLine ?? '') || city.text.trim() != (mosque.city ?? '') || postal.text.trim() != (mosque.postalCode ?? '');
      if (fullAddress.isNotEmpty && (addressChanged || lat == null)) {
        try {
          final res = await locationFromAddress(fullAddress);
          if (res.isNotEmpty) {
            lat = res.first.latitude;
            lng = res.first.longitude;
          }
        } catch (e) {
          talker.warning('geocode: $e');
        }
      }
      final updated = mosque.copyWith(
        name: name.text.trim().isEmpty ? mosque.name : name.text.trim(),
        description: description.text.trim(),
        addressLine: address.text.trim(),
        postalCode: postal.text.trim(),
        city: city.text.trim(),
        lat: lat,
        lng: lng,
        phone: phone.text.trim(),
        email: email.text.trim(),
        website: website.text.trim(),
        socials: {
          if (instagram.text.trim().isNotEmpty) 'instagram': instagram.text.trim(),
          if (facebook.text.trim().isNotEmpty) 'facebook': facebook.text.trim(),
          if (youtube.text.trim().isNotEmpty) 'youtube': youtube.text.trim(),
        },
        logoUrl: logo.value,
        coverImages: covers.value,
        openingStatus: opening.value,
      );
      if (await admin.saveMosque(updated)) {
        snackbar.showSuccess(l10n.mosque_admin_profile_saved);
        if (context.mounted) await context.router.maybePop();
      }
    }

    return Scaffold(
      appBar: UIAppBar(title: l10n.mosque_admin_edit_profile, onBack: () => context.router.maybePop()),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Covers
                  Text(l10n.mosque_admin_cover_images, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final c in covers.value)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(c, width: 160, height: 110, fit: BoxFit.cover)),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: UITap(
                                    onTap: () => covers.value = covers.value.where((x) => x != c).toList(),
                                    child: Container(
                                      width: 26,
                                      height: 26,
                                      decoration: BoxDecoration(color: UIColorsToken.black.withValues(alpha: .6), shape: BoxShape.circle),
                                      child: const Icon(Icons.close, size: 14, color: UIColorsToken.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        UITap(
                          onTap: uploading.value
                              ? null
                              : () async {
                                  final url = await pick('cover');
                                  if (url != null) covers.value = [...covers.value, url];
                                },
                          child: Container(
                            width: 160,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: UIColorsToken.stroke.withValues(alpha: .4)),
                            ),
                            child: uploading.value
                                ? const Center(child: UICircularProgressBar())
                                : const Icon(Icons.add_photo_alternate_outlined, color: UIColorsToken.textYellow),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      UITap(
                        onTap: () async {
                          final url = await pick('logo', maxWidth: 600);
                          if (url != null) logo.value = url;
                        },
                        child: MosqueLogo(mosque: mosque.copyWith(logoUrl: logo.value), size: 64),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.mosque_admin_tap_to_change_logo, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  UIInputField(controller: name, labelText: l10n.mosque_admin_field_name),
                  const SizedBox(height: 12),
                  Text(l10n.mosque_admin_field_description, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: description,
                    minLines: 3,
                    maxLines: 6,
                    style: theme.typo.inter.body.copyWith(color: UIColorsToken.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: UIColorsToken.bgSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  UIInputField(controller: address, labelText: l10n.mosque_admin_field_address, hintText: "178 Rue d'Illzach"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: UIInputField(controller: postal, labelText: l10n.mosque_admin_field_postal, hintText: '68100', keyboardType: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(child: UIInputField(controller: city, labelText: l10n.mosque_admin_field_city, hintText: 'Mulhouse')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  UIInputField(controller: phone, labelText: l10n.mosque_admin_field_phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  UIInputField(controller: email, labelText: l10n.auth_email, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  UIInputField(controller: website, labelText: l10n.mosque_admin_field_website, keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  UIInputField(controller: instagram, labelText: 'Instagram', hintText: 'https://instagram.com/…', keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  UIInputField(controller: facebook, labelText: 'Facebook', keyboardType: TextInputType.url),
                  const SizedBox(height: 12),
                  UIInputField(controller: youtube, labelText: 'YouTube', keyboardType: TextInputType.url, textInputAction: TextInputAction.done),
                  const SizedBox(height: 16),
                  Text(l10n.mosque_admin_opening_status, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final o in [(null, l10n.mosque_admin_opening_auto), ('open', l10n.mosque_status_open), ('closed', l10n.mosque_status_closed)])
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: UITap(
                              onTap: () => opening.value = o.$1,
                              child: Container(
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: opening.value == o.$1 ? UIColorsToken.bgPriYellow : null,
                                  color: opening.value == o.$1 ? null : UIColorsToken.bgSurface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(o.$2, style: theme.typo.inter.bodyMedium.copyWith(color: opening.value == o.$1 ? UIColorsToken.black : UIColorsToken.white)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(kPageHorzPadding, 8, kPageHorzPadding, 16),
            child: UIButton.primary(label: l10n.common_save, fullWidth: true, isBusy: saving || uploading.value, onTap: save),
          ),
        ],
      ),
    );
  }
}
