import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/auth/login_cubit/login_states.dart';

class LoginCubit extends Cubit<LoginState>{

  LoginCubit() : super(LoginInitial());

  static LoginCubit get(context) => BlocProvider.of(context);

  bool isShown = true;

  void changePasswordVisibility(){
    isShown = !isShown;
    emit(LoginShowPasswordState());
  }

}