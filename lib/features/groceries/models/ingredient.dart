import 'package:flutter/foundation.dart';

@immutable
class Ingredient {
  final String name;
  final double quantity;
  final String unit;
  final String? imageUrl;

  const Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.imageUrl,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      quantity: (json['quantity'] ?? json['total_quantity']).toDouble(),
      unit: json['unit'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(name, quantity, unit, imageUrl);

  Ingredient copyWith({
    String? name,
    double? quantity,
    String? unit,
    String? Function()? imageUrl,
  }) {
    return Ingredient(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
    );
  }
}
