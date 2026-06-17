import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:social_media_app/core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;

  UserAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    this.radius = 24,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
  });

  bool get _hasValidUrl {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return false;
    try {
      final uri = Uri.parse(imageUrl!);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  String get _initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  List<Color> _getGradientForName(String name) {
    if (name.isEmpty) {
      return [const Color(0xff4776E6), const Color(0xff8E54E9)];
    }
    final int hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    final List<List<Color>> gradients = [
      [const Color(0xffFF512F), const Color(0xffDD2476)], // Red-Orange
      [const Color(0xff4776E6), const Color(0xff8E54E9)], // Purple-Blue
      [const Color(0xff00B0FF), const Color(0xff00E5FF)], // Cyan-Blue
      [const Color(0xff11998e), const Color(0xff38ef7d)], // Green-Teal
      [const Color(0xfff857a6), const Color(0xffff5858)], // Pink-Red
      [const Color(0xffFF8C00), const Color(0xffFFA500)], // Orange
      [const Color(0xff8A2387), const Color(0xffE94057)], // Purple-Pink
    ];
    return gradients[hash % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    
    Widget avatarChild;
    if (_hasValidUrl) {
      avatarChild = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.dividerColor,
          ),
          child: Center(
            child: SizedBox(
              width: 16.w,
              height: 16.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsPlaceholder(size),
      );
    } else {
      avatarChild = _buildInitialsPlaceholder(size);
    }

    if (showBorder) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? AppColors.primaryColor,
            width: borderWidth,
          ),
        ),
        child: avatarChild,
      );
    }

    return avatarChild;
  }

  Widget _buildInitialsPlaceholder(double size) {
    final gradientColors = _getGradientForName(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
