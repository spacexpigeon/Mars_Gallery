import 'package:parcelviewer/core/nasa_api_client.dart';

/// Data source do pobierania zdjęć z NASA Images API
abstract class NasaPhotoDataSource {
  Future<List<Map<String, dynamic>>> fetchMarsPhotos({
    String? keywords,
    int page = 1,
    int pageSize = 100,
  });
}

class NasaPhotoDataSourceImpl implements NasaPhotoDataSource {
  final NasaApiClient apiClient;

  NasaPhotoDataSourceImpl(this.apiClient);

  @override
  Future<List<Map<String, dynamic>>> fetchMarsPhotos({
    String? keywords,
    int page = 1,
    int pageSize = 100,
  }) async {
    return await apiClient.fetchImages(
      keywords: keywords ?? 'curiosity mastcam',
      mediaType: 'image',
      page: page,
      pageSize: pageSize,
    );
  }
}

