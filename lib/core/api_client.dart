import 'dart:convert';
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: 'https://api.nasa.gov',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          responseType: ResponseType.json,
          validateStatus: (_) => true,
        ));

  Future<List<Map<String, dynamic>>> getMarsPhotos({
    required String rover,     // curiosity / perseverance / opportunity / spirit
    int? sol,                  // np. 1000
    String? earthDate,         // np. '2015-06-03'
    required int page,         // >= 1
    required String apiKey,
  }) async {
    if (sol == null && earthDate == null) {
      throw ArgumentError('Podaj sol lub earthDate');
    }

    final uri = Uri.https(
      'api.nasa.gov',
      '/mars-photos/api/v1/rovers/$rover/photos',
      {
        if (sol != null) 'sol': '$sol' else 'earth_date': earthDate!,
        'page': '$page',
        'api_key': apiKey.trim(), 
      },
    );

    final res = await dio.getUri(uri);


    print('NASA URL => $uri | STATUS ${res.statusCode}');

    if (res.statusCode != 200) {
  
      throw Exception('NASA API ${res.statusCode}: ${res.statusMessage ?? ''}  BODY: ${res.data}');
    }

    dynamic body = res.data;
    if (body is String) body = jsonDecode(body);

    final List photos = (body['photos'] as List? ?? []);
    return photos.cast<Map<String, dynamic>>();
  }
}

//V4CYE5ThmFj4AFAgFMab0WnvCyVKJCS9UuVwyIxg