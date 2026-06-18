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

class _ReelVideoPlayerState extends State<ReelVideoPlayer>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = true;
  bool _isInitialized = false;
  bool _wasPlaying = true;

  // Play/pause icon overlay
  late final AnimationController _iconController;
  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _iconOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 40),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_iconController);
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.1)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 60),
    ]).animate(_iconController);

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _iconController.dispose();
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
    _iconController.forward(from: 0);
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || !_isInitialized) return;
    if (info.visibleFraction <= 0.05) {
      if (_controller.value.isPlaying) {
        _wasPlaying = true;
        _controller.pause();
        if (mounted) setState(() => _isPlaying = false);
      }
    } else {
      if (_wasPlaying && !_controller.value.isPlaying) {
        _controller.play();
        if (mounted) setState(() => _isPlaying = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel_${widget.videoUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── Video ────────────────────────────────────────────────
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
              Container(
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white.withValues(alpha: 0.7),
                    strokeWidth: 2.5,
                  ),
                ),
              ),

            // ── Play/Pause animated overlay ──────────────────────────
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) => Opacity(
                opacity: _iconOpacity.value,
                child: Transform.scale(
                  scale: _iconScale.value,
                  child: child,
                ),
              ),
              child: Container(
                width: 68.w,
                height: 68.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
            ),

            // Persistent pause icon (when paused and overlay faded)
            if (!_isPlaying)
              Align(
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _iconController,
                  builder: (context, child) {
                    // Only show after the animated overlay fades out
                    final show = _iconController.status ==
                            AnimationStatus.completed ||
                        _iconController.status == AnimationStatus.dismissed;
                    return Opacity(
                      opacity: show && !_isPlaying ? 1.0 : 0.0,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),
                ),
              ),

            // ── Progress bar ─────────────────────────────────────────
            if (_isInitialized)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  padding: EdgeInsets.zero,
                  colors: VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white.withValues(alpha: 0.35),
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
