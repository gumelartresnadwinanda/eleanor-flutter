import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  final int id;
  final String name;
  final double? quantity;
  final String unit;
  final String? imageUrl;

  const Ingredient({
    required this.id,
    required this.name,
    this.quantity,
    required this.unit,
    this.imageUrl,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] ?? json['total_quantity']).toDouble(),
      unit: json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  factory Ingredient.fromJsonList(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: 0,
      unit: json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    };
  }

  Map<String, dynamic> toEssensialJson() {
    return {"ingredient_id": id, 'quantity': quantity};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient && other.id == id;
  }

  @override
  int get hashCode => Object.hash(name, quantity, unit, imageUrl);

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, unit:$unit, quantity:$quantity)';
  }

  Ingredient copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    String? Function()? imageUrl,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
    );
  }
}

class IngredientMealPlanFormData {
  final int id;
  final double quantity;

  const IngredientMealPlanFormData({required this.id, required this.quantity});
  @override
  String toString() {
    return 'IngredientMealPlanFormData(id: $id, quantity: $quantity)';
  }

  Map<String, dynamic> toJson() {
    return {"ingredient_id": id, 'quantity': quantity};
  }
}
