import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/core/shared/widgets/app_toast.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _repaintKey = GlobalKey();

  // Background Options (Instagram style gradients and solids)
  final List<List<Color>> _backgroundGradients = [
    [const Color(0xff8E54E9), const Color(0xffDD2476), const Color(0xffFF512F)], // Instagram Sunset
    [const Color(0xff0f2027), const Color(0xff203a43), const Color(0xff2c5364)], // Deep Space
    [const Color(0xff02aab0), const Color(0xff00cdac)], // Neon Blue/Green
    [const Color(0xfff12711), const Color(0xfff5af19)], // Flame Sunset
    [const Color(0xffeecda3), const Color(0xffef629f)], // Lavender Sweet
    [const Color(0xff000000), const Color(0xff000000)], // Pure Black
    [const Color(0xff1f4037), const Color(0xff99f2c8)], // Forest Green
  ];

  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
  ];

  int _selectedBgIndex = 0;
  int _selectedTextColorIndex = 0;
  TextAlign _textAlign = TextAlign.center;
  bool _textHasBackground = false;
  File? _backgroundImage;
  bool _isPrivate = false;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _backgroundImage = File(image.path);
        });
      }
    } catch (e) {
      AppToast.showToast(msg: "Error picking image: $e", backgroundColor: AppColors.red);
    }
  }

  void _changeAlignment() {
    setState(() {
      if (_textAlign == TextAlign.center) {
        _textAlign = TextAlign.left;
      } else if (_textAlign == TextAlign.left) {
        _textAlign = TextAlign.right;
      } else {
        _textAlign = TextAlign.center;
      }
    });
  }

  Future<void> _shareStory(HomeCubit homeCubit) async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Unfocus text to hide cursor/keyboard and wait for completion
      _focusNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 150));

      // 2. Render the canvas repaint boundary to bytes
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception("Failed to get render boundary");
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to get image byte data");
      }

      final pngBytes = byteData.buffer.asUint8List();

      // 3. Write bytes to temporary file
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/story_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // 4. Upload story using HomeCubit
      await homeCubit.uploadStory(image: file, isPrivate: _isPrivate);

      if (mounted) {
        AppToast.showToast(
          msg: _isPrivate ? "Private Story shared successfully!" : "Story shared successfully!",
          backgroundColor: AppColors.primaryColor,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showToast(
          msg: "Failed to upload story: ${e.toString()}",
          backgroundColor: AppColors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get HomeCubit passed via BlocProvider.value in route args
    final homeCubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Controls Bar ─────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 28.h),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      // Text alignment button
                      IconButton(
                        icon: Icon(
                          _textAlign == TextAlign.center
                              ? Icons.format_align_center
                              : _textAlign == TextAlign.left
                                  ? Icons.format_align_left
                                  : Icons.format_align_right,
                          color: Colors.white,
                          size: 24.h,
                        ),
                        onPressed: _changeAlignment,
                      ),
                      // Text highlight button
                      IconButton(
                        icon: Icon(
                          _textHasBackground ? Icons.font_download : Icons.font_download_outlined,
                          color: Colors.white,
                          size: 24.h,
                        ),
                        onPressed: () {
                          setState(() {
                            _textHasBackground = !_textHasBackground;
                          });
                        },
                      ),
                      // Image Background Picker button
                      IconButton(
                        icon: Icon(Icons.photo_library_outlined, color: Colors.white, size: 24.h),
                        onPressed: _pickImage,
                      ),
                      if (_backgroundImage != null)
                        IconButton(
                          icon: Icon(Icons.no_photography_outlined, color: Colors.redAccent, size: 24.h),
                          onPressed: () {
                            setState(() {
                              _backgroundImage = null;
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Story Canvas (RepaintBoundary) ───────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(_focusNode);
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background (Image or Gradient)
                              if (_backgroundImage != null)
                                Image.file(
                                  _backgroundImage!,
                                  fit: BoxFit.cover,
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: _backgroundGradients[_selectedBgIndex],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),

                              // Centered Text Input Container
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32.0.w),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                    decoration: _textHasBackground
                                        ? BoxDecoration(
                                            color: _textColors[_selectedTextColorIndex] == Colors.white
                                                ? Colors.black.withValues(alpha: 0.55)
                                                : Colors.white.withValues(alpha: 0.7),
                                            borderRadius: BorderRadius.circular(8.r),
                                          )
                                        : null,
                                    child: IntrinsicWidth(
                                      child: TextField(
                                        controller: _textController,
                                        focusNode: _focusNode,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        textAlign: _textAlign,
                                        style: TextStyle(
                                          color: _textColors[_selectedTextColorIndex],
                                          fontSize: 26.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Type something...",
                                          hintStyle: TextStyle(color: Colors.white54, fontSize: 26.sp),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // ── Color Text Picker & Background Selector ──────────
            if (_focusNode.hasFocus)
              // Text Color Selector when editing text
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _textColors.length,
                  itemBuilder: (context, index) {
                    final color = _textColors[index];
                    final isSelected = _selectedTextColorIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTextColorIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.w,
                          ),
                          boxShadow: [
                            if (isSelected)
                              const BoxShadow(color: Colors.black26, blurRadius: 4, spreadRadius: 1)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              // Background Gradient Selector when not editing text
              SizedBox(
                height: 48.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _backgroundGradients.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedBgIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _backgroundImage = null; // Clear image if selecting gradient
                          _selectedBgIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _backgroundGradients[index],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white24,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            SizedBox(height: 16.h),

            // ── Privacy Settings & Share Action Row ─────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 8.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Privacy Mode Selector (Public/Private)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPrivate = !_isPrivate;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: _isPrivate
                            ? Colors.green.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: _isPrivate ? Colors.green : Colors.transparent,
                          width: 1.w,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isPrivate ? Icons.star : Icons.public,
                            color: _isPrivate ? Colors.green : Colors.white,
                            size: 18.h,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _isPrivate ? "Close Friends" : "Public Story",
                            style: TextStyle(
                              color: _isPrivate ? Colors.green : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Share Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _isUploading ? null : () => _shareStory(homeCubit),
                    child: _isUploading
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                "Share",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_forward_ios, size: 12.h),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
