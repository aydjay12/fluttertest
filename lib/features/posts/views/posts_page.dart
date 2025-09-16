import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/posts_providers.dart';
import '../models/post.dart';

class PostsPage extends ConsumerStatefulWidget {
  const PostsPage({super.key});

  @override
  ConsumerState<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends ConsumerState<PostsPage> {
  int _currentPage = 0;
  final int _postsPerPage = 10; // Number of posts per page
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsNotifierProvider.notifier).loadPosts();
    });
  }

  void _goToPreviousPage() {
    setState(() {
      _currentPage = (_currentPage - 1).clamp(0, _totalPages - 1);
    });
    _scrollToTop();
  }

  void _goToNextPage() {
    setState(() {
      _currentPage = (_currentPage + 1).clamp(0, _totalPages - 1);
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  int get _totalPages {
    final state = ref.watch(postsNotifierProvider);
    if (state.posts.isEmpty) return 1; // At least one page even if empty
    return (state.posts.length / _postsPerPage).ceil();
  }

  List<Post> get _currentPosts {
    final state = ref.watch(postsNotifierProvider);
    if (state.posts.isEmpty) return [];

    final startIndex = _currentPage * _postsPerPage;
    final endIndex = (startIndex + _postsPerPage).clamp(0, state.posts.length);
    return state.posts.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Posts App'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(postsNotifierProvider.notifier).refreshPosts();
        },
        color: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeThroughTransition(
            animation: animation,
            secondaryAnimation: kAlwaysDismissedAnimation,
            child: child,
          ),
          child: _buildBody(context, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, PostsState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (state.errorMessage != null && state.posts.isEmpty) {
      return _ErrorView(
        key: const ValueKey('error'),
        message: state.errorMessage!,
        onRetry: () {
          ref.read(postsNotifierProvider.notifier).loadPosts();
          _currentPage = 0; // Reset page on retry
        },
      );
    }
    if (state.posts.isEmpty) {
      return _EmptyPostsView(
        key: const ValueKey('empty'),
        onRefresh: () {
          ref.read(postsNotifierProvider.notifier).refreshPosts();
          _currentPage = 0;
        },
      );
    }
    return _PostsListWithPagination(
      key: const ValueKey('posts_list'),
      posts: _currentPosts,
      currentPage: _currentPage,
      totalPages: _totalPages,
      onPreviousPage: _goToPreviousPage,
      onNextPage: _goToNextPage,
      isLoadingMore: state.isLoading, // Indicate loading when refresh is happening
      controller: _scrollController,
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 60, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong.',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load posts: ${message.contains("Exception:") ? message.split("Exception:").last.trim() : message}',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPostsView extends StatelessWidget {
  const _EmptyPostsView({super.key, required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 60, color: theme.colorScheme.primary.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              'No Posts Yet!',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'It seems there are no posts to display at the moment. Pull down to refresh or try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostsListWithPagination extends StatelessWidget {
  const _PostsListWithPagination({
    super.key,
    required this.posts,
    required this.currentPage,
    required this.totalPages,
    required this.onPreviousPage,
    required this.onNextPage,
    this.isLoadingMore = false,
    required this.controller,
  });

  final List<Post> posts;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final bool isLoadingMore;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            reverse: false,
            transitionBuilder: (child, primary, secondary) {
              return SharedAxisTransition(
                animation: primary,
                secondaryAnimation: secondary,
                transitionType: SharedAxisTransitionType.horizontal,
                child: child,
              );
            },
            child: ListView.separated(
              key: ValueKey('page_\${currentPage}'),
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = posts[index];
                return OpenContainer(
                  closedElevation: 0,
                  openElevation: 0,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  transitionDuration: const Duration(milliseconds: 450),
                  closedBuilder: (context, open) => _PostCard(post: p, onTap: open),
                  openBuilder: (context, _) => _PostDetails(post: p),
                );
              },
            ),
          ),
        ),
        if (totalPages > 1) // Only show pagination if there's more than one page
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: currentPage > 0 ? onPreviousPage : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Page ${currentPage + 1} of $totalPages',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: currentPage < totalPages - 1 ? onNextPage : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
                ),
              ],
            ),
          ),
        if (isLoadingMore) // Show a subtle indicator when refreshing
          LinearProgressIndicator(
            color: theme.colorScheme.secondary,
            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
          ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post, required this.onTap});
  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      color: cs.surface,
      elevation: 2, // Subtle shadow for a card effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias, // Ensures content is clipped to rounded corners
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'post_title_${post.id}', // Unique tag for Hero animation
                child: Material(
                  type: MaterialType.transparency, // Essential for Hero text animation
                  child: Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Hero(
                tag: 'post_body_preview_${post.id}', // Unique tag for Hero animation
                child: Material(
                  type: MaterialType.transparency, // Essential for Hero text animation
                  child: Text(
                    // Replace newlines with spaces for preview if desired,
                    // but usually, Text handles them fine by default
                    post.body.replaceAll('\n', ' '), // Or just post.body if newlines are fine in preview
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                      height: 1.4, // Improve line spacing
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostDetails extends StatelessWidget {
  const _PostDetails({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${post.id}'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: SingleChildScrollView( // Make the body scrollable
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'post_title_${post.id}', // Match tag with _PostCard
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  post.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: cs.outlineVariant, thickness: 1),
            const SizedBox(height: 16),
            Hero(
              tag: 'post_body_preview_${post.id}', // Match tag with _PostCard
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  post.body, // Text widget naturally handles \n for new lines
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurface,
                    height: 1.6, // Enhanced line spacing for readability
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}