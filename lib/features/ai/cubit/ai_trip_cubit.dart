import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/ai/cubit/ai_trip_states.dart';
import 'package:tunisian_trip_planner/features/ai/data/ai_trip_repository.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_place.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_plan_request.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';

class AiTripCubit extends Cubit<AiTripStates> {
  final AiTripRepository _repository = AiTripRepository();

  AiTripCubit() : super(AiTripInitial());

  static AiTripCubit get(context) => BlocProvider.of(context);

  // Form Data
  bool rentCar = false;
  bool bookAccommodation = false;
  List<PlacesCategory> selectedCategories = [];
  int age = 25;
  List<String> selectedPreferences = [];
  double budget = 500.0;
  int tripLength = 3;
  int groupNumber = 1;

  // UI State
  int currentStep = 0;

  void toggleRentCar(bool value) {
    rentCar = value;
    emit(AiTripFormUpdated());
  }

  void toggleAccommodation(bool value) {
    bookAccommodation = value;
    emit(AiTripFormUpdated());
  }

  void toggleCategorySelection(PlacesCategory category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
    emit(AiTripFormUpdated());
  }

  void togglePreference(String pref) {
    if (selectedPreferences.contains(pref)) {
      selectedPreferences.remove(pref);
    } else {
      selectedPreferences.add(pref);
    }
    emit(AiTripFormUpdated());
  }

  void updateAge(int newAge) {
    age = newAge;
    emit(AiTripFormUpdated());
  }

  void updateBudget(double newBudget) {
    budget = newBudget;
    emit(AiTripFormUpdated());
  }

  void updateTripLength(int newLength) {
    tripLength = newLength;
    emit(AiTripFormUpdated());
  }

  void updateGroupNumber(int newGroupNumber) {
    groupNumber = newGroupNumber;
    emit(AiTripFormUpdated());
  }

  void setStep(int step) {
    currentStep = step;
    emit(AiTripFormUpdated());
  }

  bool validateStep3() {
    return budget > 0 && tripLength > 0 && groupNumber > 0 && selectedPreferences.isNotEmpty;
  }

  Future<void> generateTripPlan() async {
    if (!validateStep3()) {
      emit(AiTripError("Please provide all required trip details (budget, length, group size, and at least one preference)."));
      return;
    }
    emit(AiTripLoading());

    try {
      final matchingPlaces = MockPlacesData.places
          .where((p) => p.category != null && selectedCategories.contains(p.category))
          .toList();

      final request = AiPlanRequest(
        places: matchingPlaces
            .map((p) => AiPlace(
                  id: p.id,
                  name: p.name,
                  cityName: p.cityName,
                  latitude: p.latitude,
                  longitude: p.longitude,
                  category: p.category?.name,
                ))
            .toList(),
        user: "CurrentUser", // Replace with actual user ID if available
        age: age,
        preferences: selectedPreferences.isNotEmpty ? selectedPreferences : ["General"],
        budget: budget,
        tripLength: tripLength,
        groupNumber: groupNumber,
        accommodation: bookAccommodation,
        transportMean: rentCar,
      );

      final itinerary = await _repository.generatePlan(request);
      emit(AiTripSuccess(itinerary));
    } catch (e) {
      emit(AiTripError(e.toString()));
    }
  }
}
