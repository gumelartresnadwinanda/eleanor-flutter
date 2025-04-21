import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IngredientsProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredient => List.unmodifiable(_ingredients);

  Ingredient? _selectedIngredient;
  Ingredient? get selectedIngredient => _selectedIngredient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchIngredients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(Uri.parse('$baseUrl/api/ingredients'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _ingredients =
            data
                .map(
                  (json) => Ingredient.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        _error = null;
      } else {
        throw Exception('Failed to load meal plans');
      }
    } catch (e) {
      _error = e.toString();
      _ingredients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
