import 'package:flutter/foundation.dart';

@immutable
class RecipeList {
  final int id;
  final String name;
  final String? imageUrl;
  final int? defaultPortion;
  const RecipeList({
    required this.id,
    required this.name,
    this.imageUrl,
    this.defaultPortion,
  });

  factory RecipeList.fromJson(Map<String, dynamic> json) {
    return RecipeList(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      defaultPortion: json['default_portion'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'default_portion': defaultPortion,
    };
  }

  @override
  String toString() {
    return "Recipe(id: $id, name: $name, image_url: $imageUrl, default_portion: $defaultPortion)";
  }

  RecipeList copyWith({
    int? id,
    String? name,
    String? Function()? imageUrl,
    int? defaultPortion,
  }) {
    return RecipeList(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      defaultPortion: defaultPortion ?? this.defaultPortion,
    );
  }
}
