import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/utils/constants/constants.dart';
import 'package:nour/src/core/utils/state_management/app_events.dart';
import 'package:nour/src/core/utils/state_management/single_events.dart';
import 'package:nour/src/features/mosques/data/models/mosque_donation_models.dart';
import 'package:nour/src/features/mosques/data/mosque_repo.dart';

/// Collects the donor's fiscal identity.
///
/// A French receipt must carry the donor's name AND postal address, which the
/// app collects nowhere else — without it the edge function refuses with
/// `incomplete_donor_data`. Asked once, stored in `donor_tax_profiles`, reused
/// for every mosque afterwards.
Future<DonorTaxProfile?> askDonorTaxProfile(
  BuildContext context,
  WidgetRef ref, {
  DonorTaxProfile? initial,
}) {
  return UIBottomSheet.show<DonorTaxProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: UIColorsToken.bgPrimary,
    builder: (_) => _DonorTaxProfileSheet(initial: initial ?? const DonorTaxProfile()),
  );
}

class _DonorTaxProfileSheet extends HookConsumerWidget {
  const _DonorTaxProfileSheet({required this.initial});

  final DonorTaxProfile initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final repo = ref.read(mosqueRepoProvider);

    final name = useTextEditingController(text: initial.fullName);
    final address = useTextEditingController(text: initial.addressLine);
    final postal = useTextEditingController(text: initial.postalCode);
    final city = useTextEditingController(text: initial.city);
    final busy = useState(false);
    useListenable(Listenable.merge([name, address, postal, city]));

    final draft = DonorTaxProfile(
      fullName: name.text,
      addressLine: address.text,
      postalCode: postal.text,
      city: city.text,
      countryCode: initial.countryCode,
    );

    Future<void> save() async {
      if (!draft.isComplete || busy.value) return;
      busy.value = true;
      final res = await repo.saveMyTaxProfile(draft);
      busy.value = false;
      res.when(
        (saved) {
          if (context.mounted) Navigator.of(context).pop(saved);
        },
        (e) => ref.read(appEventProvider).send(ShowErrorEvent(e)),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        kPageHorzPadding,
        16,
        kPageHorzPadding,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.donor_tax_profile_title,
            style: theme.typo.inter.title.copyWith(color: UIColorsToken.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.donor_tax_profile_hint,
            style: theme.typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
          ),
          const SizedBox(height: 16),
          UIInputField(controller: name, hintText: l10n.donor_tax_profile_name),
          const SizedBox(height: 10),
          UIInputField(controller: address, hintText: l10n.donor_tax_profile_address),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 120, child: UIInputField(controller: postal, hintText: l10n.donor_tax_profile_postal)),
              const SizedBox(width: 10),
              Expanded(child: UIInputField(controller: city, hintText: l10n.donor_tax_profile_city)),
            ],
          ),
          const SizedBox(height: 18),
          UIButton.primary(
            label: l10n.common_save,
            fullWidth: true,
            isBusy: busy.value,
            onTap: draft.isComplete ? save : null,
          ),
        ],
      ),
    );
  }
}
