import 'package:eleanor/features/groceries/providers/ingredients_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class GroceriesIngredientsScreen extends StatefulWidget {
  const GroceriesIngredientsScreen({super.key});

  @override
  State<GroceriesIngredientsScreen> createState() =>
      _GroceriesIngredientsScreenState();
}

class _GroceriesIngredientsScreenState
    extends State<GroceriesIngredientsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientsProvider>().fetchIngredients();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredients')),
      body: Text("asdasdas"),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
