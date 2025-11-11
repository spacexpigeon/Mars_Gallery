class Photo {
  final String id;
  final String url;
  final String? cameraName;
  final String? roverName;
  final String? earthDate;

  Photo({
    required this.id,
    required this.url,
    this.cameraName,
    this.roverName,
    this.earthDate,
  });

  factory Photo.fromJson(Map<String, dynamic> json) => Photo(
        id: json['id'].toString(),
        url: (json['img_src'] as String).replaceFirst('http://', 'https://'),
        cameraName: json['camera']?['full_name'] as String?,
        roverName: json['rover']?['name'] as String?,
        earthDate: json['earth_date'] as String?,
      );
}

