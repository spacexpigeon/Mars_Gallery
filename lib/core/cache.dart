import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MarsCache {
  static const key = 'mars_images_v2'; 

  static CacheManager build() {
    return CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 1000,
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
  }
}