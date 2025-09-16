// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttertest/features/posts/models/post.dart';
import 'package:fluttertest/features/posts/providers/posts_providers.dart';
import 'package:fluttertest/features/posts/services/posts_service.dart';
import 'package:fluttertest/features/posts/views/posts_page.dart';

void main() {
  testWidgets('App renders posts page', (WidgetTester tester) async {
    final fakeService = _FakePostsService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postsServiceProvider.overrideWithValue(fakeService),
        ],
        child: const MaterialApp(
          home: PostsPage(),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Latest Posts'), findsOneWidget);

    // Let async init (loadPosts) complete
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(ListView), findsOneWidget);
  });
}

class _FakePostsService implements PostsService {
  @override
  Future<List<Post>> fetchPosts() async {
    return const [
      Post(userId: 1, id: 1, title: 'Test Title', body: 'Test Body'),
    ];
  }
}
