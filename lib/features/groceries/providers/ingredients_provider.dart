import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class IngredientsProvider with ChangeNotifier {
  List<Ingredient> _ingredients = [];
  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);

  Ingredient? _selectedIngredient;
  Ingredient? get selectedIngredient => _selectedIngredient;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String get _baseUrl {
    final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return baseUrl;
  }

  Future<void> fetchIngredients({bool? isExtra}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/api/ingredients?${isExtra != null ? 'is_extra=true' : ''}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _ingredients =
            data
                .map(
                  (json) =>
                      Ingredient.fromJsonList(json as Map<String, dynamic>),
                )
                .toList();
        _error = null;
      } else {
        throw Exception('Failed to load ingredients');
      }
    } catch (e) {
      _error = e.toString();
      _ingredients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createIngredient(Ingredient ingredient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/ingredients'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ingredient.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchIngredients();
      } else {
        throw Exception('Failed to create ingredient');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/ingredients/${ingredient.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ingredient.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchIngredients();
      } else {
        throw Exception('Failed to update ingredient');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectIngredient(Ingredient? ingredient) {
    _selectedIngredient = ingredient;
    notifyListeners();
  }
}
