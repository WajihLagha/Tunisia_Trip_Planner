import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/auth/register_cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterInitial());

  static RegisterCubit get(context) => BlocProvider.of(context);

  bool isPasswordShown = true;
  bool isConfirmShown = true;

  // 0 = Empty, 1 = Weak, 2 = Medium, 3 = Strong
  int passwordStrengthLevel = 0;

  void changePasswordVisibility() {
    isPasswordShown = !isPasswordShown;
    emit(RegisterPasswordVisibilityChange());
  }

  void changeConfirmVisibility() {
    isConfirmShown = !isConfirmShown;
    emit(RegisterPasswordVisibilityChange());
  }

  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      passwordStrengthLevel = 0;
    } else if (password.length < 6) {
      passwordStrengthLevel = 1; // Weak
    } else if (password.length < 8 || !password.contains(RegExp(r'[0-9]'))) {
      passwordStrengthLevel = 2; // Medium
    } else {
      passwordStrengthLevel = 3; // Strong
    }
    emit(RegisterPasswordStrengthChange());
  }
}