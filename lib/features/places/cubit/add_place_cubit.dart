import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class AddPlaceCubit extends Cubit<AddPlaceStates> {
  AddPlaceCubit() : super(AddPlaceInitial());

  static AddPlaceCubit get(context) => BlocProvider.of(context);

  // Image URLs (instead of File uploads)
  String mainImageUrl = '';
  List<String> galleryImageUrls = [];

  void setMainImageUrl(String url) {
    mainImageUrl = url.trim();
    emit(AddPlaceImageSelected());
  }

  void addGalleryImageUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isNotEmpty && !galleryImageUrls.contains(trimmed)) {
      galleryImageUrls.add(trimmed);
      emit(AddPlaceImageSelected());
    }
  }

  void removeGalleryImage(int index) {
    galleryImageUrls.removeAt(index);
    emit(AddPlaceImageSelected());
  }

  void submitPlace({
    required String name,
    required String description,
    required String cityName,
    required String stateName,
    required String address,
    required String phoneNumber,
    required String email,
    required double averagePrice,
    required double latitude,
    required double longitude,
    required PlacesCategory category,
  }) async {
    if (mainImageUrl.isEmpty) {
      emit(AddPlaceError('Main image URL is required'));
      return;
    }
    if (name.isEmpty || description.isEmpty || cityName.isEmpty ||
        stateName.isEmpty || address.isEmpty) {
      emit(AddPlaceError('Please fill in all required fields'));
      return;
    }

    emit(AddPlaceLoading());

    try {
      final ownerId = CacheHelper.getData('userId') ?? '69ef4f28a88bc7f8fd36b78e';

      final Map<String, dynamic> data = {
        'ownerId': ownerId,
        'cityName': cityName,
        'stateName': stateName,
        'Category': category.name.toUpperCase(),
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phoneNumber': phoneNumber.isNotEmpty ? phoneNumber : null,
        'email': email.isNotEmpty ? email : null,
        'averagePrice': averagePrice,
        'mainImageUrl': mainImageUrl,
        'images': galleryImageUrls.asMap().entries.map((e) => {
          'id': e.key + 1,
          'imageUrl': e.value,
        }).toList(),
      };

      await DioHelper.postData(url: EndPoints.places, data: data);
      emit(AddPlaceSuccess());
    } catch (error) {
      debugPrint('[AddPlaceCubit] submitPlace error: $error');
      emit(AddPlaceError('Something went wrong.'));
    }
  }
}
