import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';

import 'preferences_state.dart';

class PreferencesCubit extends Cubit<PreferencesState> {
  static const _cacheKey = 'user_preferences';

  PreferencesCubit() : super(const PreferencesState()) {
    _loadSavedPreferences();
  }

  static PreferencesCubit get(context) => BlocProvider.of(context);

  // ── Simple single-value updates ────────────────────────────────

  void updateAddress(String address) => emit(state.copyWith(address: address));

  void updateAgeGroup(String age) => emit(state.copyWith(ageGroup: age));

  void updateCompanions(String companion) =>
      emit(state.copyWith(companions: companion));

  void updateBudget(String budget) => emit(state.copyWith(budget: budget));

  // ── Multi-select toggles ───────────────────────────────────────

  void toggleTravelStyle(String style) {
    final styles = List<String>.from(state.travelStyle);
    styles.contains(style) ? styles.remove(style) : styles.add(style);
    emit(state.copyWith(travelStyle: styles));
  }

  void toggleAccommodation(String acc) {
    final accomms = List<String>.from(state.accommodation);
    accomms.contains(acc) ? accomms.remove(acc) : accomms.add(acc);
    emit(state.copyWith(accommodation: accomms));
  }

  void toggleTransport(String trans) {
    final transports = List<String>.from(state.transport);
    transports.contains(trans) ? transports.remove(trans) : transports.add(trans);
    emit(state.copyWith(transport: transports));
  }

  // ── Local persistence (Hive via CacheHelper) ───────────────────

  Future<void> savePreferences() async {
    await CacheHelper.putData(
      key: _cacheKey,
      value: jsonEncode(state.toJson()),
    );
  }

  void _loadSavedPreferences() {
    final saved = CacheHelper.getData(_cacheKey);
    if (saved != null && saved is String) {
      try {
        final data = jsonDecode(saved) as Map<dynamic, dynamic>;
        emit(PreferencesState.fromJson(data));
      } catch (_) {
        // corrupted cache – silently ignore
      }
    }
  }
}
