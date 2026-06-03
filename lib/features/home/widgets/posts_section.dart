import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/core/theme/app_colors.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/widgets/comments_sheet.dart';

class PostsSection extends StatelessWidget {
  const PostsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: cubit,
      buildWhen: (previous, current) =>
          current is PostLoading ||
          current is PostLoaded ||
          current is PostError,
      builder: (context, state) {
        if (state is PostLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (state is PostLoaded) {
          return ListView.builder(
            itemCount: state.posts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return PostCard(post: state.posts[index]);
            },
          );
        } else if (state is PostError) {
          return Center(child: Text(state.error));
        }
        return const Center(child: Text('No Posts'));
      },
    );
  }
}

