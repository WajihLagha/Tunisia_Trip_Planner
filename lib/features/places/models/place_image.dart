class PlaceImage {
  final String? id;
  final String url;

  PlaceImage({this.id, required this.url});

  factory PlaceImage.fromJson(Map<String, dynamic> json) {
    return PlaceImage(
      id: json['id'] as String?,
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'url': url,
    };
  }
}
