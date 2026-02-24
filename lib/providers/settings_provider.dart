import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/link_service.dart';

class SettingsState {
  final bool isLoading;
  final String? inviteCode;
  final String? partnerName;

  SettingsState({this.isLoading = false, this.inviteCode, this.partnerName});

  SettingsState copyWith({
    bool? isLoading,
    String? inviteCode,
    String? partnerName,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      inviteCode: inviteCode ?? this.inviteCode,
      partnerName: partnerName ?? this.partnerName,
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final linkService = ref.watch(linkServiceProvider);
    return SettingsNotifier(linkService);
  },
);

class SettingsNotifier extends StateNotifier<SettingsState> {
  final LinkService _linkService;

  SettingsNotifier(this._linkService) : super(SettingsState()) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final status = await _linkService.getLinkStatus();
      state = state.copyWith(
        isLoading: false,
        inviteCode: status['invite_code'],
        partnerName: status['partner_name'],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> generateInviteCode() async {
    await _loadStatus();
  }

  Future<bool> linkWithPartner(String code) async {
    state = state.copyWith(isLoading: true);
    try {
      await _linkService.linkPartner(code);
      await _loadStatus();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}
