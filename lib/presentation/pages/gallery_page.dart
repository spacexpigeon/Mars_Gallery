import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/gallery_viewmodel.dart';
import '../widgets/photo_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../theme/app_theme.dart';
import 'photo_detail_page.dart';

class GalleryPage extends ConsumerStatefulWidget {
  const GalleryPage({super.key});

  @override
  ConsumerState<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends ConsumerState<GalleryPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(galleryViewModelProvider.notifier).loadInitialPhotos();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(galleryViewModelProvider.notifier).loadMorePhotos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryViewModelProvider);
    final viewModel = ref.read(galleryViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Mars Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () => viewModel.refresh(),
            tooltip: 'Odśwież',
          ),
        ],
      ),
      body: _buildBody(state, viewModel),
    );
  }

  Widget _buildBody(GalleryState state, GalleryViewModel viewModel) {
    if (state.isLoading && state.photos.isEmpty) {
      return const LoadingIndicator(message: 'Ładowanie zdjęć...');
    }

    if (state.errorMessage != null && state.photos.isEmpty) {
      return ErrorDisplay(
        message: state.errorMessage!,
        onRetry: () => viewModel.loadInitialPhotos(),
      );
    }

    if (state.photos.isEmpty) {
      return const Center(
        child: Text(
          'Brak zdjęć',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.refresh(),
      color: AppTheme.highlightColor,
      backgroundColor: AppTheme.surfaceColor,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == state.photos.length) {
                    // Loading indicator at the bottom
                    if (state.isLoadingMore) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: LoadingIndicator(message: 'Ładowanie więcej...'),
                      );
                    }
                    if (state.hasReachedEnd) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'Koniec zdjęć',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }

                  final photo = state.photos[index];
                  return PhotoCard(
                    photo: photo,
                    index: index,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhotoDetailPage(
                            photos: state.photos,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: state.photos.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

