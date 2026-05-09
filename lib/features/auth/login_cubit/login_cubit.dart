import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/auth/login_cubit/login_states.dart';
import 'package:tunisian_trip_planner/features/auth/models/login_model.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isShown = true;
  late LoginModel loginModel;

  void changePasswordVisibility() {
    isShown = !isShown;
    emit(LoginShowPasswordState());
  }

  void userLogin({
    required String username,
    required String password,
  }) {
    emit(LoginLoading());

    DioHelper.postData(
      url: EndPoints.keycloakBaseUrl,
      contentType: 'application/x-www-form-urlencoded',
      data: {
        'client_id': 'oauth-pkce',
        'grant_type': 'password',
        'username': username,
        'password': password,
      },
    ).then((value) {
      loginModel = LoginModel.fromJson(value.data);
      emit(LoginSuccess(loginModel));
    }).catchError((error) {
      debugPrint('[LoginCubit] userLogin error: $error');
      emit(LoginError('Something went wrong. Please try again.'));
    });
  }
}