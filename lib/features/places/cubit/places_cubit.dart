import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
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
      emit(PlacesErrorState('Something went wrong.'));
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
        emit(PlacesErrorState('Something went wrong.'));
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
      emit(PlacesErrorState('Something went wrong.'));
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
      emit(PlacesErrorState('Something went wrong.'));
    }
  }
}
