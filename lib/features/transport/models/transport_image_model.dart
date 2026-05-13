class TransportImageModel {
  final int? id;
  final int transportId;
  final String imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const TransportImageModel({
    this.id,
    required this.transportId,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory TransportImageModel.fromJson(Map<String, dynamic> json) {
    return TransportImageModel(
      id: json['id'] as int?,
      transportId: json['transportId'] as int? ?? 0,
      imageUrl: json['imageUrl'] as String? ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transportId': transportId,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
