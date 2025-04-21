import 'package:flutter/foundation.dart';
import 'ingredient.dart';

@immutable
class Recipe {
  final String name;
  final String? imageUrl;
  final List<Ingredient> ingredients;

  const Recipe({required this.name, this.imageUrl, required this.ingredients});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['recipe_name'] as String,
      imageUrl: json['image_url'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_name': name,
      'image_url': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        listEquals(other.ingredients, ingredients);
  }

  @override
  int get hashCode => Object.hash(name, imageUrl, Object.hashAll(ingredients));

  Recipe copyWith({
    String? name,
    String? Function()? imageUrl,
    List<Ingredient>? ingredients,
  }) {
    return Recipe(
      name: name ?? this.name,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}
