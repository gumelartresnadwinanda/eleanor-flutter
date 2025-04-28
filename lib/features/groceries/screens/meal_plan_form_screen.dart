import 'package:eleanor/core/providers/form_controller_provider.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:eleanor/core/widgets/image_preview.dart';
import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:eleanor/features/groceries/models/recipe_list.dart';
import 'package:eleanor/features/groceries/providers/ingredients_provider.dart';
import 'package:eleanor/features/groceries/providers/meal_plan_provider.dart';
import 'package:eleanor/features/groceries/providers/recipes_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MealPlanFormScreen extends StatefulWidget {
  final int id;
  const MealPlanFormScreen({super.key, required this.id});

  @override
  State<MealPlanFormScreen> createState() => _MealPlanFormScreenState();
}

class _MealPlanFormScreenState extends State<MealPlanFormScreen> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      context.read<RecipesProvider>().fetchRecipes();
      context.read<IngredientsProvider>().fetchIngredients(isExtra: true);
      final mealPlanProvider = context.read<MealPlanProvider>();
      await mealPlanProvider.initMealPlanForm(widget.id);
      if (!mounted) return;
      final formProvider = context.read<FormControllerProvider>();
      formProvider.disposeControllers();
      formProvider.setInitialValue('title', mealPlanProvider.title);
      for (final extra in mealPlanProvider.mealPlanExtras) {
        formProvider.setInitialValue(
          "quantity-${extra.id}",
          '${extra.quantity}',
        );
      }
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  Future<void> _showExtraSelection() async {
    final extraProvider = Provider.of<IngredientsProvider>(
      context,
      listen: false,
    );
    final mealPlanProvider = Provider.of<MealPlanProvider>(
      context,
      listen: false,
    );
    final extraOptions = extraProvider.ingredients;
    final ScrollController extraScrollController = ScrollController();
    final TextEditingController searchExtraController = TextEditingController();
    String extraSearchQuery = '';
    List<dynamic> filterIngredients(List<dynamic> extras) {
      if (extraSearchQuery.isEmpty) return extras;
      return extras
          .where(
            (extra) => extra.name.toLowerCase().contains(
              extraSearchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    final result = await showDialog<Ingredient>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final filteredExtra = filterIngredients(extraOptions);
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            controller: searchExtraController,
                            decoration: InputDecoration(
                              hintText: 'Cari Tambahan Bahan Belanja',
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
                                extraSearchQuery = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 420,
                          child: CustomScrollView(
                            controller: extraScrollController,
                            slivers: [
                              SliverList.builder(
                                itemCount: filteredExtra.length,
                                itemBuilder: (context, index) {
                                  final extra = filteredExtra[index];
                                  return (ListTile(
                                    leading:
                                        extra.imageUrl != null
                                            ? ImagePreview(
                                              imageUrl: extra.imageUrl,
                                              dimesion: 50,
                                              size: 25,
                                            )
                                            : Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 25,
                                              ),
                                            ),
                                    title: Text(extra.name),
                                    onTap:
                                        () => Navigator.of(context).pop(extra),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
    if (result != null) {
      mealPlanProvider.addMealPlanExtra(result);
      if (!mounted) return;
      context.read<FormControllerProvider>().setInitialValue(
        'quantity-${result.id}',
        '1',
      );
    }
  }

  Future<void> _showRecipeSelection() async {
    final recipeProvider = Provider.of<RecipesProvider>(context, listen: false);
    final mealPlanProvider = Provider.of<MealPlanProvider>(
      context,
      listen: false,
    );
    final recipeOptions = recipeProvider.recipes;
    final ScrollController recipeScrollController = ScrollController();
    final TextEditingController searchRecipeController =
        TextEditingController();
    String searchRecipeQuery = '';
    List<dynamic> filterRecipes(List<dynamic> recipes) {
      if (searchRecipeQuery.isEmpty) return recipes;
      return recipes
          .where(
            (recipe) => recipe.name.toLowerCase().contains(
              searchRecipeQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    final result = await showDialog<RecipeList?>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              final filteredRecipe = filterRecipes(recipeOptions);
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: searchRecipeController,
                            decoration: InputDecoration(
                              hintText: 'Cari Menu',
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
                                searchRecipeQuery = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 420,
                          child: CustomScrollView(
                            controller: recipeScrollController,
                            slivers: [
                              SliverList.builder(
                                itemCount: filteredRecipe.length,
                                itemBuilder: (context, index) {
                                  final recipe = filteredRecipe[index];
                                  return (ListTile(
                                    leading:
                                        recipe.imageUrl != null
                                            ? ImagePreview(
                                              imageUrl: recipe.imageUrl,
                                              dimesion: 50,
                                              size: 25,
                                            )
                                            : Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                size: 25,
                                              ),
                                            ),
                                    title: Text(recipe.name),
                                    onTap:
                                        () => Navigator.of(context).pop(recipe),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );

    if (result != null) {
      mealPlanProvider.addMealPlanMeal(result);
    }
  }

  @override
  build(BuildContext context) {
    final provider = Provider.of<MealPlanProvider>(context);
    final formControllerProvider = Provider.of<FormControllerProvider>(
      context,
      listen: false,
    );
    final titleText =
        widget.id != -1 ? "Update Meal Plan" : "Create New Meal Plan";
    return Scaffold(
      appBar: AppBar(title: Text(titleText)),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: formControllerProvider.getController('title'),
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      print('value, $value');
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverList.builder(
                itemCount: provider.mealPlanMeals.length,
                itemBuilder: (context, index) {
                  final recipe = provider.mealPlanMeals[index];
                  return (ListTile(
                    leading:
                        recipe.imageUrl != null
                            ? ImagePreview(
                              imageUrl: recipe.imageUrl,
                              dimesion: 50,
                              size: 25,
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 25,
                              ),
                            ),
                    title: Text(recipe.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            // ON REMOVE RECIPE
                            provider.removeMealPlanMeal(index);
                          },
                          icon: Icon(Icons.delete_rounded),
                        ),
                      ],
                    ),
                  ));
                },
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () => _showRecipeSelection(),
                        child: const Text("Tambah Menu Makanan"),
                      ),
                    ),

                    Divider(),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      "Tambahan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SliverList.builder(
                itemCount: provider.mealPlanExtras.length,
                itemBuilder: (context, index) {
                  final extra = provider.mealPlanExtras[index];
                  return ListTile(
                    leading:
                        extra.imageUrl != null
                            ? ImagePreview(
                              imageUrl: extra.imageUrl,
                              dimesion: 50,
                              size: 25,
                            )
                            : Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 25,
                              ),
                            ),
                    title: Text(extra.name),

                    subtitle: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: formControllerProvider.getController(
                              'quantity-${extra.id}',
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(extra.unit),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            // ON REMOVE EXTRA
                            provider.removeMealPlanExtra(index);
                          },
                          icon: Icon(Icons.delete_rounded),
                        ),
                      ],
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () => _showExtraSelection(),
                        child: const Text("Tambah Daftar Belanja Tambahan"),
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: const SizedBox()),
                        ElevatedButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text("Cancel"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final nav = Navigator.of(context);
                              await provider.confirmMealPlan(
                                formControllerProvider.currentValues,
                                widget.id,
                              );
                              nav.pop();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
