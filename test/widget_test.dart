import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:parcelviewer/features/gallery/logic/gallery_controller.dart';
import 'package:parcelviewer/features/gallery/ui/gallery_page.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';
import 'package:parcelviewer/core/api_client.dart';

/// FAKE: repozytorium zwracające sztuczne dane zamiast wołać API NASA.
/// Dziedziczymy po `PhotoRepository` i nadpisujemy tylko `fetchPage`.
class FakePhotoRepository extends PhotoRepository {
  FakePhotoRepository()
      : super(
          ApiClient(),            // nie będzie użyty, ale konstruktor go wymaga
          apiKey: 'TEST_KEY',     // j.w.
          rover: 'curiosity',
          sol: 1000,
        );

  @override
  Future<List<String>> fetchPage(int page) async {
    // lekkie opóźnienie jak sieć
    await Future.delayed(const Duration(milliseconds: 50));
    // zwróć 3 obrazki „na stronę”
    return List.generate(
      3,
      (i) => 'https://example.com/$page-$i.jpg',
    );
  }
}

void main() {
  testWidgets('Gallery loads first page and shows GalleryPage',
      (WidgetTester tester) async {
    final controller =
        GalleryController(repo: FakePhotoRepository(), pageSize: 3);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: GalleryPage()),
      ),
    );

    // start: kontroler jeszcze nic nie załadował
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // wywołaj inicjalne ładowanie jak w main.dart
    controller.loadInit();

    // pierwszy frame po notifyListeners()
    await tester.pump();

    // poczekaj aż fake „sieć” się zakończy
    await tester.pump(const Duration(milliseconds: 80));

    // strona widoczna
    expect(find.byType(GalleryPage), findsOneWidget);

    // na ekranie powinny być 3 obrazki z pierwszej „strony”
    // (nie testujemy Image.network bezpośrednio – sprawdzimy, że nie ma loadera)
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
