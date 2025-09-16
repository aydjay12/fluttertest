import 'package:dio/dio.dart';
import '../models/post.dart';

abstract class PostsService {
  Future<List<Post>> fetchPosts();
}

class JsonPlaceholderPostsService implements PostsService {
  JsonPlaceholderPostsService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                sendTimeout: const Duration(seconds: 8),
                responseType: ResponseType.json,
                contentType: 'application/json; charset=utf-8',
                headers: const {
                  'Accept': 'application/json',
                },
              ),
            );

  final Dio _dio;
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  @override
  Future<List<Post>> fetchPosts() async {
    try {
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        final data = response.data as List<dynamic>;
        return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Unexpected status code: ${response.statusCode}');
    } on DioException catch (e) {
      final message = e.response?.statusMessage ?? e.message ?? 'Network error';
      throw Exception(message);
    } catch (e) {
      rethrow;
    }
  }
}


