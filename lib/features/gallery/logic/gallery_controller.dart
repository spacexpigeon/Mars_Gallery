import 'package:flutter/foundation.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';

class GalleryController extends ChangeNotifier {
  GalleryController({required this.repo, this.pageSize = 25});

  final PhotoRepository repo;
  final int pageSize; // dla spójności na przyszłość (NASA i tak używa 'page')

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<String> _items = [];
  List<String> get photos => List.unmodifiable(_items);

  int _page = 1;
  bool _end = false;

  Future<void> loadInit() async {
    _items.clear();
    _page = 1;
    _end = false;
    await _loadNext();
  }

  Future<void> loadMoreIfNeeded(int lastVisibleIndex, {int threshold = 6}) async {
    if (_loading || _end) return;
    if (_items.length - lastVisibleIndex <= threshold) {
      await _loadNext();
    }
  }

      Future<void> _loadNext() async {
      _loading = true;
      _errorMessage = null;
      notifyListeners(); // teraz jest bezpieczne (nie w trakcie buildu)
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
        notifyListeners();
      } 
  }
}