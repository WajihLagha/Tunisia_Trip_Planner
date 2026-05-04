import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

    // Mock API call
    try {
      await Future.delayed(const Duration(seconds: 2));
      emit(AddStaySuccess());
    } catch (error) {
      emit(AddStayError(error.toString()));
    }
  }
}
