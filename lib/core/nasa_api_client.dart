import 'dart:convert';
import 'package:dio/dio.dart';

/// Client do komunikacji z Mars Photos API (Android Codelab)
/// Base URL: https://android-kotlin-fun-mars-server.appspot.com
class MarsApiClient {
  // Nowy Base URL z kursu Android Kotlin
  static const String _baseUrl = 'https://android-kotlin-fun-mars-server.appspot.com';
  
  late final Dio _dio;

  MarsApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Interceptor do logowania
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌍 Mars Photos API Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final count = (response.data is List) ? (response.data as List).length : 0;
          print('✅ Mars Photos API Response: ${response.statusCode} - $count images');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ Mars Photos API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Pobiera zdjęcia z API Codelaba
  /// 
  /// Zauważ: To API jest prostsze i nie obsługuje paginacji ani wyszukiwania
  /// tak jak poprzednie API NASA. Parametry zostały usunięte.
  Future<List<Map<String, dynamic>>> fetchImages() async {
    try {
      final response = await _dio.get('/photos');

      // Sprawdź status code
      if (response.statusCode == null) {
        throw Exception('Brak odpowiedzi z serwera');
      }

      if (response.statusCode! >= 400) {
        throw Exception('API Error ${response.statusCode}: ${response.statusMessage ?? ''}');
      }

      final data = response.data;
      
      List<dynamic> listData;
      if (data is String) {
        try {
          listData = jsonDecode(data) as List<dynamic>;
        } catch (e) {
          throw Exception('Nie można sparsować odpowiedzi: $e');
        }
      } else if (data is List) {
        listData = data;
      } else {
        return [];
      }

      return _extractImages(listData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Błąd podczas pobierania zdjęć: $e');
    }
  }
// W pliku nasa_api_client.dart

List<Map<String, dynamic>> _extractImages(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return {
          'id': item['id'] as String?,
          
          // 👇 ZMIEŃ TĘ LINIJKĘ - TO NAPRAWI ZDJĘCIA
          'img_src': (item['img_src'] as String?)?.replaceAll('http://', 'https://'), 
          
          'title': 'Mars Photo ${item['id']}',
          'description': 'Zdjęcie pobrane z Android Codelab API',
          'date_created': null,
          'camera': {'full_name': 'Unknown Camera'},
          'rover': {'name': 'Unknown Rover'},
          'earth_date': null,
        };
      }
      return <String, dynamic>{};
    }).where((img) => img['img_src'] != null).toList();
  }
  /// Obsługuje błędy Dio
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Timeout połączenia. Sprawdź połączenie internetowe.');
      case DioExceptionType.badResponse:
        return Exception(
          'API Error ${error.response?.statusCode}: ${error.response?.statusMessage ?? ''}',
        );
      case DioExceptionType.cancel:
        return Exception('Żądanie zostało anulowane.');
      case DioExceptionType.unknown:
      default:
        return Exception(
          'Błąd połączenia: ${error.message ?? "Nieznany błąd"}',
        );
    }
  }
}