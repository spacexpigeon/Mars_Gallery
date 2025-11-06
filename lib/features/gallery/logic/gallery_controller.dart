import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';

class GalleryController extends ChangeNotifier {
  GalleryController({required this.repo, this.pageSize = 25});

  final PhotoRepository repo;
  final int pageSize;

  bool _loading = false;          // trwa jakiekolwiek pobieranie
  bool get loading => _loading;

  String? _errorMessage;          // ostatni komunikat błędu
  String? get errorMessage => _errorMessage;

  final List<String> _items = []; // URL-e zdjęć
  List<String> get photos => List.unmodifiable(_items);

  int _page = 1;                  // numer strony NASA (zaczyna się od 1)
  bool _end = false;              // brak kolejnych stron
  bool _scheduled = false;        // strażnik przed wielokrotnym _loadNext

  /// Inicjalne ładowanie – czyści stan i pobiera pierwszą stronę.
  Future<void> loadInit() async {
    if (_loading) return;
    _items.clear();
    _page = 1;
    _end = false;
    _errorMessage = null;
    notifyListeners(); 
    await _loadNext();
  }

 
  Future<void> loadMoreIfNeeded(int lastVisibleIndex, {int threshold = 6}) async {
    if (_loading || _end) return;

    if (_items.length - lastVisibleIndex <= threshold) {
      await _loadNext();
    }
  }


  Future<void> refresh() => loadInit();



  Future<void> _loadNext() async {

    if (_scheduled) return;
    _scheduled = true;

    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final next = await repo.fetchPage(_page);

      if (next.isEmpty) {
        _end = true;
      } else {
        _items.addAll(next);
        _page++; 
      }
    } catch (e, st) {

      _errorMessage = e.toString();
      debugPrint('Gallery load error: $e\n$st');
    } finally {
      _loading = false;
      _scheduled = false;
      notifyListeners();
    }
  }
}
