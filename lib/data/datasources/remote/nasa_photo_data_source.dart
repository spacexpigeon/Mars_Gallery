import 'package:parcelviewer/core/nasa_api_client.dart';

abstract class NasaPhotoDataSource {
  Future<List<Map<String, dynamic>>> fetchMarsPhotos({
    String? keywords,
    int page = 1,
    int pageSize = 100,
  });
}

class NasaPhotoDataSourceImpl implements NasaPhotoDataSource {
  final MarsApiClient apiClient;

  NasaPhotoDataSourceImpl(this.apiClient);

  @override
  Future<List<Map<String, dynamic>>> fetchMarsPhotos({
    String? keywords,
    int page = 1,
    int pageSize = 100,
  }) async {
    return await apiClient.fetchImages();
  }
}

