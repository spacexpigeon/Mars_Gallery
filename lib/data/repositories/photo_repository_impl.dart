import '../../domain/entities/photo.dart';
import '../../domain/repositories/photo_repository.dart';
import '../datasources/remote/nasa_photo_data_source.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final NasaPhotoDataSource dataSource;
  final CacheManager? cacheManager;

  PhotoRepositoryImpl({
    required this.dataSource,
    this.cacheManager,
  });

  @override
  Future<List<Photo>> fetchPhotos({
    String? keywords,
    required int page,
    int pageSize = 100,
  }) async {
    try {
      final data = await dataSource.fetchMarsPhotos(
        keywords: keywords,
        page: page,
        pageSize: pageSize,
      );

      return data.map((json) => Photo.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> clearCache() async {
    await cacheManager?.emptyCache();
  }
}

