import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/add_stay_states.dart';

class AddStayCubit extends Cubit<AddStayStates> {
  AddStayCubit() : super(AddStayInitial());

  static AddStayCubit get(context) => BlocProvider.of(context);

  File? mainImage;
  List<File> galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      mainImage = File(image.path);
      emit(AddStayImageSelected());
    }
  }

  Future<void> pickGalleryImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      galleryImages.addAll(images.map((img) => File(img.path)));
      emit(AddStayImageSelected());
    }
  }

  void removeGalleryImage(int index) {
    galleryImages.removeAt(index);
    emit(AddStayImageSelected());
  }

  void submitStay({
    required String name,
    required String description,
    required String location,
    required double pricePerNight,
    required String propertyType,
  }) async {
    if (mainImage == null) {
      emit(AddStayError('Main image is required'));
      return;
    }
    if (name.isEmpty || description.isEmpty || location.isEmpty) {
      emit(AddStayError('Please fill in all required fields'));
      return;
    }

    emit(AddStayLoading());

    try {
      final ownerId = CacheHelper.getData('userId') ?? "69ef4f28a88bc7f8fd36b78e";
      
      // Parse location into city and state (mock logic)
      final locParts = location.split(',');
      final city = locParts.isNotEmpty ? locParts[0].trim() : 'Unknown';
      final state = locParts.length > 1 ? locParts[1].trim() : 'Unknown';

      final Map<String, dynamic> data = {
        "ownerId": ownerId,
        "cityName": city,
        "stateName": state,
        "Category": propertyType.toUpperCase(), // Maps UI property type or defaults
        "name": name,
        "description": description,
        "address": location,
        "latitude": 10.0,
        "longitude": 10.0,
        "phoneNumber": "22999888",
        "email": "test@test.tn",
        "averagePrice": pricePerNight,
        "mainImageUrl": "http://example.com",
        "images": [
          {
            "id": 1,
            "imageUrl": "https://virage.png.tn"
          }
        ]
      };

      await DioHelper.postData(
        url: EndPoints.places,
        data: data,
      );

      emit(AddStaySuccess());
    } catch (error) {
      debugPrint('[AddStayCubit] submitStay error: $error');
      emit(AddStayError('Something went wrong.'));
    }
  }
}
