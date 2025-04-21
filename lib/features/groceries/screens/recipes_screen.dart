import 'package:eleanor/features/groceries/providers/recipes_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class GroceriesRecipesScreen extends StatefulWidget {
  const GroceriesRecipesScreen({super.key});

  @override
  State<GroceriesRecipesScreen> createState() => _GroceriesRecipesScreenState();
}

class _GroceriesRecipesScreenState extends State<GroceriesRecipesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe')),
      body: Text('asdasdasdas'),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
