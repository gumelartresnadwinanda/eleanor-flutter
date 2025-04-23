import 'package:flutter/foundation.dart';

@immutable
class MealPlanMeal {
  final String name;
  final String? imageUrl;
  final int multiplier;

  const MealPlanMeal({
    required this.name,
    this.imageUrl,
    required this.multiplier,
  });

  factory MealPlanMeal.fromJson(Map<String, dynamic> json) {
    return MealPlanMeal(
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      multiplier: json['multiplier'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'image_url': imageUrl, 'multiplier': multiplier};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanMeal &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.multiplier == multiplier;
  }

  @override
  int get hashCode => Object.hash(name, imageUrl, multiplier);

  MealPlanMeal copyWith({
    String? name,
    String? Function()? imageUrl,
    int? multiplier,
  }) {
    return MealPlanMeal(
      name: name ?? this.name,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      multiplier: multiplier ?? this.multiplier,
    );
  }
}

@immutable
class MealPlanExtra {
  final int id;
  final String name;
  final double quantity;
  final String unit;
  final String? imageUrl;

  const MealPlanExtra({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.imageUrl,
  });

  factory MealPlanExtra.fromJson(Map<String, dynamic> json) {
    return MealPlanExtra(
      id: json['id'] as int,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlanExtra &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => Object.hash(id, name, quantity, unit, imageUrl);

  MealPlanExtra copyWith({
    int? id,
    String? name,
    double? quantity,
    String? unit,
    String? imageUrl,
  }) {
    return MealPlanExtra(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

@immutable
class MealPlan {
  final int id;
  final String title;
  final DateTime createdAt;
  final bool archived;
  final List<MealPlanMeal>? meals;
  final List<MealPlanExtra>? extras;

  const MealPlan({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.archived,
    this.meals,
    this.extras,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as int,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['archived'] as bool,
      meals:
          json['meals'] != null
              ? (json['meals'] as List<dynamic>)
                  .map((e) => MealPlanMeal.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      extras:
          json['extras'] != null
              ? (json['extras'] as List<dynamic>)
                  .map((e) => MealPlanExtra.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'archived': archived,
      'meals': meals?.map((e) => e.toJson()).toList(),
      'extras': extras?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealPlan &&
        other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.archived == archived &&
        listEquals(other.meals, meals) &&
        listEquals(other.extras, extras);
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    archived,
    Object.hashAll(meals ?? []),
    Object.hashAll(extras ?? []),
  );

  MealPlan copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    bool? archived,
    List<MealPlanMeal>? meals,
    List<MealPlanExtra>? extras,
  }) {
    return MealPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
      meals: meals ?? this.meals,
      extras: extras ?? this.extras,
    );
  }
}
