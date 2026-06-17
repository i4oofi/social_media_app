import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ReelVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const ReelVideoPlayer({super.key, required this.videoUrl});

  @override
  State<ReelVideoPlayer> createState() => _ReelVideoPlayerState();
}

class _ReelVideoPlayerState extends State<ReelVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _wasPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.setLooping(true);
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _wasPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
        _wasPlaying = true;
      }
    });
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || !_isInitialized) return;
    
    if (info.visibleFraction <= 0.05) {
      if (_controller.value.isPlaying) {
        _wasPlaying = true;
        _controller.pause();
        setState(() {
          _isPlaying = false;
        });
      }
    } else {
      if (_wasPlaying && !_controller.value.isPlaying) {
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black45,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12.w),
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50.h,
              ),
            ),
        ],
      ),
    ),
    );
  }
}
