import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';

class AddPlaceCubit extends Cubit<AddPlaceStates> {
  AddPlaceCubit() : super(AddPlaceInitial());

  static AddPlaceCubit get(context) => BlocProvider.of(context);

  File? mainImage;
  List<File> galleryImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickMainImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      mainImage = File(image.path);
      emit(AddPlaceImageSelected());
    }
  }

  Future<void> pickGalleryImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      galleryImages.addAll(images.map((img) => File(img.path)));
      emit(AddPlaceImageSelected());
    }
  }

  void removeGalleryImage(int index) {
    galleryImages.removeAt(index);
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
    required PlacesCategory category,
  }) async {
    if (mainImage == null) {
      emit(AddPlaceError('Main image is required'));
      return;
    }
    if (name.isEmpty || description.isEmpty || cityName.isEmpty || stateName.isEmpty || address.isEmpty) {
      emit(AddPlaceError('Please fill in all required fields'));
      return;
    }

    emit(AddPlaceLoading());

    // Mock API call to create a place
    try {
      await Future.delayed(const Duration(seconds: 2)); // Simulate network request

      // Since we don't have a real backend connected, we just log and succeed.
      // In a real scenario, we'd upload the images and construct a PlacesRequest object.
      emit(AddPlaceSuccess());
    } catch (error) {
      emit(AddPlaceError(error.toString()));
    }
  }
}
