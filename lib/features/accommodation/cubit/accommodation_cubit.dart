import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/accommodation_states.dart';
import 'package:tunisian_trip_planner/features/accommodation/data/mock_accommodation_data.dart';
import 'package:tunisian_trip_planner/features/accommodation/enums/accommodation_type.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/room.dart';

class AccommodationCubit extends Cubit<AccommodationStates> {
  AccommodationCubit() : super(AccommodationInitialState());

  static AccommodationCubit get(context) => BlocProvider.of(context);

  AccommodationType? selectedType;
  
  List<RoomDto> get topRooms => MockAccommodationData.topRooms;

  void loadAccommodations() async {
    emit(AccommodationLoadingState());
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (isClosed) return;

    try {
      final accommodations = MockAccommodationData.accommodations;
      emit(AccommodationLoadedState(
        accommodations: accommodations,
        filteredAccommodations: accommodations,
      ));
    } catch (e) {
      emit(AccommodationErrorState('Failed to load accommodations'));
    }
  }

  void filterByType(AccommodationType? type) {
    if (state is AccommodationLoadedState) {
      final currentState = state as AccommodationLoadedState;
      selectedType = type;

      if (type == null) {
        emit(AccommodationLoadedState(
          accommodations: currentState.accommodations,
          filteredAccommodations: currentState.accommodations,
        ));
      } else {
        final filtered = currentState.accommodations
            .where((acc) => acc.accommodationType == type)
            .toList();
        emit(AccommodationLoadedState(
          accommodations: currentState.accommodations,
          filteredAccommodations: filtered,
        ));
      }
    }
  }
}
