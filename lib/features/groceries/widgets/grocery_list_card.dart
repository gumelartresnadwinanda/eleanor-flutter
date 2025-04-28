import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grocery_list.dart';
import '../providers/grocery_list_provider.dart';

class GroceryListCard extends StatefulWidget {
  const GroceryListCard({super.key});

  @override
  State<GroceryListCard> createState() => _GroceryListCardState();
}

class _GroceryListCardState extends State<GroceryListCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GroceryListProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final groceryList = provider.groceryList;
        if (groceryList == null) {
          return const Center(child: Text('No grocery list available'));
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: provider.isRecipeView ? 4 : 8),
                provider.isRecipeView
                    ? _buildRecipeList(groceryList, provider)
                    : _buildIngredientList(groceryList, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecipeList(
    GroceryList groceryList,
    GroceryListProvider provider,
  ) {
    if (groceryList.recipes.isEmpty) {
      return const Center(child: Text('No recipes in the grocery list'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...groceryList.recipes.map((recipe) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  recipe.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...recipe.ingredients.map((ingredient) {
                final key =
                    '${recipe.name}_${ingredient.name}_${ingredient.unit}';
                final isChecked = provider.checkedItems[key] ?? false;
                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      provider.toggleItemChecked(key, value ?? false);
                    },
                  ),
                  title: Text(
                    ingredient.name,
                    style: TextStyle(
                      fontSize: 14,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    '${(ingredient.quantity! % 1 == 0 ? ingredient.quantity!.toInt() : ingredient.quantity!.toStringAsFixed(2))} ${ingredient.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onTap: () {
                    provider.toggleItemChecked(key, !isChecked);
                  },
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildIngredientList(
    GroceryList groceryList,
    GroceryListProvider provider,
  ) {
    if (groceryList.ingredients.isEmpty) {
      return const Center(child: Text('No ingredients in the grocery list'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          groceryList.ingredients.map((ingredient) {
            final key = '${ingredient.name}_${ingredient.unit}';
            final isChecked = provider.checkedItems[key] ?? false;

            return ListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  provider.toggleItemChecked(key, value ?? false);
                },
              ),
              title: Text(
                ingredient.name,
                style: TextStyle(
                  fontSize: 14,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${ingredient.quantity} ${ingredient.unit}',
                style: TextStyle(
                  fontSize: 12,
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                ),
              ),
              onTap: () {
                provider.toggleItemChecked(key, !isChecked);
              },
            );
          }).toList(),
    );
  }
}
