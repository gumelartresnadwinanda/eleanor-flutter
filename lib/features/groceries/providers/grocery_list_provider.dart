import 'package:eleanor/features/groceries/models/grocery_list.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroceryListProvider with ChangeNotifier {
  GroceryList? _groceryList;
  GroceryList? get groceryList => _groceryList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Track checked state of items
  final Map<String, bool> _checkedItems = {};
  Map<String, bool> get checkedItems => Map.unmodifiable(_checkedItems);

  // Track current view type
  bool _isRecipeView = true;
  bool get isRecipeView => _isRecipeView;

  Future<void> fetchGroceryList(int mealPlanId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception('API_BASE_URL not found in environment variables');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/meal-plans/$mealPlanId/grocery-list/by-recipe'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _groceryList = GroceryList.fromRecipesList(data);
        _error = null;
      } else {
        throw Exception('Failed to load grocery list');
      }
    } catch (e) {
      _error = e.toString();
      _groceryList = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLatestGroceryList() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['GROCERY_API_BASE_URL'];
      if (baseUrl == null) {
        throw Exception(
          'GROCERY_API_BASE_URL not found in environment variables',
        );
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/meal-plans/latest-id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        fetchGroceryList(data['id'] as int);
      } else {
        _error =
            'Failed to load grocery list. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _groceryList = GroceryList(recipes: [], ingredients: []);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearGroceryList() {
    _groceryList = null;
    _error = null;
    notifyListeners();
  }

  // Toggle checked state of an item
  void toggleItemChecked(String key, bool value) {
    _checkedItems[key] = value;
    notifyListeners();
  }

  // Clear all checked items
  void clearCheckedItems() {
    _checkedItems.clear();
    notifyListeners();
  }

  // Switch between recipe and ingredient view
  Future<void> switchViewType(BuildContext context) async {
    if (_checkedItems.isNotEmpty) {
      final shouldSwitch = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Switch View Type'),
              content: const Text(
                'Switching views will clear your checked items. Do you want to continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Switch'),
                ),
              ],
            ),
      );

      if (shouldSwitch != true) return;
    }

    _isRecipeView = !_isRecipeView;
    _checkedItems.clear();
    notifyListeners();
  }
}
