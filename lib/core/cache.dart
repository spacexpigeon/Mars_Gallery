import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MarsCache {
  static const key = 'marsImagesCache';

  static CacheManager build() {
    return CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 30), // 30 dni
        maxNrOfCacheObjects: 1000, // Więcej obiektów w cache
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
  }
}