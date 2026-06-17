import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double? height;

  CustomVideoPlayer({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.height,
  }) : assert(
         videoUrl != null || videoFile != null,
         'Must provide either videoUrl or videoFile',
       );

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showControls = true;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    if (widget.videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
    } else {
      _controller = VideoPlayerController.file(widget.videoFile!);
    }

    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
          }
        })
        .catchError((error) {
          debugPrint('Video Player initialization error: $error');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
        });

    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _wasPlaying = false;
      } else {
        _controller.play();
        _wasPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      if (_controller.value.volume > 0) {
        _controller.setVolume(0);
      } else {
        _controller.setVolume(1.0);
      }
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || !_isInitialized) return;

    if (info.visibleFraction <= 0.05) {
      if (_controller.value.isPlaying) {
        _wasPlaying = true;
        _controller.pause();
      }
    } else {
      if (_wasPlaying && !_controller.value.isPlaying) {
        _controller.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: widget.height ?? 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: AppColors.red, size: 40.h),
              SizedBox(height: 8.h),
              Text(
                'Error playing video',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        height: widget.height ?? 220,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return VisibilityDetector(
      key: Key(
        widget.videoUrl ?? widget.videoFile?.path ?? UniqueKey().toString(),
      ),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),

                // Animated controls overlay
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      color: Colors.black38,
                      child: Stack(
                        children: [
                          // Center play/pause
                          Align(
                            alignment: Alignment.center,
                            child: IconButton(
                              iconSize: 56,
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_filled_rounded,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlay,
                            ),
                          ),

                          // Bottom bar
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black26,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0.w,
                                vertical: 8.0.h,
                              ),
                              child: Row(
                                children: [
                                  // Mute button
                                  IconButton(
                                    iconSize: 22,
                                    icon: Icon(
                                      _controller.value.volume == 0
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: _toggleMute,
                                  ),

                                  // Current time / duration
                                  Text(
                                    _formatDuration(_controller.value.position),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    ' / ',
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(_controller.value.duration),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                  ),

                                  // Expandable slider
                                  Expanded(
                                    child: VideoProgressIndicator(
                                      _controller,
                                      allowScrubbing: true,
                                      colors: VideoProgressColors(
                                        playedColor: AppColors.primaryColor,
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.white12,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12.0.w,
                                        vertical: 8.0.h,
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
