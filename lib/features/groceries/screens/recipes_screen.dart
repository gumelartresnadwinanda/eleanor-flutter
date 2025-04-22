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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesProvider>().fetchRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterRecipes(List<dynamic> recipes) {
    if (_searchQuery.isEmpty) return recipes;
    return recipes
        .where(
          (recipe) =>
              recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RecipesProvider>(context);
    final filteredRecipes = _filterRecipes(provider.recipes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredRecipes.length,
        itemBuilder: (context, index) {
          final recipe = filteredRecipes[index];
          return ListTile(title: Text(recipe.name), onTap: () {});
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
