import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/admin/cubit/admin_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_response.dart';
import 'package:tunisian_trip_planner/features/accommodation/models/accommodation.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';
import 'package:flutter/foundation.dart';

class AdminCubit extends Cubit<AdminStates> {
  AdminCubit() : super(AdminInitialState());

  static AdminCubit get(context) => BlocProvider.of(context);

  List<PlacesResponse> inactivePlaces = [];
  List<AccommodationDto> inactiveAccommodations = [];
  List<TransportModel> inactiveTransports = [];

  // ── Fetch Inactive Data ───────────────────────────────────────────────────

  Future<void> getInactivePlaces() async {
    emit(AdminLoadingPlacesState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.adminPlacesInactive,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['content'] ?? response.data;
        inactivePlaces =
            data.map((json) => PlacesResponse.fromJson(json)).toList();
        emit(AdminLoadedPlacesState());
      } else {
        emit(AdminErrorPlacesState('Failed to fetch inactive places.'));
      }
    } catch (e) {
      debugPrint('[AdminCubit] getInactivePlaces error: $e');
      emit(AdminErrorPlacesState(e.toString()));
    }
  }

  Future<void> getInactiveAccommodations() async {
    emit(AdminLoadingAccommodationsState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.adminAccommodationsInactive,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['content'] ?? response.data;
        inactiveAccommodations =
            data.map((json) => AccommodationDto.fromJson(json)).toList();
        emit(AdminLoadedAccommodationsState());
      } else {
        emit(AdminErrorAccommodationsState(
            'Failed to fetch inactive accommodations.'));
      }
    } catch (e) {
      debugPrint('[AdminCubit] getInactiveAccommodations error: $e');
      emit(AdminErrorAccommodationsState(e.toString()));
    }
  }

  Future<void> getInactiveTransports() async {
    emit(AdminLoadingTransportsState());
    try {
      final response = await DioHelper.getData(
        url: EndPoints.adminTransportsInactive,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data =
            response.data['content'] ?? response.data;
        inactiveTransports =
            data.map((json) => TransportModel.fromJson(json)).toList();
        emit(AdminLoadedTransportsState());
      } else {
        emit(AdminErrorTransportsState('Failed to fetch inactive transports.'));
      }
    } catch (e) {
      debugPrint('[AdminCubit] getInactiveTransports error: $e');
      emit(AdminErrorTransportsState(e.toString()));
    }
  }

  // ── Activate Endpoints ────────────────────────────────────────────────────

  Future<void> activatePlace(String id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.putData(
        url: EndPoints.adminActivatePlace(id),
        data: {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactivePlaces.removeWhere((p) => p.id == id);
        emit(AdminActionSuccessState('Place activated successfully!'));
        emit(AdminLoadedPlacesState()); // Refresh UI
      } else {
        emit(AdminActionErrorState('Failed to activate place.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }

  Future<void> activateAccommodation(int id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.patchData(
        url: EndPoints.adminActivateAccommodation(id),
        data: {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactiveAccommodations.removeWhere((a) => a.id == id);
        emit(AdminActionSuccessState('Accommodation activated successfully!'));
        emit(AdminLoadedAccommodationsState());
      } else {
        emit(AdminActionErrorState('Failed to activate accommodation.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }

  Future<void> activateTransport(int id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.patchData(
        url: EndPoints.adminActivateTransport(id),
        data: {},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactiveTransports.removeWhere((t) => t.id == id);
        emit(AdminActionSuccessState('Transport activated successfully!'));
        emit(AdminLoadedTransportsState());
      } else {
        emit(AdminActionErrorState('Failed to activate transport.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }

  // ── Delete Endpoints ──────────────────────────────────────────────────────

  Future<void> deletePlace(String id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.deleteData(
        url: 'places/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactivePlaces.removeWhere((p) => p.id == id);
        emit(AdminActionSuccessState('Place deleted successfully!'));
        emit(AdminLoadedPlacesState());
      } else {
        emit(AdminActionErrorState('Failed to delete place.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }

  Future<void> deleteAccommodation(int id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.deleteData(
        url: 'accommodations/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactiveAccommodations.removeWhere((a) => a.id == id);
        emit(AdminActionSuccessState('Accommodation deleted successfully!'));
        emit(AdminLoadedAccommodationsState());
      } else {
        emit(AdminActionErrorState('Failed to delete accommodation.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }

  Future<void> deleteTransport(int id) async {
    emit(AdminActionLoadingState());
    try {
      final response = await DioHelper.deleteData(
        url: 'transports/$id',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        inactiveTransports.removeWhere((t) => t.id == id);
        emit(AdminActionSuccessState('Transport deleted successfully!'));
        emit(AdminLoadedTransportsState());
      } else {
        emit(AdminActionErrorState('Failed to delete transport.'));
      }
    } catch (e) {
      emit(AdminActionErrorState(e.toString()));
    }
  }
}
