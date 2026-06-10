import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class AppToast {
  static void showToast({
    required String msg,
    Color? backgroundColor,
    Color? textColor,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 1,
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      textColor: textColor ?? AppColors.white,
      fontSize: 16.0,
    );
  }
}
