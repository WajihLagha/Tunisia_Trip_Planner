import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/profile/cubit/profile_states.dart';
import 'package:tunisian_trip_planner/features/profile/models/user_model.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  ProfileCubit() : super(ProfileInitialState()) {
    _loadSavedProfileImage();
  }

  static ProfileCubit get(context) => BlocProvider.of(context);

  bool isDarkMode = false;
  UserModel? user;
  String selectedProfileImage = 'assets/images/profile/default_profile.jpg';

  void _loadSavedProfileImage() {
    final savedPath = CacheHelper.getData('profile_image_path') as String?;
    if (savedPath != null && savedPath.isNotEmpty) {
      selectedProfileImage = savedPath;
    }
  }

  void changeProfileImage(String path) {
    selectedProfileImage = path;
    CacheHelper.putData(key: 'profile_image_path', value: path);
    emit(ProfileImageUpdatedState());
  }

  void toggleTheme(bool value) {
    isDarkMode = value;
    emit(ProfileThemeChangedState(isDarkMode));
  }

  Future<void> loadUserProfile() async {
    emit(ProfileLoadingState());
    try {
      String? userId = CacheHelper.getData('userId') as String?;
      
      // Fallback to the ID from the Postman screenshot if not logged in
      if (userId == null || userId.isEmpty) {
        userId = '69ef4f28a88bc7f8fd36b78e';
      }
      
      debugPrint('[ProfileCubit] loading user, id=$userId');

      final response = await DioHelper.getData(
        url: EndPoints.users,
        headers: {'X-User-Id': userId},
      );

      // Response structure: { "data": [...], "message": "user found", "statusCode": 200 }
      final Map<String, dynamic> body =
          response.data is Map ? response.data as Map<String, dynamic> : {};
      final dynamic data = body['data'];

      Map<String, dynamic>? userJson;
      if (data is List && data.isNotEmpty) {
        // API returns data as an array — take the first element
        userJson = data.first as Map<String, dynamic>?;
      } else if (data is Map<String, dynamic>) {
        // Fallback: data might be a plain object
        userJson = data;
      }

      if (userJson != null) {
        user = UserModel.fromJson(userJson);
        debugPrint('[ProfileCubit] loaded user: ${user?.userName}');
        emit(ProfileLoadedState(user!));
      } else {
        emit(ProfileErrorState('Unexpected response format'));
      }
    } catch (e, st) {
      debugPrint('[ProfileCubit] loadUserProfile error: $e');
      debugPrint('[ProfileCubit] Stack: $st');
      emit(ProfileErrorState('Something went wrong.'));
    }
  }

  void logout() {
    user = null;
  }
}
