import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  final int id;
  final String name;
  final double? quantity;
  final double? comparisonScale;
  final double? minimumPurchase;
  final String? unitPurchase;
  final String unit;
  final String? imageUrl;

  const Ingredient({
    required this.id,
    required this.name,
    this.quantity,
    required this.unit,
    this.imageUrl,
    this.unitPurchase,
    this.comparisonScale,
    this.minimumPurchase,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] ?? json['total_quantity']).toDouble(),
      comparisonScale: ((json['comparison_scale'] ?? 1).toDouble()),
      minimumPurchase: ((json['minimum_purchase'] ?? 1).toDouble()),
      unit: json['unit'] as String,
      unitPurchase: json['unit_purchase'] ?? json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  factory Ingredient.fromJsonList(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: 0,
      comparisonScale: ((json['comparison_scale'] ?? 1).toDouble()),
      minimumPurchase: ((json['minimum_purchase'] ?? 1).toDouble()),
      unit: json['unit'] as String,
      unitPurchase: json['unit_purchase'] ?? json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'name': name,
      'quantity': quantity,
      'comparison_scale': comparisonScale,
      'minimum_purchase': minimumPurchase,
      'unit_purchase': unitPurchase,
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
  int get hashCode => Object.hash(
    name,
    quantity,
    unit,
    imageUrl,
    comparisonScale,
    unitPurchase,
    minimumPurchase,
  );

  @override
  String toString() {
    return 'Ingredient(id: $id, name: $name, unit:$unit, quantity:$quantity, unit_purchase:$unitPurchase, comparison_scale:$comparisonScale, minimum_purchase:$minimumPurchase)';
  }

  Ingredient copyWith({
    int? id,
    String? name,
    double? quantity,
    double? minimumPurchase,
    double? comparisonScale,
    String? unitPurchase,
    String? unit,
    String? Function()? imageUrl,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      comparisonScale: comparisonScale ?? this.comparisonScale,
      unitPurchase: unitPurchase ?? this.unitPurchase,
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
