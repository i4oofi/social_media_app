import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:social_media_app/core/services/core_auth_services.dart';
import 'package:social_media_app/core/services/home_services.dart';
import 'package:social_media_app/features/home/models/post_model.dart';
import 'package:social_media_app/features/home/models/story_model.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  final homeServices = HomeServices();
  final coreAuthServices = CoreAuthServices();
  Future<void> fetchStories() async {
    try {
      emit(StoryLoading());
      final rawStories = await homeServices.fetchStories();
      List<StoryModel> stories = [];
      for (var story in rawStories) {
        final userData = await coreAuthServices.getUserData(story.authorId);
        if (userData != null) {
          story = story.copyWith(authorName: userData.name);
        }
        stories.add(story);
      }

      emit(StoryLoaded(stories: stories));
    } catch (e) {
      emit(StoryError(error: e.toString()));
    }
  }
  Future<void> fetchPosts() async {
    try {
      emit(PostLoading());
      final rawPosts = await homeServices.fetchPosts();
      List<PostModel> posts = [];
      for (var post in rawPosts) {
        final userData = await coreAuthServices.getUserData(post.authorId);
        if (userData != null) {
          post = post.copyWith(authorName: userData.name , authorProfileImage: userData.imageUrl);
        }
        posts.add(post);
      }

      emit(PostLoaded(posts: posts));
    } catch (e) {
      emit(PostError(error: e.toString()));
    }
  }
}
