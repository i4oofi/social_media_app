import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/reels/cubit/reels_cubit.dart';
import 'package:social_media_app/features/reels/cubit/reels_state.dart';
import 'package:social_media_app/features/reels/widgets/reel_info_overlay.dart';
import 'package:social_media_app/features/reels/widgets/reel_interaction_sidebar.dart';
import 'package:social_media_app/features/reels/widgets/reel_video_player.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReelsView();
  }
}

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Page transition fade
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Make status bar icons white on the black Reels screen
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
    ));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, int reelsLength, bool hasReachedMax) {
    // Animate UI elements on page change
    _fadeController.forward(from: 0);
    setState(() => _currentPage = index);

    // Paginate
    if (index == reelsLength - 1 && !hasReachedMax) {
      context.read<ReelsCubit>().fetchReels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: BlocBuilder<ReelsCubit, ReelsState>(
        builder: (context, state) {
          // ── Loading ────────────────────────────────────────────────
          if (state is ReelsLoading) {
            return _buildLoadingState();
          }

          // ── Error ──────────────────────────────────────────────────
          if (state is ReelsError) {
            return _buildErrorState(state.message);
          }

          // ── Loaded ─────────────────────────────────────────────────
          if (state is ReelsLoaded) {
            if (state.reels.isEmpty) return _buildEmptyState();

            return Stack(
              children: [
                // Main PageView
                RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  onRefresh: () async {
                    _pageController.jumpToPage(0);
                    await context
                        .read<ReelsCubit>()
                        .fetchReels(refresh: true);
                  },
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemCount:
                        state.reels.length + (state.hasReachedMax ? 0 : 1),
                    onPageChanged: (index) => _onPageChanged(
                      index,
                      state.reels.length,
                      state.hasReachedMax,
                    ),
                    itemBuilder: (context, index) {
                      // Loading more indicator
                      if (index >= state.reels.length) {
                        return _buildPaginationLoader();
                      }

                      final reel = state.reels[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // ── Video ──────────────────────────────────
                          if (reel.video != null)
                            ReelVideoPlayer(videoUrl: reel.video!)
                          else
                            _buildNoVideoPlaceholder(),

                          // ── Bottom gradient + info ─────────────────
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 240.h,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: ReelInfoOverlay(reel: reel),
                            ),
                          ),

                          // ── Interaction sidebar ────────────────────
                          Positioned(
                            bottom: 90.h,
                            right: 10.w,
                            child: FadeTransition(
                              opacity: _fadeAnim,
                              child: ReelInteractionSidebar(reel: reel),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // ── Page indicator dots (right edge) ──────────────────
                if (state.reels.length > 1)
                  Positioned(
                    right: 6.w,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ReelPageDots(
                        count: state.reels.length.clamp(1, 8),
                        current: _currentPage.clamp(
                            0, state.reels.length.clamp(1, 8) - 1),
                      ),
                    ),
                  ),

                // ── Reels wordmark / top label ─────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _ReelsTopBar(),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 42.w,
              height: 42.w,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading Reels…',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: Colors.white54,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(color: Colors.white38, fontSize: 13.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            GestureDetector(
              onTap: () =>
                  context.read<ReelsCubit>().fetchReels(refresh: true),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black54,
      onRefresh: () =>
          context.read<ReelsCubit>().fetchReels(refresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  color: Colors.white24,
                  size: 56.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Reels yet',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pull down to refresh',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoVideoPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Colors.white24,
          size: 64.sp,
        ),
      ),
    );
  }

  Widget _buildPaginationLoader() {
    return Container(
      color: Colors.black,
      child: Center(
        child: CircularProgressIndicator(
          color: Colors.white54,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ── Top bar ────────────────────────────────────────────────────────────────────

class _ReelsTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.55),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        left: 18.w,
        right: 18.w,
        bottom: 18.h,
      ),
      child: Row(
        children: [
          Text(
            'Reels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xff007AFF),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page indicator dots ────────────────────────────────────────────────────────

class _ReelPageDots extends StatelessWidget {
  final int count;
  final int current;

  const _ReelPageDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: 3.w,
          height: isActive ? 18.h : 5.h,
          margin: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}
