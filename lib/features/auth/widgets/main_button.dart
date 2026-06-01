import 'package:flutter/material.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final double height;
  final bool isLoading;
  final double? width;
  final String? text;
  final bool transparent;
  const MainButton({
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
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: transparent
              ? AppColors.white
              : AppColors.primaryColor,
          foregroundColor: transparent ? AppColors.black : AppColors.white,
          side: BorderSide(
            color: transparent ? AppColors.grey : AppColors.trasparent,
            width: 2,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : text != null
            ? Text(text!, style: const TextStyle())
            : child,
      ),
    );
  }
}
