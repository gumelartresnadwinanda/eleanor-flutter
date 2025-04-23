import 'package:eleanor/core/services/permission_service.dart';
import 'package:eleanor/core/widgets/image_preview.dart';
import 'package:eleanor/features/groceries/models/ingredient.dart';
import 'package:eleanor/features/groceries/models/ingredients_input.dart';
import 'package:eleanor/features/groceries/models/recipe.dart';
import 'package:eleanor/features/groceries/models/recipe_list.dart';
import 'package:eleanor/features/groceries/providers/ingredients_provider.dart';
import 'package:eleanor/features/groceries/providers/recipes_provider.dart';
import 'package:flutter/material.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class GroceriesRecipesScreen extends StatefulWidget {
  const GroceriesRecipesScreen({super.key});

  @override
  State<GroceriesRecipesScreen> createState() => _GroceriesRecipesScreenState();
}

class _GroceriesRecipesScreenState extends State<GroceriesRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipesProvider>().fetchRecipes();
      context.read<IngredientsProvider>().fetchIngredients();
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

  Future<String?> _pickImage() async {
    try {
      final hasPermission = await PermissionService.requestImagePermission(
        onPermissionDenied: (message) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        onPermissionPermanentlyDenied: (message) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
      );
      if (!hasPermission) return null;

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print("Image path: ${image.path}");
        return image.path;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
    return null;
  }

  Future<void> _showRecipeDetail([RecipeList? recipe]) async {
    final provider = Provider.of<RecipesProvider>(context, listen: false);
    final ingredientProvider = Provider.of<IngredientsProvider>(
      context,
      listen: false,
    );
    final ingredientOptions = ingredientProvider.ingredients;

    Recipe? selectedRecipe;
    String? imagePath;
    String? imageUrl;
    List<IngredientInput>? ingredientInputs = [];

    if (recipe != null) {
      selectedRecipe = await provider.fetchDetailRecipe(recipe.id);
      final initialIngredients = selectedRecipe?.ingredients ?? [];
      imageUrl = selectedRecipe?.imageUrl;
      ingredientInputs =
          initialIngredients
              .map((i) => IngredientInput(ingredient: i))
              .toList();
      if (!mounted) return;
    }
    final nameController = TextEditingController(
      text: selectedRecipe?.name ?? '',
    );

    final result = await showDialog<FormRecipe>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                insetPadding: EdgeInsets.zero,
                child: SizedBox.expand(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(
                        recipe == null ? 'Add Recipe' : 'Edit Recipe',
                      ),
                    ),
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'This field is required';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              if (imageUrl != null || imagePath != null)
                                ImagePreview(
                                  imagePath: imagePath,
                                  imageUrl: imageUrl,
                                  onRemove: () {
                                    setState(() {
                                      imagePath = null;
                                      imageUrl = null;
                                    });
                                  },
                                ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (!mounted) return;
                                  final path = await _pickImage();
                                  if (path != null && mounted) {
                                    setState(() {
                                      imagePath = path;
                                      imageUrl = null;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.image),
                                label: const Text('Pick Image'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...List.generate(ingredientInputs?.length ?? 0, (
                                index,
                              ) {
                                final ingredient = ingredientInputs![index];
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Text(ingredient.ingredient.name),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextField(
                                        controller: ingredient.controller,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          ingredient.dispose();
                                          ingredientInputs!.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.delete),
                                    ),
                                  ],
                                );
                              }),
                              SizedBox(height: 16),
                              TypeAheadField<Ingredient>(
                                direction: VerticalDirection.up,
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      labelText: "Add More Ingredients",
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                  );
                                },
                                suggestionsCallback: (pattern) {
                                  if (pattern.isEmpty) {
                                    return ingredientOptions;
                                  }

                                  return ingredientOptions
                                      .where(
                                        (ing) => ing.name
                                            .toLowerCase()
                                            .contains(pattern.toLowerCase()),
                                      )
                                      .toList();
                                },
                                itemBuilder: (context, suggestion) {
                                  return ListTile(
                                    title: Text(suggestion.name),
                                    subtitle: Text('Unit: ${suggestion.unit}'),
                                  );
                                },

                                onSelected: (suggestion) {
                                  print(suggestion.copyWith(quantity: 1));
                                  setState(() {
                                    ingredientInputs ??= [];
                                    if (!ingredientInputs!.any(
                                      (i) => i.ingredient.id == suggestion.id,
                                    )) {
                                      ingredientInputs!.add(
                                        IngredientInput(
                                          ingredient: suggestion.copyWith(
                                            quantity: 1,
                                          ),
                                        ),
                                      );
                                    }
                                    _focusNode.unfocus();
                                  });
                                },
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: SizedBox()),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.lightBlue[200],
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        List<Ingredient> updatedIngredients =
                                            List.generate(
                                              ingredientInputs?.length ?? 0,
                                              (index) {
                                                final parsedQuantity =
                                                    double.tryParse(
                                                      ingredientInputs![index]
                                                          .controller
                                                          .text,
                                                    ) ??
                                                    0;
                                                return Ingredient(
                                                  id:
                                                      ingredientInputs![index]
                                                          .ingredient
                                                          .id,
                                                  name:
                                                      ingredientInputs![index]
                                                          .ingredient
                                                          .name,
                                                  unit:
                                                      ingredientInputs![index]
                                                          .ingredient
                                                          .unit,
                                                  quantity: parsedQuantity,
                                                  imageUrl:
                                                      ingredientInputs![index]
                                                          .ingredient
                                                          .imageUrl,
                                                );
                                              },
                                            );
                                        final newRecipe = FormRecipe(
                                          id: selectedRecipe?.id,
                                          name: nameController.text,
                                          imageUrl: selectedRecipe?.imageUrl,
                                          ingredients: updatedIngredients,
                                        );
                                        Navigator.of(context).pop(newRecipe);
                                      }
                                    },
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );

    if (result != null && mounted) {
      if (recipe == null) {
        await context.read<RecipesProvider>().createRecipe(result);
      } else {
        await context.read<RecipesProvider>().updateRecipe(result);
      }
    }
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
          return ListTile(
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
                      child: const Icon(Icons.image_not_supported, size: 25),
                    ),
            title: Text(recipe.name),
            onTap: () => _showRecipeDetail(recipe),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecipeDetail(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }
}
