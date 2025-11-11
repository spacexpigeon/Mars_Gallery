import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/photo.dart';
import '../../domain/usecases/get_photos_usecase.dart';
import '../providers/photo_repository_provider.dart';

class GalleryState {
  final List<Photo> photos;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool hasReachedEnd;
  final int currentPage;

  GalleryState({
    this.photos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.hasReachedEnd = false,
    this.currentPage = 1,
  });

  GalleryState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return GalleryState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class GalleryViewModel extends StateNotifier<GalleryState> {
  final GetPhotosUseCase getPhotosUseCase;
  final String keywords;
  final int pageSize;

  GalleryViewModel({
    required this.getPhotosUseCase,
    this.keywords = 'curiosity mastcam',
    this.pageSize = 25,
  }) : super(GalleryState());

  Future<void> loadInitialPhotos() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      photos: [],
      currentPage: 1,
      hasReachedEnd: false,
    );

    try {
      final photos = await getPhotosUseCase(
        keywords: keywords,
        page: 1,
        pageSize: pageSize,
      );

      state = state.copyWith(
        photos: photos,
        isLoading: false,
        currentPage: 2,
        hasReachedEnd: photos.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMorePhotos() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    try {
      final photos = await getPhotosUseCase(
        keywords: keywords,
        page: state.currentPage,
        pageSize: pageSize,
      );

      if (photos.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasReachedEnd: true,
        );
      } else {
        state = state.copyWith(
          photos: [...state.photos, ...photos],
          isLoadingMore: false,
          currentPage: state.currentPage + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadInitialPhotos();
  }
}

final galleryViewModelProvider = StateNotifierProvider<GalleryViewModel, GalleryState>((ref) {
  final repository = ref.watch(photoRepositoryProvider);
  final useCase = GetPhotosUseCase(repository);
  return GalleryViewModel(
    getPhotosUseCase: useCase,
    keywords: 'curiosity mastcam', // Wyszukiwanie zdjęć Curiosity z kamery Mastcam
    pageSize: 25,
  );
});

