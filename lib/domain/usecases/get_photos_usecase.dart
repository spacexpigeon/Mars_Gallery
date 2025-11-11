import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

class GetPhotosUseCase {
  final PhotoRepository repository;

  GetPhotosUseCase(this.repository);

  Future<List<Photo>> call({
    String? keywords,
    required int page,
    int pageSize = 100,
  }) async {
    return await repository.fetchPhotos(
      keywords: keywords,
      page: page,
      pageSize: pageSize,
    );
  }
}

