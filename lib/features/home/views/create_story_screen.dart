import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class _CreateStoryScreenState extends State<CreateStoryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _repaintKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _canvasFade;
  late final Animation<Offset> _canvasSlide;
  late final Animation<double> _toolbarFade;

  // Canvas shimmer pulse (idle state)
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  // Share button press
  late final AnimationController _shareCtrl;
  late final Animation<double> _shareScale;

  // Background gradients — app palette extended
  final List<List<Color>> _backgroundGradients = [
    [const Color(0xFF007AFF), const Color(0xFF00C6FF)],          // Primary Blue
    [const Color(0xff8E54E9), const Color(0xffDD2476), const Color(0xffFF512F)],
    [const Color(0xff0f2027), const Color(0xff203a43), const Color(0xff2c5364)],
    [const Color(0xff02aab0), const Color(0xff00cdac)],
    [const Color(0xfff12711), const Color(0xfff5af19)],
    [const Color(0xFF1a1a2e), const Color(0xFF16213e), const Color(0xFF0f3460)],
    [const Color(0xff1f4037), const Color(0xff99f2c8)],
    [const Color(0xff000000), const Color(0xff434343)],
  ];

  final List<Color> _textColors = [
    Colors.white,
    Colors.black,
    AppColors.primaryColor,
    Colors.yellow,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orange,
    Colors.purpleAccent,
  ];

  int _selectedBgIndex = 0;
  int _selectedTextColorIndex = 0;
  TextAlign _textAlign = TextAlign.center;
  bool _textHasBackground = false;
  File? _backgroundImage;
  bool _isPrivate = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _canvasFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _canvasSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _toolbarFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _shareCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _shareScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _shareCtrl, curve: Curves.easeInOut),
    );

    _focusNode.addListener(() => setState(() {}));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _entranceCtrl.dispose();
    _pulseCtrl.dispose();
    _shareCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _backgroundImage = File(image.path));
      }
    } catch (e) {
      AppToast.showToast(
          msg: 'Error picking image: $e',
          backgroundColor: AppColors.red);
    }
  }

  void _changeAlignment() {
    HapticFeedback.selectionClick();
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
    setState(() => _isUploading = true);
    try {
      _focusNode.unfocus();
      await Future.delayed(const Duration(milliseconds: 150));

      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Failed to get render boundary');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to encode image');

      final pngBytes = byteData.buffer.asUint8List();
      final file = File(
          '${Directory.systemTemp.path}/story_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      await homeCubit.uploadStory(image: file, isPrivate: _isPrivate);

      if (mounted) {
        AppToast.showToast(
          msg: _isPrivate
              ? 'Story shared with close friends!'
              : 'Story shared successfully!',
          backgroundColor: AppColors.primaryColor,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showToast(
            msg: 'Failed to upload story: $e',
            backgroundColor: AppColors.red);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Toolbar ──────────────────────────────────────────
            FadeTransition(
              opacity: _toolbarFade,
              child: _TopToolbar(
                textAlign: _textAlign,
                textHasBackground: _textHasBackground,
                hasImage: _backgroundImage != null,
                onClose: () => Navigator.pop(context),
                onAlignTap: _changeAlignment,
                onHighlightTap: () =>
                    setState(() => _textHasBackground = !_textHasBackground),
                onPickImage: _pickImage,
                onRemoveImage: () => setState(() => _backgroundImage = null),
              ),
            ),

            // ── Canvas ───────────────────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: FadeTransition(
                    opacity: _canvasFade,
                    child: SlideTransition(
                      position: _canvasSlide,
                      child: ScaleTransition(
                        scale: _pulse,
                        child: AspectRatio(
                          aspectRatio: 9 / 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.35),
                                    blurRadius: 24,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: RepaintBoundary(
                                key: _repaintKey,
                                child: GestureDetector(
                                  onTap: () => FocusScope.of(context)
                                      .requestFocus(_focusNode),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Background
                                      if (_backgroundImage != null)
                                        Image.file(_backgroundImage!,
                                            fit: BoxFit.cover)
                                      else
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 400),
                                          curve: Curves.easeInOut,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _backgroundGradients[
                                                  _selectedBgIndex],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        ),

                                      // Subtle noise overlay
                                      if (_backgroundImage == null)
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.white.withValues(
                                                    alpha: 0.04),
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                    alpha: 0.15),
                                              ],
                                              begin: Alignment.topRight,
                                              end: Alignment.bottomLeft,
                                            ),
                                          ),
                                        ),

                                      // Text input
                                      Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(28.w),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h),
                                            decoration: _textHasBackground
                                                ? BoxDecoration(
                                                    color: _textColors[
                                                                _selectedTextColorIndex] ==
                                                            Colors.white
                                                        ? Colors.black
                                                            .withValues(
                                                                alpha: 0.55)
                                                        : Colors.white
                                                            .withValues(
                                                                alpha: 0.75),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.r),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.2),
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                            child: IntrinsicWidth(
                                              child: TextField(
                                                controller: _textController,
                                                focusNode: _focusNode,
                                                maxLines: null,
                                                keyboardType:
                                                    TextInputType.multiline,
                                                textAlign: _textAlign,
                                                style: TextStyle(
                                                  color: _textColors[
                                                      _selectedTextColorIndex],
                                                  fontSize: 26.sp,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.3,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.3),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                decoration: InputDecoration(
                                                  hintText:
                                                      'Tap to write something…',
                                                  hintStyle: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.45),
                                                    fontSize: 22.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.zero,
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
                  ),
                ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Color / Gradient Picker ──────────────────────────────
            FadeTransition(
              opacity: _toolbarFade,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _focusNode.hasFocus
                    ? _ColorPicker(
                        key: const ValueKey('text_colors'),
                        colors: _textColors
                            .map((c) => [c, c])
                            .toList(),
                        selectedIndex: _selectedTextColorIndex,
                        onSelect: (i) =>
                            setState(() => _selectedTextColorIndex = i),
                        isSolid: true,
                      )
                    : _ColorPicker(
                        key: const ValueKey('bg_gradients'),
                        colors: _backgroundGradients,
                        selectedIndex: _selectedBgIndex,
                        onSelect: (i) => setState(() {
                          _backgroundImage = null;
                          _selectedBgIndex = i;
                        }),
                      ),
              ),
            ),

            SizedBox(height: 12.h),

            // ── Bottom Bar — Privacy + Share ─────────────────────────
            FadeTransition(
              opacity: _toolbarFade,
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Privacy toggle
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isPrivate = !_isPrivate);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _isPrivate
                              ? AppColors.primaryColor.withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: _isPrivate
                                ? AppColors.primaryColor
                                : Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                _isPrivate
                                    ? Icons.star_rounded
                                    : Icons.public_rounded,
                                key: ValueKey(_isPrivate),
                                color: _isPrivate
                                    ? AppColors.primaryColor
                                    : Colors.white70,
                                size: 17.sp,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Text(
                              _isPrivate
                                  ? 'Close Friends'
                                  : 'Public Story',
                              style: TextStyle(
                                color: _isPrivate
                                    ? AppColors.primaryColor
                                    : Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Share button
                    GestureDetector(
                      onTapDown: (_) => _shareCtrl.forward(),
                      onTapUp: (_) async {
                        await _shareCtrl.reverse();
                        if (!_isUploading) _shareStory(homeCubit);
                      },
                      onTapCancel: () => _shareCtrl.reverse(),
                      child: ScaleTransition(
                        scale: _shareScale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: EdgeInsets.symmetric(
                              horizontal: 26.w, vertical: 13.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isUploading
                                  ? [Colors.grey, Colors.grey]
                                  : [
                                      AppColors.primaryColor,
                                      const Color(0xFF00C6FF),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: _isUploading
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: _isUploading
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Share',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(Icons.send_rounded,
                                        color: Colors.white, size: 15.sp),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Toolbar ────────────────────────────────────────────────────────────────

class _TopToolbar extends StatelessWidget {
  final TextAlign textAlign;
  final bool textHasBackground;
  final bool hasImage;
  final VoidCallback onClose;
  final VoidCallback onAlignTap;
  final VoidCallback onHighlightTap;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const _TopToolbar({
    required this.textAlign,
    required this.textHasBackground,
    required this.hasImage,
    required this.onClose,
    required this.onAlignTap,
    required this.onHighlightTap,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToolbarIcon(
            icon: Icons.close_rounded,
            onTap: onClose,
          ),
          Row(
            children: [
              _ToolbarIcon(
                icon: textAlign == TextAlign.center
                    ? Icons.format_align_center_rounded
                    : textAlign == TextAlign.left
                        ? Icons.format_align_left_rounded
                        : Icons.format_align_right_rounded,
                onTap: onAlignTap,
              ),
              _ToolbarIcon(
                icon: textHasBackground
                    ? Icons.font_download_rounded
                    : Icons.font_download_off_rounded,
                onTap: onHighlightTap,
                active: textHasBackground,
              ),
              _ToolbarIcon(
                icon: Icons.photo_library_outlined,
                onTap: onPickImage,
              ),
              if (hasImage)
                _ToolbarIcon(
                  icon: Icons.no_photography_outlined,
                  onTap: onRemoveImage,
                  color: Colors.redAccent,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Color? color;

  const _ToolbarIcon({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.color,
  });

  @override
  State<_ToolbarIcon> createState() => _ToolbarIconState();
}

class _ToolbarIconState extends State<_ToolbarIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.25)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.25, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 60),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.color ??
        (widget.active ? AppColors.primaryColor : Colors.white);
    return GestureDetector(
      onTap: () {
        _ctrl.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.all(8.w),
          decoration: widget.active
              ? BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                )
              : null,
          child: Icon(widget.icon, color: iconColor, size: 22.sp),
        ),
      ),
    );
  }
}

// ── Color / Gradient Picker ────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final List<List<Color>> colors;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool isSolid;

  const _ColorPicker({
    super.key,
    required this.colors,
    required this.selectedIndex,
    required this.onSelect,
    this.isSolid = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          final gradient = colors[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              width: isSelected ? 40.w : 34.w,
              height: isSelected ? 40.w : 34.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSolid ? gradient.first : null,
                gradient: isSolid
                    ? null
                    : LinearGradient(
                        colors: gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.25),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: gradient.first.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
            ),
          );
        },
      ),
    );
  }
}
