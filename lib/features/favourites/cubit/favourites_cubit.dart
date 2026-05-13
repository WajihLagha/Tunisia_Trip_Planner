import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_states.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';

class FavouritesCubit extends Cubit<FavouritesStates> {
  final String? userId;

  FavouritesCubit({this.userId}) : super(FavouritesInitial());

  static FavouritesCubit get(context) => BlocProvider.of(context);

  String get _placesKey => 'fav_places_${userId ?? "guest"}';
  String get _accommodationsKey => 'fav_accommodations_${userId ?? "guest"}';
  String get _transportsKey => 'fav_transports_${userId ?? "guest"}';

  Set<String> _placeIds = {};
  Set<String> _accommodationIds = {};
  Set<String> _transportIds = {};

  // ── Load ──────────────────────────────────────────────────────────────────
  void loadFavourites() {
    final rawPlaces = CacheHelper.getData(_placesKey);
    final rawAccom = CacheHelper.getData(_accommodationsKey);
    final rawTransport = CacheHelper.getData(_transportsKey);

    _placeIds = rawPlaces != null
        ? Set<String>.from((rawPlaces as List).cast<String>())
        : {};
    _accommodationIds = rawAccom != null
        ? Set<String>.from((rawAccom as List).cast<String>())
        : {};
    _transportIds = rawTransport != null
        ? Set<String>.from((rawTransport as List).cast<String>())
        : {};

    _emitLoaded();
  }

  // ── Place Favourites ───────────────────────────────────────────────────────
  bool isPlaceFavourite(String id) => _placeIds.contains(id);

  Future<void> togglePlaceFavourite(String id) async {
    if (_placeIds.contains(id)) {
      _placeIds.remove(id);
    } else {
      _placeIds.add(id);
    }
    await _persistPlaces();
    _emitLoaded();
  }

  // ── Accommodation Favourites ───────────────────────────────────────────────
  bool isAccommodationFavourite(String id) => _accommodationIds.contains(id);

  Future<void> toggleAccommodationFavourite(String id) async {
    if (_accommodationIds.contains(id)) {
      _accommodationIds.remove(id);
    } else {
      _accommodationIds.add(id);
    }
    await _persistAccommodations();
    _emitLoaded();
  }

  // ── Transport Favourites ───────────────────────────────────────────────────
  bool isTransportFavourite(String id) => _transportIds.contains(id);

  Future<void> toggleTransportFavourite(String id) async {
    if (_transportIds.contains(id)) {
      _transportIds.remove(id);
    } else {
      _transportIds.add(id);
    }
    await _persistTransports();
    _emitLoaded();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _emitLoaded() {
    emit(FavouritesLoaded(
      favouritePlaceIds: Set.from(_placeIds),
      favouriteAccommodationIds: Set.from(_accommodationIds),
      favouriteTransportIds: Set.from(_transportIds),
    ));
  }

  Future<void> _persistPlaces() async {
    await CacheHelper.putData(key: _placesKey, value: _placeIds.toList());
  }

  Future<void> _persistAccommodations() async {
    await CacheHelper.putData(
        key: _accommodationsKey, value: _accommodationIds.toList());
  }

  Future<void> _persistTransports() async {
    await CacheHelper.putData(
        key: _transportsKey, value: _transportIds.toList());
  }
}
