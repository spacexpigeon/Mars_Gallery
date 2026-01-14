import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/nasa_api_client.dart';
import '../../core/cache.dart';
import '../../data/datasources/remote/nasa_photo_data_source.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';

/// Provider dla NASA API Client
final nasaApiClientProvider = Provider<MarsApiClient>((ref) {
  return MarsApiClient();
});

/// Provider dla data source
final nasaPhotoDataSourceProvider = Provider<NasaPhotoDataSource>((ref) {
  return NasaPhotoDataSourceImpl(ref.watch(nasaApiClientProvider));
});

/// Provider dla repository
final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepositoryImpl(
    dataSource: ref.watch(nasaPhotoDataSourceProvider),
    cacheManager: MarsCache.build(),
  );
});

