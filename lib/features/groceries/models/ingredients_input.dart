import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:flutter/widgets.dart';

class IngredientInput {
  Ingredient ingredient;
  final TextEditingController controller;

  IngredientInput({required this.ingredient})
    : controller = TextEditingController(text: '${ingredient.quantity ?? 0}');

  void dispose() {
    controller.dispose();
  }
}
