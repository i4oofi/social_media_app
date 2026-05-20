import 'package:flutter/material.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class MainButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final double height;
  final bool isLoading;

  const MainButton({
    super.key,
    this.onPressed,
    this.child,
    this.height = 50,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : child,
      ),
    );
  }
}
