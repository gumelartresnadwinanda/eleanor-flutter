import 'package:flutter/foundation.dart';
import 'ingredient.dart';

@immutable
class Recipe {
  final int? id;
  final String name;
  final String? imageUrl;
  final List<Ingredient> ingredients;

  const Recipe({
    this.id,
    required this.name,
    this.imageUrl,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.id == id &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        listEquals(other.ingredients, ingredients);
  }

  @override
  int get hashCode =>
      Object.hash(id, name, imageUrl, Object.hashAll(ingredients));

  Recipe copyWith({
    int? id,
    String? name,
    String? Function()? imageUrl,
    List<Ingredient>? ingredients,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      ingredients: ingredients ?? this.ingredients,
    );
  }
}

class FormRecipe {
  final int? id;
  final String name;
  final String? imageUrl;
  final List<Ingredient>? ingredients;

  const FormRecipe({
    this.id,
    required this.name,
    this.imageUrl,
    this.ingredients,
  });

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, imageUrl: $imageUrl, ingredient: ${ingredients.toString()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'ingredients': ingredients?.map((e) => e.toEssensialJson()).toList(),
    };
  }

  Map<String, dynamic> toIngredientsJson() {
    return {
      'ingredients': ingredients?.map((e) => e.toEssensialJson()).toList(),
    };
  }
}
