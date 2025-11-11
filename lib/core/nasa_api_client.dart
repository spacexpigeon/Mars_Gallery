import 'dart:convert';
import 'package:dio/dio.dart';

/// Client do komunikacji z NASA Images API
/// Dokumentacja: https://images.nasa.gov/docs/images/api/api.html
class NasaApiClient {
  static const String _baseUrl = 'https://images-api.nasa.gov';
  
  late final Dio _dio;

  NasaApiClient() {
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
          print('🌍 NASA Images API Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          final count = _getImageCount(response.data);
          print('✅ NASA Images API Response: ${response.statusCode} - $count images');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ NASA Images API Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  int _getImageCount(dynamic data) {
    try {
      if (data is Map && data['collection'] != null) {
        final items = data['collection']['items'] as List?;
        return items?.length ?? 0;
      }
    } catch (e) {
      // Ignore
    }
    return 0;
  }

  /// Pobiera zdjęcia z NASA Images API
  /// 
  /// [keywords] - słowa kluczowe do wyszukiwania (np. 'curiosity mastcam')
  /// [mediaType] - typ mediów ('image', 'video', 'audio')
  /// [page] - numer strony (domyślnie 1)
  /// [pageSize] - liczba wyników na stronę (domyślnie 100)
  /// 
  /// Zwraca listę zdjęć jako Map
  Future<List<Map<String, dynamic>>> fetchImages({
    String keywords = 'curiosity mastcam',
    String mediaType = 'image',
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'keywords': keywords,
        'media_type': mediaType,
        'page': page,
        'page_size': pageSize,
      };

      final response = await _dio.get(
        '/search',
        queryParameters: queryParams,
      );

      // Sprawdź status code
      if (response.statusCode == null) {
        throw Exception('Brak odpowiedzi z serwera');
      }

      if (response.statusCode! >= 400) {
        throw Exception('NASA Images API Error ${response.statusCode}: ${response.statusMessage ?? ''}');
      }

      // Parsowanie odpowiedzi
      final data = response.data;
      if (data == null) {
        return [];
      }

      Map<String, dynamic> jsonData;
      if (data is String) {
        try {
          jsonData = jsonDecode(data) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Nie można sparsować odpowiedzi: $e');
        }
      } else if (data is Map<String, dynamic>) {
        jsonData = data;
      } else {
        throw Exception('Nieoczekiwany format odpowiedzi z API');
      }

      return _extractImages(jsonData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Błąd podczas pobierania zdjęć: $e');
    }
  }

  /// Wyciąga listę zdjęć z odpowiedzi API
  List<Map<String, dynamic>> _extractImages(Map<String, dynamic> data) {
    try {
      if (data.containsKey('collection') && data['collection'] is Map) {
        final collection = data['collection'] as Map<String, dynamic>;
        if (collection.containsKey('items') && collection['items'] is List) {
          final items = collection['items'] as List;
          
          return items.map((item) {
            if (item is Map<String, dynamic>) {
              return _parseImageItem(item);
            }
            return <String, dynamic>{};
          }).where((img) => img.isNotEmpty).toList();
        }
      }
      return [];
    } catch (e) {
      print('Błąd podczas parsowania obrazów: $e');
      return [];
    }
  }

  /// Parsuje pojedynczy item z odpowiedzi API
  Map<String, dynamic> _parseImageItem(Map<String, dynamic> item) {
    try {
      // Pobierz dane
      final dataList = item['data'] as List?;
      if (dataList == null || dataList.isEmpty) {
        return {};
      }
      
      final imageData = dataList[0] as Map<String, dynamic>;
      
      // Pobierz linki - używamy mniejszych rozmiarów dla szybkiego ładowania
      final linksList = item['links'] as List?;
      String? imageUrl;
      
      if (linksList != null) {
        // Priorytet: medium > small > thumb > alternate > canonical (największy, najwolniejszy)
        String? mediumUrl;
        String? smallUrl;
        String? thumbUrl;
        String? alternateUrl;
        String? canonicalUrl;
        
        for (final link in linksList) {
          if (link is Map<String, dynamic>) {
            final rel = link['rel'] as String?;
            final render = link['render'] as String?;
            final href = link['href'] as String?;
            
            if (href != null && render == 'image') {
              final hrefLower = href.toLowerCase();
              
              // Zbierz różne rozmiary na podstawie nazwy pliku i rel
              if (rel == 'canonical' || hrefLower.contains('~orig') || hrefLower.contains('orig.')) {
                canonicalUrl = href; // Największy - używamy tylko jako ostatnia opcja
              } else if (hrefLower.contains('~medium') || hrefLower.contains('medium.')) {
                mediumUrl = href; // Optymalny - ~200KB
              } else if (hrefLower.contains('~small') || hrefLower.contains('small.')) {
                smallUrl = href; // Mały - ~50KB
              } else if (rel == 'preview' || hrefLower.contains('~thumb') || hrefLower.contains('thumb.')) {
                thumbUrl = href; // Miniaturka - ~30KB
              } else if (rel == 'alternate') {
                alternateUrl = href;
              }
            }
          }
        }
        
        // Wybierz najlepszy dostępny rozmiar (medium jest optymalny - szybki i dobrej jakości)
        // medium ~200KB vs canonical ~15MB - 75x szybciej!
        imageUrl = mediumUrl ?? smallUrl ?? alternateUrl ?? thumbUrl ?? canonicalUrl;
      }
      
      if (imageUrl == null) {
        return {};
      }

      // Zbuduj obiekt zdjęcia w formacie kompatybilnym z Photo entity
      return {
        'id': imageData['nasa_id'] as String? ?? imageData['title'] as String? ?? '',
        'img_src': imageUrl,
        'title': imageData['title'] as String?,
        'description': imageData['description'] as String?,
        'date_created': imageData['date_created'] as String?,
        'camera': {
          'full_name': _extractCameraName(imageData),
        },
        'rover': {
          'name': _extractRoverName(imageData),
        },
        'earth_date': _extractDate(imageData['date_created'] as String?),
      };
    } catch (e) {
      print('Błąd podczas parsowania item: $e');
      return {};
    }
  }

  String? _extractCameraName(Map<String, dynamic> data) {
    final keywords = data['keywords'] as List?;
    if (keywords != null) {
      for (final keyword in keywords) {
        final kw = keyword.toString().toLowerCase();
        if (kw.contains('mastcam')) return 'Mast Camera (Mastcam)';
        if (kw.contains('navcam')) return 'Navigation Camera (Navcam)';
        if (kw.contains('mahli')) return 'Mars Hand Lens Imager (MAHLI)';
        if (kw.contains('mardi')) return 'Mars Descent Imager (MARDI)';
      }
    }
    return null;
  }

  String? _extractRoverName(Map<String, dynamic> data) {
    final keywords = data['keywords'] as List?;
    if (keywords != null) {
      for (final keyword in keywords) {
        final kw = keyword.toString().toLowerCase();
        if (kw.contains('curiosity')) return 'Curiosity';
        if (kw.contains('opportunity')) return 'Opportunity';
        if (kw.contains('spirit')) return 'Spirit';
        if (kw.contains('perseverance')) return 'Perseverance';
      }
    }
    return null;
  }

  String? _extractDate(String? dateCreated) {
    if (dateCreated == null) return null;
    try {
      // Format: "2017-01-17T21:21:03Z" -> "2017-01-17"
      final dateTime = DateTime.parse(dateCreated);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return null;
    }
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
          'NASA Images API Error ${error.response?.statusCode}: ${error.response?.statusMessage ?? ''}',
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
