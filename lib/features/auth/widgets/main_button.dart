import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final double height;
  final bool isLoading;
  final double? width;
  final String? text;
  final bool transparent;
  MainButton({
    super.key,
    this.onPressed,
    this.child,
    this.height = 50,
    this.isLoading = false,
    this.width,
    this.text,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: transparent
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColors.primaryColor,
          foregroundColor: transparent 
              ? (isDark ? Colors.white : AppColors.black) 
              : AppColors.white,
          side: BorderSide(
            color: transparent ? AppColors.grey : Colors.transparent,
            width: 2.w,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          elevation: 0,
        ),
        child: isLoading
            ? CircularProgressIndicator(color: AppColors.white)
            : text != null
            ? Text(text!, style: TextStyle())
            : child,
      ),
    );
  }
}
