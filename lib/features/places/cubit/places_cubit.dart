import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/places/cubit/places_states.dart';
import 'package:tunisian_trip_planner/features/places/data/mock_places_data.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
class PlacesCubit extends Cubit<PlacesStates> {
  PlacesCubit() : super(PlacesInitialState());

  static PlacesCubit get(context) => BlocProvider.of(context);

  PlacesCategory? selectedCategory;
  double minRating = 0.0;
  String _searchQuery = '';

  void loadPlaces() async {
    emit(PlacesLoadingState());
    await Future.delayed(const Duration(milliseconds: 800));
    if (isClosed) return;
    try {
      final places = MockPlacesData.places;
      emit(PlacesLoadedState(
        places: places,
        filteredPlaces: places,
        selectedCategory: null,
        minRating: 0.0,
      ));
    } catch (e) {
      emit(PlacesErrorState('Failed to load places'));
    }
  }

  void _applyFilters(List<PlacesResponse> allPlaces) {
    final results = allPlaces.where((place) {
      final matchesCategory =
          selectedCategory == null || place.category == selectedCategory;
      final matchesRating = (place.rating ?? 0.0) >= minRating;
      final matchesSearch = _searchQuery.isEmpty ||
          (place.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (place.cityName
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      return matchesCategory && matchesRating && matchesSearch;
    }).toList();

    emit(PlacesLoadedState(
      places: allPlaces,
      filteredPlaces: results,
      selectedCategory: selectedCategory,
      minRating: minRating,
    ));
  }

  void filterByCategory(PlacesCategory? category) {
    if (state is PlacesLoadedState) {
      selectedCategory = category;
      _applyFilters((state as PlacesLoadedState).places);
    }
  }

  void filterByRating(double rating) {
    if (state is PlacesLoadedState) {
      minRating = rating;
      _applyFilters((state as PlacesLoadedState).places);
    }
  }

  void applyFilters({PlacesCategory? category, required double rating}) {
    if (state is PlacesLoadedState) {
      selectedCategory = category;
      minRating = rating;
      _applyFilters((state as PlacesLoadedState).places);
    }
  }

  void resetFilters() {
    selectedCategory = null;
    minRating = 0.0;
    _searchQuery = '';
    if (state is PlacesLoadedState) {
      final allPlaces = (state as PlacesLoadedState).places;
      emit(PlacesLoadedState(
        places: allPlaces,
        filteredPlaces: allPlaces,
        selectedCategory: null,
        minRating: 0.0,
      ));
    }
  }

  void searchPlaces(String query) {
    if (state is PlacesLoadedState) {
      _searchQuery = query;
      _applyFilters((state as PlacesLoadedState).places);
    }
  }
}
