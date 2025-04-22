import 'package:eleanor/features/groceries/providers/grocery_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../widgets/grocery_list_card.dart';
import 'dart:developer' as developer;

class GroceriesScreen extends StatefulWidget {
  const GroceriesScreen({super.key});

  @override
  State<GroceriesScreen> createState() => _GroceriesScreenState();
}

class _GroceriesScreenState extends State<GroceriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryListProvider>().fetchLatestGroceryList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GroceryListProvider>(context);
    developer.log(provider.groceryList.toString(), name: 'Grocery List');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchLatestGroceryList(),
            tooltip: 'Refresh',
          ),
          // View type toggle
          IconButton(
            icon: Icon(
              provider.isRecipeView
                  ? Icons.restaurant_menu
                  : Icons.shopping_basket,
            ),
            onPressed: () => provider.switchViewType(context),
            tooltip: provider.isRecipeView ? 'By Recipe' : 'By Ingredient',
          ),
          // Clear button
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Clear All'),
                      content: const Text(
                        'Are you sure you want to clear all checked items?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearCheckedItems();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
              );
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [_buildGridView(), const GroceryListCard()]),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 5,
      children: _buildMenuItems(),
    );
  }

  List<Widget> _buildMenuItems() {
    return [
      SizedBox(width: 50),
      _buildMenuItem(
        icon: Icons.restaurant,
        title: 'Recipe',
        onTap: () => context.push('/groceries/recipes'),
      ),
      _buildMenuItem(
        icon: Icons.kitchen,
        title: 'Ingredients',
        onTap: () => context.push('/groceries/ingredients'),
      ),
      _buildMenuItem(
        icon: Icons.restaurant_menu,
        title: 'Meal Plan',
        onTap: () => context.push('/groceries/meal-plans'),
      ),
    ];
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  blurRadius: 4,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: Colors.grey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
