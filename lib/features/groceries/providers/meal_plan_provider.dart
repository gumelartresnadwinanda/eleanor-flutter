import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:eleanor/features/groceries/models/recipe_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/meal_plan.dart';

class MealPlanProvider with ChangeNotifier {
  List<MealPlan> _mealPlans = [];
  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);

  MealPlan? _selectedMealPlan;
  MealPlan? get selectedMealPlan => _selectedMealPlan;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MealPlanExtra> _mealPlanExtras = [];
  List<MealPlanExtra> get mealPlanExtras => List.from(_mealPlanExtras);

  List<MealPlanMeal> _mealPlanMeals = [];
  List<MealPlanMeal> get mealPlanMeals => List.from(_mealPlanMeals);

  Future<void> initMealPlanForm(int id) async {
    if (id == -1) {
      _selectedMealPlan = null;
      _mealPlanExtras = [];
      _mealPlanMeals = [];
    } else {
      _mealPlanMeals = List.from(selectedMealPlan?.meals ?? []);
      _mealPlanExtras = List.from(selectedMealPlan?.extras ?? []);
    }

    notifyListeners();
  }

  Future<void> addMealPlanMeal(RecipeList meal) async {
    if (!_mealPlanMeals.any((i) => i.id == meal.id)) {
      final newMeal = MealPlanMeal(
        id: meal.id,
        name: meal.name,
        multiplier: 1,
        imageUrl: meal.imageUrl,
      );
      _mealPlanMeals.add(newMeal);
    }
    notifyListeners();
  }

  Future<void> removeMealPlanMeal(int index) async {
    _mealPlanMeals.removeAt(index);
    notifyListeners();
  }

  Future<void> addMealPlanExtra(Ingredient extra) async {
    if (!_mealPlanExtras.any((i) => i.id == extra.id)) {
      final newExtra = MealPlanExtra(
        id: extra.id,
        name: extra.name,
        unit: extra.unit,
        quantity: 1,
        imageUrl: extra.imageUrl,
      );
      _mealPlanExtras.add(newExtra);
    }
    notifyListeners();
  }

  Future<void> removeMealPlanExtra(int index) async {
    _mealPlanExtras.removeAt(index);
    notifyListeners();
  }

  Future<void> confirmMealPlan() async {
    print("");
    print("");
  }

  Future<void> fetchMealPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(Uri.parse('$baseUrl/api/meal-plans'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _mealPlans =
            data
                .map((json) => MealPlan.fromJson(json as Map<String, dynamic>))
                .toList();
        _error = null;
      } else {
        throw Exception('Failed to load meal plans');
      }
    } catch (e) {
      _error = e.toString();
      _mealPlans = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMealPlanDetails(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(Uri.parse('$baseUrl/api/meal-plans/$id'));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _selectedMealPlan = MealPlan.fromJson(json as Map<String, dynamic>);
        _error = null;
      } else {
        throw Exception('Failed to load meal plan details');
      }
    } catch (e) {
      _error = e.toString();
      _selectedMealPlan = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMealPlan(String title) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/meal-plans'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );

      if (response.statusCode == 201) {
        await fetchMealPlans();
      } else {
        throw Exception('Failed to create meal plan');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMealPlan(int id, String title) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/meal-plans/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'title': title}),
      );

      if (response.statusCode == 200) {
        await fetchMealPlans();
        if (_selectedMealPlan?.id == id) {
          await fetchMealPlanDetails(id);
        }
      } else {
        throw Exception('Failed to update meal plan');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveMealPlan(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/meal-plans/$id/archive'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchMealPlans();
        if (_selectedMealPlan?.id == id) {
          await fetchMealPlanDetails(id);
        }
      } else {
        throw Exception('Failed to archive meal plan');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
