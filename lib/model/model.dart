import 'package:flutter/material.dart';

class TagData {
  Offset offset;
  String data;

  TagData({required this.data, required this.offset});

  Map<String, dynamic> toJson() {
    return {'dx': offset.dx, 'dy': offset.dy, 'data': data};
  }

  static fromJson(Map<String, dynamic> data) {
    return TagData(data: data['data'], offset: Offset(data['dx'], data['dy']));
  }
}

class ImageData {
  String imageUrl;
  List<TagData> tags;
  ImageData({required this.imageUrl, required this.tags});

  static ImageData fromJson(Map<String, dynamic> data) {
    return ImageData(
        imageUrl: data['imageUrl'],
        tags: List.from(data['tags'].map((e) => TagData.fromJson(e))));
  }

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'tags': List.from(tags.map((e) => e.toJson()))
    };
  }
}
