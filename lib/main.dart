import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parcelviewer/core/api_client.dart';
import 'package:parcelviewer/features/gallery/data/photo_repository.dart';
import 'package:parcelviewer/features/gallery/logic/gallery_controller.dart';
import 'package:parcelviewer/features/gallery/ui/gallery_page.dart';

void main() {
  runApp(const MarsApp());
}

class MarsApp extends StatelessWidget {
  const MarsApp({super.key});

  @override
  Widget build(BuildContext context) {
 
    final api = ApiClient(); 


    const nasaKey = 'V4CYE5ThmFj4AFAgFMab0WnvCyVKJCS9UuVwyIxg'; 


    final repo = PhotoRepository(
      api,
      apiKey: nasaKey,
      rover: 'curiosity',
      sol: 1000,
  
    );

        return ChangeNotifierProvider(
      create: (_) => GalleryController(repo: repo, pageSize: 25), 
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const GalleryPage(),
      ),
    );
  }
}
