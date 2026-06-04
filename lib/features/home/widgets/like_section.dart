import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/cubit/posts_cubit/posts_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class LikeSection extends StatelessWidget {
  final PostModel post;
  const LikeSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final postsCubit = context.read<PostsCubit>();
    return BlocBuilder<PostsCubit, PostsState>(
      bloc: postsCubit,
      buildWhen: (previous, current) {
        return current is FetchingLikersDetails ||
            current is LikersDetailsFetched ||
            current is FetchingLikersDetailsError;
      },
      builder: (context, state) {
        if (state is FetchingLikersDetails) {
          return Center(child: CircularProgressIndicator());
        } else if (state is LikersDetailsFetched) {
          final likes = state.likersDetails;
          if (likes.isEmpty) {
            return const Center(child: Text('No likes'));
          }
          return Row(
            children: [
              ...likes.map(
                (like) => CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(like.imageUrl ?? ''),
                ),
              ),
              const SizedBox(width: 8),
              Text('${likes.length} likes'),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
