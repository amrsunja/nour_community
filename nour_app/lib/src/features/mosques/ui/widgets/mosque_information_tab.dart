import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nour/gen/assets.gen.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/mosque_onboarding/ui/widgets/countries.dart';

import '../../data/models/mosque_enums.dart';
import '../../data/models/mosque_imam_model.dart';
import '../../data/models/mosque_model.dart';

/// Information tab (public): capacity · founded · services · khutbah
/// languages · imams. Also used by the admin editor with [editable].
class MosqueInformationTab extends StatelessWidget {
  const MosqueInformationTab({
    super.key,
    required this.mosque,
    required this.l10n,
    this.editable = false,
    this.onEditCapacity,
    this.onEditFounded,
    this.onToggleService,
    this.onEditLanguages,
    this.onEditImam,
    this.onAddImam,
  });

  final MosqueModel mosque;
  final AppLocale l10n;
  final bool editable;
  final VoidCallback? onEditCapacity;
  final VoidCallback? onEditFounded;
  final ValueChanged<MosqueService>? onToggleService;
  final VoidCallback? onEditLanguages;
  final ValueChanged<MosqueImamModel>? onEditImam;
  final VoidCallback? onAddImam;

  static String serviceLabel(AppLocale l10n, MosqueService s) => switch (s) {
        MosqueService.parking => l10n.mosque_service_parking,
        MosqueService.disabledAccess => l10n.mosque_service_disabled_access,
        MosqueService.ablutionRoom => l10n.mosque_service_ablution_room,
        MosqueService.womenSpace => l10n.mosque_service_women_space,
        MosqueService.adultClasses => l10n.mosque_service_adult_classes,
        MosqueService.childrenClasses => l10n.mosque_service_children_classes,
        MosqueService.quranClasses => l10n.mosque_service_quran_classes,
        MosqueService.arabicClasses => l10n.mosque_service_arabic_classes,
        MosqueService.eidPrayer => l10n.mosque_service_eid_prayer,
        MosqueService.janaza => l10n.mosque_service_janaza,
        MosqueService.iftarRamadan => l10n.mosque_service_iftar_ramadan,
        MosqueService.library => l10n.mosque_service_library,
        MosqueService.newMuslimsSupport => l10n.mosque_service_new_muslims,
      };

  static String serviceImagePath(MosqueService s) => switch (s) {
        MosqueService.parking => Assets.images.illustration40.path,
        MosqueService.disabledAccess => Assets.images.illustration41.path,
        MosqueService.ablutionRoom => Assets.images.illustration31.path,
        MosqueService.womenSpace => Assets.images.illustration45.path,
        MosqueService.adultClasses => Assets.images.illustration44.path,
        MosqueService.childrenClasses => Assets.images.illustration46.path,
        MosqueService.quranClasses => Assets.images.illustration24.path,
        MosqueService.arabicClasses => Assets.images.illustration3.path,
        MosqueService.eidPrayer => Assets.images.illustration42.path,
        MosqueService.janaza => Assets.images.illustration47.path,
        MosqueService.iftarRamadan => Assets.images.illustration43.path,
        MosqueService.library => Assets.images.illustration28.path,
        MosqueService.newMuslimsSupport => Assets.images.illustration42.path,
      };

  static String languageName(String code) => switch (code.toLowerCase()) {
        'fr' => 'French',
        'ar' => 'Arabic',
        'en' => 'English',
        'tr' => 'Turkish',
        'ur' => 'Urdu',
        'bn' => 'Bengali',
        'de' => 'German',
        'nl' => 'Dutch',
        'es' => 'Spanish',
        'it' => 'Italian',
        'id' => 'Indonesian',
        'ms' => 'Malay',
        'ru' => 'Russian',
        'so' => 'Somali',
        'wo' => 'Wolof',
        'ber' => 'Amazigh',
        _ => code.toUpperCase(),
      };

  static String languageFlag(String code) => switch (code.toLowerCase()) {
        'fr' => '🇫🇷', 'ar' => '🇸🇦', 'en' => '🇬🇧', 'tr' => '🇹🇷', 'ur' => '🇵🇰', 'bn' => '🇧🇩', 'de' => '🇩🇪',
        'nl' => '🇳🇱', 'es' => '🇪🇸', 'it' => '🇮🇹', 'id' => '🇮🇩', 'ms' => '🇲🇾', 'ru' => '🇷🇺', 'so' => '🇸🇴',
        'wo' => '🇸🇳', 'ber' => '🇲🇦',
        _ => flagEmoji(code.length == 2 ? code : 'un'),
      };

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final services = editable ? MosqueService.values : mosque.services;
    final age = mosque.foundedYear == null ? null : DateTime.now().year - mosque.foundedYear!;

    Widget section(String title, {Widget? trailing, String? subtitle}) => Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white))),
                  if (trailing != null) trailing,
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
              ],
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.groups_outlined,
                  label: l10n.mosque_capacity,
                  value: mosque.capacityTotal?.toString() ?? '—',
                  hint: mosque.capacityMen != null || mosque.capacityWomen != null
                      ? '${l10n.mosque_capacity_men} ${mosque.capacityMen ?? '—'} · ${l10n.mosque_capacity_women} ${mosque.capacityWomen ?? '—'}'
                      : l10n.mosque_capacity_men_women,
                  onEdit: editable ? onEditCapacity : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  icon: Icons.calendar_today_outlined,
                  label: l10n.mosque_founded,
                  value: mosque.foundedYear?.toString() ?? '—',
                  hint: age == null ? ' ' : l10n.mosque_years_old(age),
                  onEdit: editable ? onEditFounded : null,
                ),
              ),
            ],
          ),
          section(l10n.mosque_services, subtitle: editable ? l10n.mosque_services_edit_hint : null),
          if (services.isEmpty)
            Text(l10n.mosque_no_services, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
          for (final s in services)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ServiceRow(
                image: serviceImagePath(s),
                label: serviceLabel(l10n, s),
                selected: mosque.services.contains(s),
                editable: editable,
                onTap: editable ? () => onToggleService?.call(s) : null,
              ),
            ),
          section(
            l10n.mosque_khutbah_languages,
            trailing: editable ? UIButton.textual(label: l10n.common_edit, isSmall: true, onTap: onEditLanguages) : null,
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (mosque.khutbahLanguages.isEmpty)
                Text('—', style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
              for (final code in mosque.khutbahLanguages)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: UIColorsToken.bgSurface, borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(languageFlag(code), style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(languageName(code), style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                    ],
                  ),
                ),
            ],
          ),
          section(l10n.mosque_imams),
          if (mosque.imams.isEmpty && !editable)
            Text('—', style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
          for (final imam in mosque.imams)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: UICard(
                padding: const EdgeInsets.all(12),
                onTap: editable ? () => onEditImam?.call(imam) : null,
                child: Row(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: imam.photoUrl != null
                            ? CachedNetworkImage(imageUrl: imam.photoUrl!, fit: BoxFit.cover)
                            : Container(
                                color: UIColorsToken.yellow,
                                alignment: Alignment.center,
                                child: Text(imam.initials, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.black)),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(imam.fullName, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white)),
                          if (imam.sinceYear != null)
                            Text(l10n.mosque_since_year(imam.sinceYear!),
                                style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                        ],
                      ),
                    ),
                    if (editable) Icon(Icons.edit_outlined, size: 18, color: UIColorsToken.textParagraph),
                  ],
                ),
              ),
            ),
          if (editable)
            UIButton.secondary(label: l10n.mosque_add_imam, fullWidth: true, onTap: onAddImam),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value, required this.hint, this.onEdit});
  final IconData icon;
  final String label;
  final String value;
  final String hint;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return UICard(
      padding: const EdgeInsets.all(14),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: UIColorsToken.textParagraph),
              const SizedBox(width: 6),
              Expanded(child: Text(label, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph))),
              if (onEdit != null) Icon(Icons.edit_outlined, size: 14, color: UIColorsToken.textParagraph),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.typo.inter.display.copyWith(color: UIColorsToken.white)),
          if (hint.isNotEmpty) Text(hint, style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({required this.image, required this.label, required this.selected, required this.editable, this.onTap});
  final String image;
  final String label;
  final bool selected;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    return Opacity(
      opacity: editable && !selected ? .5 : 1,
      child: UICard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 50,
              child: Image.asset(image),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: theme.typo.inter.bodyMedium.copyWith(color: UIColorsToken.white))),
            if (editable)
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? UIColorsToken.pastelGreen : UIColorsToken.textParagraph,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
