import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String baseUrl = 'https://example.com/api'})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ));

  Future<List<Map<String, dynamic>>> getPhotos({required int page, required int pageSize}) async {
    final res = await _dio.get('/photos', queryParameters: {
      'page': page,
      'pageSize': pageSize,
    });
    final data = res.data as List;
    return data.cast<Map<String, dynamic>>();
  }
}
