import 'package:flutter/foundation.dart';
import 'ingredient.dart';
import 'recipe.dart';

@immutable
class GroceryList {
  final List<Recipe> recipes;
  final List<Ingredient> ingredients;

  const GroceryList({required this.recipes, required this.ingredients});

  factory GroceryList.fromRecipesList(List<dynamic> json) {
    final recipes =
        json.map((e) => Recipe.fromJson(e as Map<String, dynamic>)).toList();
    // Aggregate ingredients from recipes
    final Map<String, Ingredient> aggregatedIngredients = {};
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        final key = '${ingredient.name}_${ingredient.unit}';
        if (aggregatedIngredients.containsKey(key)) {
          final existing = aggregatedIngredients[key]!;
          aggregatedIngredients[key] = existing.copyWith(
            quantity: existing.quantity + ingredient.quantity,
          );
        } else {
          aggregatedIngredients[key] = ingredient;
        }
      }
    }

    return GroceryList(
      recipes: recipes,
      ingredients: aggregatedIngredients.values.toList(),
    );
  }

  factory GroceryList.fromIngredientsList(List<dynamic> json) {
    final ingredients =
        json
            .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
            .toList();
    return GroceryList(recipes: [], ingredients: ingredients);
  }

  Map<String, dynamic> toJson() {
    return {
      'recipes': recipes.map((e) => e.toJson()).toList(),
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroceryList &&
        listEquals(other.recipes, recipes) &&
        listEquals(other.ingredients, ingredients);
  }

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(recipes), Object.hashAll(ingredients));

  GroceryList copyWith({List<Recipe>? recipes, List<Ingredient>? ingredients}) {
    return GroceryList(
      recipes: recipes ?? this.recipes,
      ingredients: ingredients ?? this.ingredients,
    );
  }

  // Helper method to get total quantity of an ingredient across all recipes
  double getTotalQuantityForIngredient(String name, String unit) {
    return ingredients
        .where((i) => i.name == name && i.unit == unit)
        .fold(0.0, (sum, ingredient) => sum + ingredient.quantity);
  }
}
