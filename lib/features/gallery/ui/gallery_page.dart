import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:parcelviewer/core/cache.dart';
import 'package:parcelviewer/features/gallery/logic/gallery_controller.dart';
import 'package:parcelviewer/features/gallery/logic/prefetcher.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  late final PageController _pageController;
  late final CacheManager _cache;
  late final Prefetcher _prefetcher;
  final int prefetchWindow = 10; // ile obrazów do przodu prefetchować

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _cache = MarsCache.build();
    _prefetcher = Prefetcher(_cache);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryController>().loadInitial();
    });

    _pageController.addListener(_onScroll);
  }

  void _onScroll() {
    final controller = context.read<GalleryController>();
    final current = _pageController.page?.round() ?? 0;

    // 1) dociągnij kolejną stronę, jeśli zbliżamy się do końca
    controller.loadMoreIfNeeded(current, threshold: 2);

    // 2) prefetch następnych N obrazów
    final items = controller.items;
    if (items.isEmpty) return;
    final start = current + 1;
    final end = (current + prefetchWindow).clamp(0, items.length - 1);
    final urls = <String>[];
    for (int i = start; i <= end; i++) {
      urls.add(items[i].url);
    }
    _prefetcher.schedule(urls);
    // Opcjonalnie (droższe): precache do pamięci/GPU:
    // _prefetcher.precacheToMemory(context, urls);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GalleryController>();
    final items = controller.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mars – przegląd zdjęć'),
      ),
      body: items.isEmpty && controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              itemCount: items.length + (controller.isEnd ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  // loader-strona „na końcu” gdy doładowujemy
                  return const Center(child: CircularProgressIndicator());
                }
                final photo = items[index];
                return InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: photo.url,
                    cacheManager: _cache,
                    fit: BoxFit.cover,
                    placeholder: (c, _) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, _, __) => const Center(child: Icon(Icons.error)),
                  ),
                );
              },
            ),
    );
  }
}
