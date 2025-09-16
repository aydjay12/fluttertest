import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/posts_service.dart';

final postsServiceProvider = Provider<PostsService>((ref) {
  return JsonPlaceholderPostsService();
});

class PostsState {
  const PostsState({required this.isLoading, required this.posts, this.errorMessage});

  final bool isLoading;
  final List<Post> posts;
  final String? errorMessage;

  PostsState copyWith({bool? isLoading, List<Post>? posts, String? errorMessage}) {
    return PostsState(
      isLoading: isLoading ?? this.isLoading,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }

  static const initial = PostsState(isLoading: false, posts: [], errorMessage: null);
}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier(this._service) : super(PostsState.initial);

  final PostsService _service;

  Future<void> loadPosts() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final posts = await _service.fetchPosts();
      state = state.copyWith(isLoading: false, posts: posts, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, posts: [], errorMessage: e.toString());
    }
  }

  Future<void> refreshPosts() async {
    try {
      final posts = await _service.fetchPosts();
      state = state.copyWith(posts: posts, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}

final postsNotifierProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  final service = ref.watch(postsServiceProvider);
  return PostsNotifier(service);
});


