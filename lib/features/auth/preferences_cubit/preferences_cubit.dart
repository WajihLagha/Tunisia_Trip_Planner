import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';

import 'preferences_state.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

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

  Future<void> createUser({
    required String username,
    required String email,
    required String mobileNumber,
    required String password,
  }) async {
    emit(state.copyWith(status: PreferencesStatus.loading));

    try {
      final requestData = {
        "username": username,
        "email": email,
        "password": password,
        "mobileNumber": mobileNumber,
        "address": state.address ?? "",
        "ageGroup": state.ageGroup ?? "GENZ",
        "travelStyles": state.travelStyle,
        "groupSize": state.companions?.toUpperCase() ?? "SOLO",
        "budget": state.budget?.replaceAll(" ", "_").toUpperCase() ?? "MODERATE",
        "transportType": state.transport.isNotEmpty ? state.transport.first.replaceAll(" ", "_").toUpperCase() : "CAR_RENTAL",
        "AccommodationType": state.accommodation.isNotEmpty ? state.accommodation.first.toUpperCase() : "HOTEL",
      };

      final response = await DioHelper.postData(
        url: "users", // http://localhost:8080/api-v1/users
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(state.copyWith(status: PreferencesStatus.userCreated));
      } else {
        emit(state.copyWith(
          status: PreferencesStatus.error,
          errorMessage: "Failed to create user",
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PreferencesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> startPollingForVerification({
    required String username,
    required String password,
  }) async {
    emit(state.copyWith(status: PreferencesStatus.waitingForVerification));

    int maxAttempts = 20; // 60 seconds total if waiting 3s each
    bool verified = false;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final response = await DioHelper.postData(
          url: EndPoints.keycloakBaseUrl,
          contentType: 'application/x-www-form-urlencoded',
          data: {
            'client_id': 'oauth-pkce',
            'grant_type': 'password',
            'username': username,
            'password': password,
          },
        );

        if (response.statusCode == 200) {
          final token = response.data['access_token'];
          if (token != null) {
            await CacheHelper.putData(key: 'token', value: token);
            DioHelper.setToken(token);
            emit(state.copyWith(status: PreferencesStatus.loginSuccess, token: token));
            verified = true;
            break;
          }
        }
      } catch (e) {
        // Expected to fail if email is not verified yet.
      }
      
      // Wait for 3 seconds before trying again
      await Future.delayed(const Duration(seconds: 3));
    }

    if (!verified) {
      emit(state.copyWith(
        status: PreferencesStatus.verificationTimeout,
        errorMessage: "Email verification timed out. Please try logging in again.",
      ));
    }
  }
}
