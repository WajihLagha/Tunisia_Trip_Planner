import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class PlacesCubit extends Cubit<PlacesStates> {
  PlacesCubit() : super(PlacesInitialState());

  static PlacesCubit get(context) => BlocProvider.of(context);

  PlacesCategory? selectedCategory;
  double minRating = 0.0;

  void loadPlaces() async {
    emit(PlacesLoadingState());
    try {
      final response = await DioHelper.getData(url: EndPoints.places);
      
      List<dynamic> content = [];
      if (response.data is List) {
        content = response.data;
      } else if (response.data is Map && response.data['content'] != null) {
        content = response.data['content'] as List;
      } else {
        throw Exception('Unexpected response format: ${response.data}');
      }

      final places = content.map((e) => PlacesResponse.fromJson(e)).toList();
      emit(PlacesLoadedState(
        places: places,
        filteredPlaces: places,
        selectedCategory: null,
        minRating: 0.0,
      ));
    } catch (e, stack) {
      debugPrint('[PlacesCubit] loadPlaces error: $e');
      debugPrint('[PlacesCubit] Stack: $stack');
      _emitMockPlaces();
    }
  }

  void filterByCategory(PlacesCategory? category) {
    applyFilters(category: category, rating: minRating);
  }

  void filterByRating(double rating) {
    applyFilters(category: selectedCategory, rating: rating);
  }

  void applyFilters({PlacesCategory? category, required double rating}) async {
    selectedCategory = category;
    minRating = rating;

    if (category == null) {
      // The backend /filter requires a category. If none is selected, 
      // we fetch all and locally filter by rating to avoid backend errors.
      emit(PlacesLoadingState());
      try {
        final response = await DioHelper.getData(url: EndPoints.places);
        
        List<dynamic> content = [];
        if (response.data is List) {
          content = response.data;
        } else if (response.data is Map && response.data['content'] != null) {
          content = response.data['content'] as List;
        }

        final places = content.map((e) => PlacesResponse.fromJson(e)).toList();
        
        final filtered = places.where((p) => (p.rating ?? 0.0) >= rating).toList();
        
        emit(PlacesLoadedState(
          places: places,
          filteredPlaces: filtered,
          selectedCategory: null,
          minRating: rating,
        ));
      } catch (e) {
        debugPrint('[PlacesCubit] applyFilters (no category) error: $e');
        _emitMockPlaces(rating: rating);
      }
      return;
    }

    emit(PlacesLoadingState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.placesFilter,
        query: {
          'category': category.name.toUpperCase(),
          'rating': rating,
        },
      );
      
      List<dynamic> content = [];
      if (response.data is List) {
        content = response.data;
      } else if (response.data is Map && response.data['content'] != null) {
        content = response.data['content'] as List;
      }

      final filteredPlaces = content.map((e) => PlacesResponse.fromJson(e)).toList();

      emit(PlacesLoadedState(
        places: filteredPlaces,
        filteredPlaces: filteredPlaces,
        selectedCategory: category,
        minRating: rating,
      ));
    } catch (e) {
      debugPrint('[PlacesCubit] applyFilters error: $e');
      _emitMockPlaces(category: category, rating: rating);
    }
  }

  void resetFilters() {
    selectedCategory = null;
    minRating = 0.0;
    loadPlaces();
  }

  void searchPlaces(String query) async {
    if (query.isEmpty) {
      resetFilters();
      return;
    }

    emit(PlacesLoadingState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.placesSearch,
        query: {'searchTerm': query},
      );
      
      List<dynamic> content = [];
      if (response.data is List) {
        content = response.data;
      } else if (response.data is Map && response.data['content'] != null) {
        content = response.data['content'] as List;
      }

      final filteredPlaces = content.map((e) => PlacesResponse.fromJson(e)).toList();

      emit(PlacesLoadedState(
        places: filteredPlaces,
        filteredPlaces: filteredPlaces,
        selectedCategory: selectedCategory,
        minRating: minRating,
      ));
    } catch (e) {
      debugPrint('[PlacesCubit] searchPlaces error: $e');
      final queryLower = query.trim().toLowerCase();
      final filteredPlaces = MockPlacesData.places.where((place) {
        return [
          place.name,
          place.cityName,
          place.stateName,
          place.address,
          place.description,
        ].whereType<String>().any(
              (value) => value.toLowerCase().contains(queryLower),
            );
      }).toList();

      emit(PlacesLoadedState(
        places: MockPlacesData.places,
        filteredPlaces: filteredPlaces,
        selectedCategory: selectedCategory,
        minRating: minRating,
      ));
    }
  }

  void _emitMockPlaces({PlacesCategory? category, double rating = 0.0}) {
    final places = MockPlacesData.places;
    final filteredPlaces = places.where((place) {
      final matchesCategory = category == null || place.category == category;
      final matchesRating = (place.rating ?? 0.0) >= rating;
      return matchesCategory && matchesRating;
    }).toList();

    emit(PlacesLoadedState(
      places: places,
      filteredPlaces: filteredPlaces,
      selectedCategory: category,
      minRating: rating,
    ));
  }
}
