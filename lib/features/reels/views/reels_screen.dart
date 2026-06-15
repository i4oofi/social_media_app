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
    return BlocProvider(
      create: (context) => ReelsCubit(PostServices())..fetchReels(),
      child: const ReelsView(),
    );
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
          if (state is ReelsLoading && state is! ReelsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReelsError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is ReelsLoaded) {
            if (state.reels.isEmpty) {
              return const Center(
                child: Text(
                  'No Reels available',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: state.reels.length + (state.hasReachedMax ? 0 : 1),
              onPageChanged: (index) {
                if (index == state.reels.length - 1 && !state.hasReachedMax) {
                  context.read<ReelsCubit>().fetchReels();
                }
              },
              itemBuilder: (context, index) {
                if (index >= state.reels.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final reel = state.reels[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (reel.video != null)
                      ReelVideoPlayer(videoUrl: reel.video!)
                    else
                      const Center(
                        child: Text(
                          'Invalid Video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 150,
                      child: ReelInfoOverlay(reel: reel),
                    ),
                    Positioned(
                      bottom: 20,
                      right: 10,
                      child: ReelInteractionSidebar(reel: reel),
                    ),
                  ],
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
