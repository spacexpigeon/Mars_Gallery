class Photo {
  final String id;
  final String url;

  Photo({required this.id, required this.url});

  factory Photo.fromJson(Map<String, dynamic> json) =>
      Photo(id: json['id'].toString(), url: json['url'] as String);
}
