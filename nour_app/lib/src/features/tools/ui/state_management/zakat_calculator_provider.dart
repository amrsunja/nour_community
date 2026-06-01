import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nour/src/core/utils/enums/currency_type.dart';
import 'package:nour/src/core/utils/islamic_tools/zakat_tool.dart';
import 'package:nour/src/core/utils/state_management/presenter.dart';
import 'package:nour/src/core/utils/talker/talker.dart';
import 'package:nour/src/features/tools/data/zakat_repo.dart';

import 'zakat_calculator_state.dart';

final zakatCalculatorProvider =
    StateNotifierProvider<ZakatCalculatorPresenter, ZakatCalculatorState>((ref) {
  return ZakatCalculatorPresenter(ref.read(zakatRepoProvider));
});

class ZakatCalculatorPresenter extends Presenter<ZakatCalculatorState> {
  ZakatCalculatorPresenter(this._remote)
      : super(const ZakatCalculatorState());

  final ZakatRepo _remote;

  /// Debounce so we don't hit the API on every keystroke.
  static const _debounce = Duration(milliseconds: 700);
  Timer? _timer;

  /// Monotonic token so a slow in-flight response can't overwrite a newer one.
  int _requestId = 0;

  void init() {
    state = state.copyWith(ready: true);
    _onInputChanged();
  }

  // ── Field setters ─────────────────────────────────────────────────────────
  void setCurrency(CurrencyType c) => state = state.copyWith(currency: c);

  void setGold(double v) => _set(state.copyWith(gold: v));
  void setSilver(double v) => _set(state.copyWith(silver: v));
  void setOther(double v) => _set(state.copyWith(other: v));
  void setCash(double v) => _set(state.copyWith(cash: v));
  void setSavings(double v) => _set(state.copyWith(savings: v));
  void setInvestments(double v) => _set(state.copyWith(investments: v));
  void setLoansGiven(double v) => _set(state.copyWith(loansGiven: v));
  void setPersonalDebts(double v) => _set(state.copyWith(personalDebts: v));
  void setBillsDue(double v) => _set(state.copyWith(billsDue: v));

  /// Clears every input back to zero (keeps the chosen currency).
  void reset() {
    _timer?.cancel();
    state = ZakatCalculatorState(ready: state.ready, currency: state.currency);
    _onInputChanged();
  }

  void _set(ZakatCalculatorState next) {
    state = next;
    _onInputChanged();
  }

  /// Instant local snapshot + debounced authoritative API call.
  void _onInputChanged() {
    // Provisional figures so the UI updates immediately while we wait.
    state = state.copyWith(
      result: ZakatTool.fallback(state.input, nisab: state.lastNisab),
      loading: state.input.netAssets > 0,
      apiError: false,
    );

    _timer?.cancel();
    _timer = Timer(_debounce, _fetch);
  }

  Future<void> _fetch() async {
    final input = state.input;
    final net = input.netAssets;

    // Below or at zero net → nothing zakatable, skip the network round-trip.
    if (net <= 0) {
      if (!mounted) return;
      state = state.copyWith(
        result: ZakatTool.aggregate(input),
        loading: false,
        apiError: false,
      );
      return;
    }

    final id = ++_requestId;
      final api = await _remote.calculateMoneyZakat(net);
      if (!mounted || id != _requestId) return;

      api.when(
        (s) {
          if (s.isError) {
            _applyFallback(input, apiError: true);
            return;
          }

          final nisab = s.nisabSilverUsd ?? state.lastNisab ?? 0;
          state = state.copyWith(
            lastNisab: s.nisabSilverUsd,
            loading: false,
            apiError: false,
            result: ZakatResult(
              totalAssets: input.totalAssets,
              totalDebts: input.totalDebts,
              netAssets: net,
              nisabThreshold: nisab,
              isAboveNisab: s.aboveNisab,
              zakatDue: s.zakatDue,
              rate: ZakatTool.zakatRate,
              fromApi: true,
            ),
          );

        },
        (error) {
          talker.handle(error, null, 'Zakat API call failed');
          if (!mounted || id != _requestId) return;
          _applyFallback(input, apiError: true);
        }
      );
  }

  void _applyFallback(ZakatInput input, {required bool apiError}) {
    state = state.copyWith(
      loading: false,
      apiError: apiError,
      result: ZakatTool.fallback(input, nisab: state.lastNisab),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
