import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/pages/gallery_page.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MarsApp(),
    ),
  );
}

class MarsApp extends StatelessWidget {
  const MarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mars Gallery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const GalleryPage(),
    );
  }
}
