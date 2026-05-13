import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/data/mock_accommodation_data.dart';
import 'package:tunisian_trip_planner/features/accommodation/enums/accommodation_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class AccommodationCubit extends Cubit<AccommodationStates> {
  AccommodationCubit() : super(AccommodationInitialState());

  static AccommodationCubit get(context) => BlocProvider.of(context);

  AccommodationType? selectedType;

  // ── Derive top rooms (up to 4) from the current loaded accommodations ──────
  List<RoomDto> getTopRooms(List<AccommodationDto> accommodations) {
    return accommodations
        .expand((acc) => acc.rooms ?? <RoomDto>[])
        .take(4)
        .toList();
  }

  // ── Load all accommodations from API (paged) ─────────────────────────────
  Future<void> loadAccommodations({int page = 0, int size = 10}) async {
    emit(AccommodationLoadingState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.accommodations,
        query: {'page': page, 'size': size},
      );

      final data = response.data;
      List<dynamic> rawList;

      // Handle both paged (with 'content') and plain array responses
      if (data is List) {
        rawList = data;
      } else if (data is Map && data.containsKey('content')) {
        rawList = data['content'] as List<dynamic>;
      } else {
        rawList = [];
      }

      final accommodations =
          rawList
              .map((e) => AccommodationDto.fromJson(e as Map<String, dynamic>))
              .toList();

      emit(
        AccommodationLoadedState(
          accommodations: accommodations,
          filteredAccommodations: accommodations,
        ),
      );
    } catch (e) {
      debugPrint('[AccommodationCubit] loadAccommodations error: $e');
      _emitMockAccommodations();
    }
  }

  // ── Filter by type (client-side from loaded list) ─────────────────────────
  void filterByType(AccommodationType? type) {
    if (state is AccommodationLoadedState) {
      final currentState = state as AccommodationLoadedState;
      selectedType = type;

      if (type == null) {
        emit(
          AccommodationLoadedState(
            accommodations: currentState.accommodations,
            filteredAccommodations: currentState.accommodations,
          ),
        );
      } else {
        final filtered =
            currentState.accommodations
                .where((acc) => acc.accommodationType == type)
                .toList();
        emit(
          AccommodationLoadedState(
            accommodations: currentState.accommodations,
            filteredAccommodations: filtered,
          ),
        );
      }
    }
  }

  // ── Search via API: GET /api-v1/accommodations/search?keyword=... ─────────
  Future<void> searchAccommodations(
    String keyword, {
    int page = 0,
    int size = 20,
  }) async {
    if (keyword.trim().isEmpty) {
      emit(AccommodationSearchLoadedState(filteredAccommodations: []));
      return;
    }

    emit(AccommodationSearchingState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.accommodationSearch,
        query: {'keyword': keyword.trim(), 'page': page, 'size': size},
      );

      final data = response.data;
      List<dynamic> rawList;

      if (data is List) {
        rawList = data;
      } else if (data is Map && data.containsKey('content')) {
        rawList = data['content'] as List<dynamic>;
      } else {
        rawList = [];
      }

      final results =
          rawList
              .map((e) => AccommodationDto.fromJson(e as Map<String, dynamic>))
              .toList();

      emit(AccommodationSearchLoadedState(filteredAccommodations: results));
    } catch (e) {
      debugPrint('[AccommodationCubit] searchAccommodations error: $e');
      final keywordLower = keyword.trim().toLowerCase();
      final results =
          MockAccommodationData.accommodations.where((accommodation) {
        return [
          accommodation.name,
          accommodation.city,
          accommodation.state,
          accommodation.address,
          accommodation.description,
        ].whereType<String>().any(
              (value) => value.toLowerCase().contains(keywordLower),
            );
      }).toList();
      emit(AccommodationSearchLoadedState(filteredAccommodations: results));
    }
  }

  void _emitMockAccommodations() {
    final accommodations = MockAccommodationData.accommodations;
    emit(
      AccommodationLoadedState(
        accommodations: accommodations,
        filteredAccommodations: accommodations,
      ),
    );
  }
}
