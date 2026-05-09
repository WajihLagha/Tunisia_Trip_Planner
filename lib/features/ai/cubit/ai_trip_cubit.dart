import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/ai/cubit/ai_trip_states.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_itinerary.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/places/models/plan_request.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class AiTripCubit extends Cubit<AiTripStates> {
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
      // 1. Fetch all places to filter them
      final placesResponse = await DioHelper.getData(url: EndPoints.places);
      
      List<PlacesResponse> allPlaces = [];
      if (placesResponse.data != null && placesResponse.data['content'] != null) {
        allPlaces = (placesResponse.data['content'] as List)
            .map((e) => PlacesResponse.fromJson(e))
            .toList();
      }

      // 2. Filter places based on selected preferences (categories)
      List<PlacesResponse> filteredPlaces = allPlaces;
      if (selectedCategories.isNotEmpty) {
        filteredPlaces = allPlaces.where((place) {
          final placeCategory = place.category?.name.toUpperCase() ?? '';
          return selectedCategories.map((e) => e.name.toUpperCase()).contains(placeCategory);
        }).toList();
      }

      // 3. Construct the PlanRequest payload
      final requestPayload = PlanRequest(
        destination: "Tunisia", // Default destination
        tripLength: tripLength,
        groupNumber: groupNumber,
        accommodation: bookAccommodation,
        transport: rentCar,
        budget: budget,
        age: age,
        preferences: selectedPreferences.map((e) => e.toLowerCase()).toList(),
        places: filteredPlaces,
        reviews: [
          AiUserReview(
            placeName: "les jardin de carthage",
            rating: 4,
            category: "historic",
          )
        ],
      );

      // 4. Send POST request to AI Service via Spring Gateway
      final response = await DioHelper.postData(
        url: EndPoints.itinerary,
        data: requestPayload.toJson(),
        headers: {
          'X-User-Email': CacheHelper.getData('email') ?? 'user@test.com',
        },
      );

      if (response.data != null) {
        // Response is a Map<String, String>
        final rawMap = Map<String, dynamic>.from(response.data);
        final itinerary = AiItinerary.fromRawMap(rawMap);
        emit(AiTripSuccess(itinerary));
      } else {
        emit(AiTripError("Empty response from AI Service"));
      }
    } catch (e) {
      emit(AiTripError(e.toString()));
    }
  }
}
