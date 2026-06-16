import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/services/post_services.dart';
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

class _ReelsViewState extends State<ReelsView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ReelsCubit, ReelsState>(
        builder: (context, state) {
          if (state is ReelsLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (state is ReelsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white54, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ReelsCubit>().fetchReels(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ReelsLoaded) {
            if (state.reels.isEmpty) {
              return RefreshIndicator(
                onRefresh: () => context.read<ReelsCubit>().fetchReels(refresh: true),
                child: const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 400,
                    child: Center(
                      child: Text(
                        'No Reels yet',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black54,
              onRefresh: () async {
                _pageController.jumpToPage(0);
                await context.read<ReelsCubit>().fetchReels(refresh: true);
              },
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: state.reels.length + (state.hasReachedMax ? 0 : 1),
                onPageChanged: (index) {
                  if (index == state.reels.length - 1 && !state.hasReachedMax) {
                    context.read<ReelsCubit>().fetchReels();
                  }
                },
                itemBuilder: (context, index) {
                  if (index >= state.reels.length) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  final reel = state.reels[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (reel.video != null)
                        ReelVideoPlayer(videoUrl: reel.video!)
                      else
                        const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                        ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 180,
                        child: ReelInfoOverlay(reel: reel),
                      ),
                      Positioned(
                        bottom: 80,
                        right: 10,
                        child: ReelInteractionSidebar(reel: reel),
                      ),
                    ],
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
