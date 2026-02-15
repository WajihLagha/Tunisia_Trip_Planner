import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


/// input field tnajem tbadel fih kima t7eb
Widget defaultInputField({
  required TextEditingController controler,
  required TextInputType keybord,
  bool obsecure = false,
  IconData? prefix,
  Color prefixColor = Colors.teal,
  Color suffixColor = Colors.teal,
  IconData? sufix,
  VoidCallback? sufixFunction,
  VoidCallback? onTap,
  Function(String)? onChange,
  Function(String)? onSubmit,
  required String text,
  bool enable = true,
  int? maxLine = 1,
  Color fillColor = Colors.white,
  Color borderColor = const Color(0xFFCCEBD9),
  FormFieldValidator<String>? validator,
}) =>
    TextFormField(
      controller: controler,
      keyboardType: keybord,
      obscureText: obsecure,
      validator: validator,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: text,
        hintText: text,
        hintStyle: TextStyle(
          color: prefixColor,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        prefixIcon: prefix != null
            ? Icon(prefix, color: prefixColor)
            : null,
        suffixIcon: sufix != null
            ? IconButton(
          icon: Icon(sufix),
          onPressed: sufixFunction,
          color: suffixColor,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: prefixColor, width: 1.5),
        ),
      ),
      onTap: onTap,
      enabled: enable,
      maxLines: maxLine,
      onChanged: onChange,
      onFieldSubmitted: onSubmit,
    );


/// custom message red : danger ,green :success, amber : warning
void showToast({
  required String msg,
  required ToastStates state,})
{
  Fluttertoast
      .showToast(
    msg: msg,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: chooseToastColor(state),
    textColor: Colors.white,
    fontSize: 12.0,
  );

}

enum ToastStates {success, warning, error}

Color chooseToastColor(ToastStates state){
  Color color;
  switch(state){
    case ToastStates.success :
      color = Colors.green;
      break;
    case ToastStates.warning :
      color = Colors.amber;
      break;
    case ToastStates.error :
      color = Colors.red;
      break;
  }
  return color;

}