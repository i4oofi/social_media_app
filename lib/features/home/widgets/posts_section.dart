import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/core/shared/widgets/post_card.dart';
import 'package:social_media_app/features/home/cubit/home_cubit.dart';
import 'package:social_media_app/features/home/models/post_model.dart';

class PostsSection extends StatefulWidget {
  const PostsSection({super.key});

  @override
  State<PostsSection> createState() => _PostsSectionState();
}

class _PostsSectionState extends State<PostsSection> {
  List<PostModel> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is PostLoading) {
          setState(() {
            _isLoading = true;
            _error = null;
          });
        } else if (state is PostLoaded) {
          setState(() {
            _posts = state.posts;
            _isLoading = false;
          });
        } else if (state is PostError) {
          setState(() {
            _isLoading = false;
            _error = state.error;
          });
        }
      },
      child: _isLoading && _posts.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          : _error != null && _posts.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _posts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('No Posts')),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        return PostCard(post: _posts[index]);
                      },
                    ),
    );
  }
}
