import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingPageContent extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingPageContent({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),
          // Illustration Container
          SizedBox(
            height: 250.h,
            child: SvgPicture.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(flex: 2),
          // Title text
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.sp,
              fontFamily: 'SF Pro Text',
              fontWeight: FontWeight.w800,
              height: 1.5.h,
            ),
          ),
          SizedBox(height: 16.h),
          // Description text
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontFamily: 'SF Pro Text',
              fontWeight: FontWeight.w300,
              height: 1.5.h,
            ),
          ),
          const Spacer(flex: 4),
        ],
      ),
    );
  }
}
