import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Prefetcher {
  final CacheManager cache;
  final _queue = <String>[];
  bool _running = false;

  Prefetcher(this.cache);

  void schedule(List<String> urls) {

    for (final u in urls) {
      if (!_queue.contains(u)) _queue.add(u);
    }
    _drain();
  }

  void clear() => _queue.clear();

  Future<void> _drain() async {
    if (_running) return;
    _running = true;
    try {
      while (_queue.isNotEmpty) {
        final url = _queue.removeAt(0);

        await cache.getSingleFile(url);

        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    } finally {
      _running = false;
    }
  }

  Future<void> precacheToMemory(BuildContext context, List<String> urls) async {
    for (final url in urls) {
      final provider = CachedNetworkImageProvider(url, cacheManager: cache);
      try {
        await precacheImage(provider, context);
      } catch (_) {

      }
    }
  }
}