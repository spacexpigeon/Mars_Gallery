import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parcelviewer/features/gallery/logic/gallery_controller.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  @override
  void initState() {
    super.initState();
    // Uruchom pierwsze ładowanie PO zbudowaniu pierwszej klatki
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<GalleryController>().loadInit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<GalleryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mars – przegląd zdjęć')),
      body: RefreshIndicator(
        onRefresh: () => context.read<GalleryController>().loadInit(),
        child: ListView.builder(
          itemCount: c.photos.length + 1,
          itemBuilder: (ctx, i) {
            // Ostatni „sentinel” – doładowanie następnej strony
            if (i == c.photos.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<GalleryController>().loadMoreIfNeeded(i);
                }
              });
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: c.loading
                      ? const CircularProgressIndicator()
                      : c.errorMessage != null
                          ? Text(c.errorMessage!)
                          : const SizedBox.shrink(),
                ),
              );
            }

            final url = c.photos[i];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder: (ctx, child, prog) =>
                      prog == null ? child : const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                  errorBuilder: (_, __, ___) =>
                      const SizedBox(height: 200, child: Center(child: Text('Nie udało się załadować obrazu'))),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
