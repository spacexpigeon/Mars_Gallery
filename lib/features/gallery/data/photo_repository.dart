import 'package:parcelviewer/core/api_client.dart';

class PhotoRepository {
  PhotoRepository(
    this.api, {
    required this.apiKey,
    this.rover = 'curiosity',
    this.sol = 1000,       // możesz zamiast tego ustawić earthDate
    this.earthDate,        // np. '2015-05-30'
  });

  final ApiClient api;
  final String apiKey;

  final String rover;
  final int? sol;
  final String? earthDate;

  Future<List<String>> fetchPage(int page) async {
    final photos = await api.getMarsPhotos(
      rover: rover,
      sol: sol,
      earthDate: earthDate,
      page: page,
      apiKey: apiKey,
    );

    // NASA czasem zwraca http – wymuś https, żeby Android nie blokował
    return photos
        .map((e) => (e['img_src'] as String).replaceFirst('http://', 'https://'))
        .toList();
  }
}
