import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/design_system/design_system.dart';
import 'package:nour/src/core/locale/l10n.dart';
import 'package:nour/src/core/network/supabase_client.dart';
import 'package:nour/src/core/providers/widgets/snackbar_provider.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/admin/data/models/mosque_request_model.dart';
import 'package:nour/src/features/mosques/data/models/mosque_enums.dart';
import 'package:nour/src/features/mosques/ui/widgets/mosque_format.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Nour admin › Mosques: registration requests with Approve / Reject /
/// Suspend (§11). Calls the `review-mosque` edge function (push + email).
class AdminMosquesTab extends HookConsumerWidget {
  const AdminMosquesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = UITheme.of(context);
    final l10n = ref.watch(l10nProvider);
    final snackbar = ref.read(snackbarProvider);
    final filter = useState<MosqueStatus?>(MosqueStatus.pendingReview);
    final items = useState<List<MosqueRequestModel>>(const []);
    final loading = useState(false);

    Future<void> load() async {
      loading.value = true;
      try {
        final rows = await supabaseClient.rpc('fn_admin_mosque_requests', params: {'p_status': filter.value?.dbValue}) as List;
        items.value = rows.map((e) => MosqueRequestModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e, st) {
        talker.handle(e, st, 'admin mosques');
        snackbar.showError(e.toString());
      }
      loading.value = false;
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => load());
      return null;
    }, [filter.value]);

    Future<void> review(MosqueRequestModel m, String action) async {
      String? note;
      if (action != 'approve') {
        note = await _noteDialog(context, l10n);
        if (note == null) return;
      }
      try {
        await supabaseClient.functions.invoke('review-mosque', body: {'mosqueId': m.id, 'action': action, 'note': note});
        snackbar.showSuccess(l10n.admin_mosque_reviewed);
        await load();
      } on FunctionException catch (e) {
        snackbar.showError(e.details?.toString() ?? e.toString());
      } catch (e) {
        snackbar.showError(e.toString());
      }
    }

    final filters = <(MosqueStatus?, String)>[
      (MosqueStatus.pendingReview, l10n.admin_mosque_filter_pending),
      (MosqueStatus.approved, l10n.admin_mosque_filter_approved),
      (MosqueStatus.rejected, l10n.admin_mosque_filter_rejected),
      (MosqueStatus.suspended, l10n.admin_mosque_filter_suspended),
      (null, l10n.admin_filter_all),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final f in filters)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: UITap(
                    onTap: () => filter.value = f.$1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: filter.value == f.$1 ? UIColorsToken.bgPriYellow : null,
                        color: filter.value == f.$1 ? null : UIColorsToken.bgSurface,
                      ),
                      child: Text(f.$2, style: theme.typo.inter.bodyMedium.copyWith(color: filter.value == f.$1 ? UIColorsToken.black : UIColorsToken.white)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (loading.value)
          const Padding(padding: EdgeInsets.all(24), child: Center(child: UICircularProgressBar()))
        else if (items.value.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.admin_mosque_empty, textAlign: TextAlign.center, style: theme.typo.inter.body.copyWith(color: UIColorsToken.textParagraph)),
          )
        else
          for (final m in items.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: UICard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(m.name, style: theme.typo.inter.title.copyWith(color: UIColorsToken.white))),
                        Text(MosqueFormat.timeAgo(m.createdAt, l10n), style: theme.typo.inter.smallCaption.copyWith(color: UIColorsToken.textParagraph)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (m.legalStatus != null) m.legalStatus!.dbValue,
                        if (m.rna != null) 'RNA ${m.rna}',
                        if (m.siren != null) 'SIREN ${m.siren}',
                        m.countryCode,
                      ].join(' · '),
                      style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph),
                    ),
                    if (m.ownerEmail != null)
                      Text('${m.ownerName ?? ''} <${m.ownerEmail}>', style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textParagraph)),
                    if (m.duplicateSiren)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(l10n.admin_mosque_duplicate_siren, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.red)),
                      ),
                    if ((m.reviewNote ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(m.reviewNote!, style: theme.typo.inter.caption.copyWith(color: UIColorsToken.textYellow)),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (m.status != MosqueStatus.approved)
                          Expanded(child: UIButton.primary(label: l10n.admin_mosque_approve, isSmall: true, fullWidth: true, onTap: () => review(m, 'approve'))),
                        if (m.status != MosqueStatus.approved) const SizedBox(width: 8),
                        if (m.status == MosqueStatus.pendingReview)
                          Expanded(child: UIButton.secondary(label: l10n.admin_mosque_reject, isSmall: true, fullWidth: true, onTap: () => review(m, 'reject'))),
                        if (m.status == MosqueStatus.approved)
                          Expanded(child: UIButton.secondary(label: l10n.admin_mosque_suspend, isSmall: true, fullWidth: true, onTap: () => review(m, 'suspend'))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  static Future<String?> _noteDialog(BuildContext context, AppLocale l10n) {
    final c = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: UIColorsToken.bgSurface,
        title: Text(l10n.admin_mosque_note_title, style: const TextStyle(color: UIColorsToken.white)),
        content: TextField(controller: c, maxLines: 3, style: const TextStyle(color: UIColorsToken.white), decoration: InputDecoration(hintText: l10n.admin_mosque_note_hint)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.common_cancel)),
          TextButton(onPressed: () => Navigator.of(ctx).pop(c.text.trim()), child: Text(l10n.common_done)),
        ],
      ),
    );
  }
}
