import "package:parcelviewer/core/api_client.dart";
import 'package:parcelviewer/features/gallery/data/photo.dart';

class PhotoRepository {
  final ApiClient api;

  PhotoRepository(this.api);

  Future<List<Photo>> fetchPage(int page, int pageSize) async {
    final rows = await api.getPhotos(page: page, pageSize: pageSize);
    return rows.map(Photo.fromJson).toList();
  }
}
