import 'package:flutter/foundation.dart';
import 'package:parcelviewer/features/gallery/data/photo.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';

class GalleryController extends ChangeNotifier {
  final PhotoRepository repo;
  final int pageSize;
  int _page = 1;
  bool _loading = false;
  bool _end = false;

  final List<Photo> _items = [];

  List<Photo> get items => List.unmodifiable(_items);
  bool get isLoading => _loading;
  bool get isEnd => _end;

  GalleryController({required this.repo, this.pageSize = 10});

  Future<void> loadInitial() async {
    if (_items.isNotEmpty) return;
    await _loadNext();
  }

  Future<void> loadMoreIfNeeded(int visibleIndex, {int threshold = 2}) async {
    // jeżeli użytkownik dotknął 8. element z 10, dociągnij kolejną stronę
    if (_loading || _end) return;
    if (_items.length - visibleIndex <= threshold) {
      await _loadNext();
    }
  }

  Future<void> _loadNext() async {
    _loading = true;
    notifyListeners();
    try {
      final next = await repo.fetchPage(_page, pageSize);
      if (next.isEmpty) {
        _end = true;
      } else {
        _items.addAll(next);
        _page++;
      }
    } catch (e) {
      // możesz dodać tu obsługę błędów
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
