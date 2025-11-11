import '../entities/photo.dart';

abstract class PhotoRepository {
  Future<List<Photo>> fetchPhotos({
    String? keywords,
    required int page,
    int pageSize = 100,
  });

  Future<void> clearCache();
}

