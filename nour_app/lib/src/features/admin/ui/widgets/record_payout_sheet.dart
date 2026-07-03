import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/features/impact/data/models/impact_project_model.dart';
import 'package:nour/src/features/payments/data/models/tx_enums.dart';

import '../../data/models/record_payout_params.dart';
import '../state_management/admin_provider.dart';

/// Admin form to record a manual disbursement (payout) to a partner, with an
/// optional proof-of-transfer image uploaded to the private payout-proofs bucket.
class RecordPayoutSheet extends ConsumerStatefulWidget {
  const RecordPayoutSheet({super.key, this.presetProject, this.presetType});

  final ImpactProjectModel? presetProject;
  final TxType? presetType;

  static Future<bool?> show(
    BuildContext context, {
    ImpactProjectModel? presetProject,
    TxType? presetType,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: UIColorsToken.bgPrimary,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => RecordPayoutSheet(
        presetProject: presetProject,
        presetType: presetType,
      ),
    );
  }

  @override
  ConsumerState<RecordPayoutSheet> createState() => _RecordPayoutSheetState();
}

class _RecordPayoutSheetState extends ConsumerState<RecordPayoutSheet> {
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  ImpactProjectModel? _project;
  TxType _type = TxType.donation;
  PayoutMethod _method = PayoutMethod.bank;
  PayoutStatus _status = PayoutStatus.confirmed;
  Uint8List? _proofBytes;
  String _proofExt = 'jpg';
  String _proofContentType = 'image/jpeg';

  @override
  void initState() {
    super.initState();
    _project = widget.presetProject;
    _type = widget.presetType ??
        (widget.presetProject?.eligibleForZakat == true
            ? TxType.zakat
            : TxType.donation);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final name = file.name.toLowerCase();
    final ext = name.contains('.') ? name.split('.').last : 'jpg';
    setState(() {
      _proofBytes = bytes;
      _proofExt = ext == 'png' ? 'png' : 'jpg';
      _proofContentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    });
  }

  Future<void> _submit(AppLocale l10n) async {
    final project = _project;
    final amount =
        double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    if (project == null || amount <= 0) return;

    final params = RecordPayoutParams(
      organizationId: project.organizationId,
      impactProjectId: project.id,
      type: _type,
      amount: amount,
      currency: project.currency,
      method: _method,
      status: _status,
      reference: _refCtrl.text.trim(),
      note: _noteCtrl.text.trim(),
      executedAt: _status == PayoutStatus.pending ? null : DateTime.now(),
    );

    final ok = await ref.read(adminProvider.notifier).recordPayout(
          params,
          proofBytes: _proofBytes,
          proofExt: _proofExt,
          proofContentType: _proofContentType,
        );

    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final theme = UITheme.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final projects = ref.read(adminProvider.notifier).projects;
    final submitting =
        ref.watch(adminProvider.select((s) => s.isSubmittingPayout));

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: UIColorsToken.stroke,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const UISpace.vert(18),
              Text(
                l10n.admin_record_payout,
                style: theme.typo.inter.title
                    .copyWith(color: UIColorsToken.white),
              ),
              const UISpace.vert(16),

              // Project.
              _Label(l10n.admin_field_project),
              _Dropdown<ImpactProjectModel>(
                value: _project,
                hint: l10n.admin_field_project,
                items: [
                  for (final p in projects)
                    DropdownMenuItem(value: p, child: Text(p.title(langCode))),
                ],
                onChanged: (p) => setState(() {
                  _project = p;
                  if (p != null && !p.eligibleForZakat) _type = TxType.donation;
                }),
              ),
              const UISpace.vert(14),

              // Type.
              _Label(l10n.admin_field_type),
              UITabs<TxType>(
                selected: _type,
                items: [
                  UITabItem(value: TxType.zakat, label: l10n.donate_type_zakat),
                  UITabItem(
                    value: TxType.donation,
                    label: l10n.donate_type_donation,
                  ),
                ],
                onChanged: (t) => setState(() => _type = t),
              ),
              const UISpace.vert(14),

              // Amount.
              _Label(l10n.admin_field_amount),
              UIInputField(
                controller: _amountCtrl,
                hintText: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
              ),
              const UISpace.vert(14),

              // Method + status.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(l10n.admin_field_method),
                        _Dropdown<PayoutMethod>(
                          value: _method,
                          items: [
                            for (final m in PayoutMethod.values)
                              DropdownMenuItem(
                                value: m,
                                child: Text(m.value.toUpperCase()),
                              ),
                          ],
                          onChanged: (m) =>
                              setState(() => _method = m ?? _method),
                        ),
                      ],
                    ),
                  ),
                  const UISpace.horz(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Label(l10n.admin_field_status),
                        _Dropdown<PayoutStatus>(
                          value: _status,
                          items: [
                            for (final s in PayoutStatus.values)
                              DropdownMenuItem(
                                value: s,
                                child: Text(s.value.toUpperCase()),
                              ),
                          ],
                          onChanged: (s) =>
                              setState(() => _status = s ?? _status),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const UISpace.vert(14),

              // Reference.
              _Label(l10n.admin_field_reference),
              UIInputField(
                controller: _refCtrl,
                hintText: l10n.admin_field_reference_hint,
              ),
              const UISpace.vert(14),

              // Note.
              _Label(l10n.admin_field_note),
              UIInputField(controller: _noteCtrl),
              const UISpace.vert(16),

              // Proof.
              _Label(l10n.admin_field_proof),
              _ProofPicker(
                bytes: _proofBytes,
                onPick: _pickProof,
                onClear: () => setState(() => _proofBytes = null),
                label: l10n.admin_add_proof,
              ),
              const UISpace.vert(22),

              UIButton.primary(
                label: l10n.admin_save_payout,
                fullWidth: true,
                isBusy: submitting,
                onTap: (_project != null &&
                        (_amountCtrl.text.trim().isNotEmpty) &&
                        !submitting)
                    ? () => _submit(l10n)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: typo.inter.bodySmall.copyWith(color: UIColorsToken.textParagraph),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: UIColorsToken.bgSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint == null
              ? null
              : Text(
                  hint!,
                  style: typo.inter.bodyMedium
                      .copyWith(color: UIColorsToken.textParagraph),
                ),
          dropdownColor: UIColorsToken.bgSurface,
          iconEnabledColor: UIColorsToken.white,
          style: typo.inter.bodyMedium.copyWith(color: UIColorsToken.white),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ProofPicker extends StatelessWidget {
  const _ProofPicker({
    required this.bytes,
    required this.onPick,
    required this.onClear,
    required this.label,
  });

  final Uint8List? bytes;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String label;

  @override
  Widget build(BuildContext context) {
    final typo = UITheme.of(context).typo;
    if (bytes != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              bytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: UITap(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: UIColorsToken.black80,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close,
                    size: 18, color: UIColorsToken.white),
              ),
            ),
          ),
        ],
      );
    }

    return UITap(
      onTap: onPick,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: UIColorsToken.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: UIColorsToken.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.upload_file, color: UIColorsToken.textYellow),
            const UISpace.vert(6),
            Text(
              label,
              style: typo.inter.bodySmall
                  .copyWith(color: UIColorsToken.textParagraph),
            ),
          ],
        ),
      ),
    );
  }
}
