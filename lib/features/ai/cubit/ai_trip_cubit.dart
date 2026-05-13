import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/ai/cubit/ai_trip_states.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_itinerary.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/places/models/plan_request.dart';
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
    return budget > 0 &&
        tripLength > 0 &&
        groupNumber > 0 &&
        selectedCategories.isNotEmpty;
  }

  Future<void> generateTripPlan() async {
    if (!validateStep3()) {
      emit(
        AiTripError(
          "Please provide all required trip details (categories, budget, length, and group size).",
        ),
      );
      return;
    }
    emit(AiTripLoading());

    try {
      // 1. Fetch places for the selected categories.
      final recommendationPlaces = await _loadRecommendationPlaces();

      // 2. Construct the PlanRequest payload expected by the itinerary service.
      final requestPayload = PlanRequest(
        destination: "Tunisia", // Default destination
        tripLength: tripLength,
        groupNumber: groupNumber,
        accommodation: bookAccommodation,
        transport: rentCar,
        budget: budget,
        age: age,
        preferences: selectedCategories.map((e) => e.name.toLowerCase()).toList(),
        places: recommendationPlaces,
        reviews: [
          AiUserReview(
            placeName: "les jardin de carthage",
            rating: 4,
            category: "historic",
          )
        ],
      );

      // 3. Send POST request to AI Service via Spring Gateway
      final response = await DioHelper.postData(
        url: EndPoints.itinerary,
        data: requestPayload.toJson(),
      );

      if (response.data != null) {
        final itinerary = _parseItineraryResponse(response.data);
        emit(AiTripSuccess(itinerary));
      } else {
        emit(AiTripError("Empty response from AI Service"));
      }
    } catch (e) {
      debugPrint('[AiTripCubit] generateTripPlan error: $e');
      emit(AiTripError(e.toString()));
    }
  }

  Future<List<PlacesResponse>> _loadRecommendationPlaces() async {
    final selectedCategoryNames =
        selectedCategories.map((e) => e.name.toUpperCase()).toSet();

    if (selectedCategoryNames.isEmpty) {
      return _loadAllPlaces();
    }

    final placesByKey = <String, PlacesResponse>{};

    for (final category in selectedCategoryNames) {
      try {
        final response = await DioHelper.getData(
          url: EndPoints.placesFilter,
          query: {'category': category, 'rating': 0},
        );

        for (final place in _placesFromResponse(response.data)) {
          placesByKey[place.id ?? '${place.name}-${place.cityName}'] = place;
        }
      } catch (e) {
        debugPrint('[AiTripCubit] category fetch failed for $category: $e');
      }
    }

    if (placesByKey.isNotEmpty) {
      return placesByKey.values.toList();
    }

    final allPlaces = await _loadAllPlaces();
    final filtered = allPlaces.where((place) {
      final category = place.category?.name.toUpperCase();
      return category != null && selectedCategoryNames.contains(category);
    }).toList();

    return filtered.isNotEmpty ? filtered : allPlaces;
  }

  Future<List<PlacesResponse>> _loadAllPlaces() async {
    try {
      final response = await DioHelper.getData(url: EndPoints.places);
      final places = _placesFromResponse(response.data);

      if (places.isNotEmpty) return places;
    } catch (e) {
      debugPrint('[AiTripCubit] places fetch failed, using mock data: $e');
    }

    return MockPlacesData.places;
  }

  List<PlacesResponse> _placesFromResponse(dynamic data) {
    List<dynamic> content = [];

    if (data is List) {
      content = data;
    } else if (data is Map && data['content'] is List) {
      content = data['content'] as List;
    }

    return content
        .whereType<Map>()
        .map((e) => PlacesResponse.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  AiItinerary _parseItineraryResponse(dynamic data) {
    if (data is String) {
      return AiItinerary.fromPlainText(data, tripLength);
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final wrapped = map['itinerary'] ?? map['result'] ?? map['plan'];

      if (wrapped is String) {
        return AiItinerary.fromPlainText(wrapped, tripLength);
      }
      if (wrapped is Map) {
        return _parseItineraryResponse(wrapped);
      }

      if (map.containsKey('days') ||
          map.containsKey('title') ||
          map.containsKey('summary')) {
        return AiItinerary.fromJson(map);
      }

      return AiItinerary.fromRawMap(map);
    }

    throw Exception('Unexpected itinerary response format.');
  }
}
