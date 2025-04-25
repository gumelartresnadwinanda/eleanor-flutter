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

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _detailError;
  String? get detailError => _detailError;
  String? _error;
  String? get error => _error;

  String get _baseUrl {
    final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return baseUrl;
  }

  Future<void> fetchRecipes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/recipes'));

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

  Future<Recipe?> fetchDetailRecipe(int id) async {
    _isDetailLoading = true;
    _detailError = '';
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(Uri.parse('$baseUrl/api/recipes/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _selectedRecipe = Recipe.fromJson(data as Map<String, dynamic>);
        _detailError = null;
        return _selectedRecipe;
      } else {
        throw Exception('Failed to load recipe details');
      }
    } catch (e) {
      _detailError = e.toString();
      _selectedRecipe = null;
      return null;
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<void> createRecipe(FormRecipe recipe) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/recipes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );
      if (response.statusCode == 201) {
        await fetchRecipes();
      } else {
        throw Exception('Failed to create ingredients');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRecipe(FormRecipe recipe) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/recipes/${recipe.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(recipe.toJson()),
      );
      if (response.statusCode == 200) {
        await fetchRecipes();
      } else {
        throw Exception('Failed to create ingredients');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
