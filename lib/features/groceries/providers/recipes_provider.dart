import 'package:eleanor/features/groceries/models/recipe.dart';
import 'package:eleanor/features/groceries/models/recipe_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RecipesProvider with ChangeNotifier {
  List<RecipeList> _recipes = [];
  List<RecipeList> get recipes => List.unmodifiable(_recipes);

  Recipe? _selectedRecipe;
  Recipe? get selectedRecipe => _selectedRecipe;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(Uri.parse('$baseUrl/api/recipes'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _recipes =
            data
                .map(
                  (json) => RecipeList.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        _error = null;
      } else {
        throw Exception('Failed to load meal plans');
      }
    } catch (e) {
      _error = e.toString();
      _recipes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
