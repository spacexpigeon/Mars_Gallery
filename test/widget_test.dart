import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parcelviewer/presentation/pages/gallery_page.dart';

void main() {
  testWidgets('Gallery page loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GalleryPage(),
        ),
      ),
    );

    // Wait for initial load
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify that the app bar is present
    expect(find.text('Mars Gallery'), findsOneWidget);
  });
}
