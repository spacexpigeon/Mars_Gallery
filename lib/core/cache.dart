import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MarsCache {
  static const key = 'marsImagesCache';

  static CacheManager build() {
    return CacheManager(
      Config(
        key,
        stalePeriod: const Duration(days: 14), // 2 tygodnie
        maxNrOfCacheObjects: 500,             
        repo: JsonCacheInfoRepository(databaseName: key),
        fileService: HttpFileService(),
      ),
    );
  }
}