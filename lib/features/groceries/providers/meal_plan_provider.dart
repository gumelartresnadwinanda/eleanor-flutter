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

  String _title = '';
  String get title => _title;

  List<MealPlanExtra> _mealPlanExtras = [];
  List<MealPlanExtra> get mealPlanExtras => List.from(_mealPlanExtras);

  List<MealPlanMeal> _mealPlanMeals = [];
  List<MealPlanMeal> get mealPlanMeals => List.from(_mealPlanMeals);

  String get _baseUrl {
    final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
    if (baseUrl == null) {
      throw Exception('API_BASE_URL not found in environment variables');
    }
    return baseUrl;
  }

  Future<void> initMealPlanForm(int id) async {
    if (id == -1) {
      _selectedMealPlan = null;
      _mealPlanExtras = [];
      _mealPlanMeals = [];
      _title = '';
    } else {
      _mealPlanMeals = List.from(selectedMealPlan?.meals ?? []);
      _mealPlanExtras = List.from(selectedMealPlan?.extras ?? []);
      _title = selectedMealPlan?.title ?? '';
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
        comparisonScale: extra.comparisonScale,
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

  Future<void> confirmMealPlan(
    Map<String, String>? currentValue,
    int id,
  ) async {
    final formTitle = currentValue?['title'] ?? selectedMealPlan?.title ?? '';
    final meals = mealPlanMeals.map((m) => m.id).toList();
    final extras =
        mealPlanExtras.map((e) {
          final multiplier = e.comparisonScale ?? 1;
          return IngredientMealPlanFormData(
            id: e.id,
            quantity:
                double.tryParse(
                  ((double.tryParse(currentValue?['quantity-${e.id}'] ?? '1')
                              as num) *
                          (multiplier))
                      .toString(),
                ) ??
                1.0,
          );
        }).toList();

    final body = MealPlanFormData(
      title: formTitle,
      meals: meals,
      extraItems: extras,
    );

    if (id == -1) {
      createMealPlan(body);
    } else {
      updateMealPlan(body, id);
    }
  }

  Future<void> fetchMealPlans() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/meal-plans'));

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

  Future<void> createMealPlan(MealPlanFormData data) async {
    _isLoading = false;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/meal-plans/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 201) {
        await fetchMealPlans();
      } else {
        throw Exception(
          'Failed to create meal plan. code:${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      print("error:$error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMealPlan(MealPlanFormData data, int id) async {
    _isLoading = false;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/meal-plans/$id/complete'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data.toJson()),
      );

      if (response.statusCode == 200) {
        await fetchMealPlanDetails(id);
      } else {
        throw Exception(
          'Failed to update meal plan. code:${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      print("error:$error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> archiveMealPlan(int id) async {
    _isLoading = false;
    _error = null;
    notifyListeners();

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/meal-plans/$id/archive'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await fetchMealPlans();
      } else {
        throw Exception(
          'Failed to archive meal plan. code:${response.statusCode}',
        );
      }
    } catch (e) {
      _error = e.toString();
      print("error:$error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
