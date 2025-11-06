// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:parcelviewer/features/gallery/logic/gallery_controller.dart';
import 'package:parcelviewer/features/gallery/ui/gallery_page.dart';
import 'package:parcelviewer/features/gallery/data/photo.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';
import 'package:parcelviewer/core/api_client.dart';

// Prosty fake repo – nie robi żadnych wywołań sieciowych.
class FakePhotoRepository extends PhotoRepository {
  FakePhotoRepository() : super(ApiClient(baseUrl: 'http://localhost'));

  @override
  Future<List<Photo>> fetchPage(int page, int pageSize) async {
    // Udajemy, że backend zwraca pageSize zdjęć.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return List.generate(pageSize, (i) {
      final id = (page - 1) * pageSize + i;
      // Używamy jakiegokolwiek URL-a; obraz i tak nie będzie ładowany w teście.
      return Photo(id: '$id', url: 'https://example.com/$id.jpg');
    });
  }
}

void main() {
  testWidgets('Gallery loads first page and shows PageView', (WidgetTester tester) async {
    final controller = GalleryController(repo: FakePhotoRepository(), pageSize: 3);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(
          home: GalleryPage(),
        ),
      ),
    );

    // Na starcie powinien być loader.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Poczekaj aż postFrameCallback odpali loadInitial i kontroler pobierze dane.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Strona z galerią powinna się pojawić.
    expect(find.byType(PageView), findsOneWidget);

    // Mamy 3 elementy do przewijania (pageSize z fake’a).
    // Przewińmy na następną stronę, żeby sprawdzić, że PageView reaguje.
    await tester.fling(find.byType(PageView), const Offset(-500, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
  });
}
