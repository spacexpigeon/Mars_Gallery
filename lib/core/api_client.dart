import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient({
    String baseUrl = 'https://api.nasa.gov',
  }) : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            validateStatus: (_) => true,
          ),
        );


  Future<List<Map<String, dynamic>>> getMarsPhotos({
    required String rover,
    int? sol,
    String? earthDate, // 'YYYY-MM-DD'
    required int page,
    required String apiKey,
  }) async {
    final path = '/mars-photos/api/v1/rovers/$rover/photos';

    final qp = <String, dynamic>{
      'page': page,
      'api_key': apiKey,
    };

    if (sol != null) {
      qp['sol'] = sol;
    } else if (earthDate != null) {
      qp['earth_date'] = earthDate;
    } else {
      throw ArgumentError('Podaj sol lub earthDate.');
    }

    final res = await dio.get(path, queryParameters: qp);

    if (res.statusCode == 200) {
      final data = res.data;
      final list = (data['photos'] as List).cast<Map<String, dynamic>>();
      return list;
    } else {
      throw Exception('NASA API ${res.statusCode}: ${res.statusMessage ?? 'Nieudane zapytanie'}');
    }
  }
}

//V4CYE5ThmFj4AFAgFMab0WnvCyVKJCS9UuVwyIxg