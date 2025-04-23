import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:eleanor/core/widgets/image_preview.dart';
import 'package:eleanor/features/groceries/providers/grocery_list_provider.dart';
import 'package:eleanor/features/groceries/providers/meal_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealPlanDetailScreen extends StatefulWidget {
  final int id;
  const MealPlanDetailScreen({super.key, required this.id});

  @override
  State<MealPlanDetailScreen> createState() => _MealPlanDetailScreenState();
}

class _MealPlanDetailScreenState extends State<MealPlanDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanProvider>().fetchMealPlanDetails(widget.id);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MealPlanProvider>(context);
    final groceryProvider = Provider.of<GroceryListProvider>(context);

    final title = provider.selectedMealPlan?.title;
    Widget body;
    if (provider.isLoading || provider.selectedMealPlan == null) {
      body = _buildLoadingView();
    } else if (provider.error != null) {
      body = _buildErrorView(provider);
    } else {
      body = _buildMenuDetail(provider, groceryProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? "Detail Menu"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.edit))],
      ),
      body: body,
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildLoadingView() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorView(MealPlanProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: ${provider.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.fetchMealPlanDetails(widget.id),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuDetail(
    MealPlanProvider provider,
    GroceryListProvider groceryProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverList.builder(
            itemCount: provider.selectedMealPlan!.meals?.length ?? 0,
            itemBuilder: (context, index) {
              final recipe = provider.selectedMealPlan!.meals?[index];
              return (ListTile(
                leading:
                    recipe!.imageUrl != null
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
              ));
            },
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  "Tambahan",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
          SliverList.builder(
            itemCount: provider.selectedMealPlan!.extras?.length ?? 0,
            itemBuilder: (context, index) {
              final extra = provider.selectedMealPlan!.extras?[index];
              return ListTile(
                leading:
                    extra!.imageUrl != null
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
                subtitle: Text("${extra.quantity.toInt()} ${extra.unit}"),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child:
                      groceryProvider.activeMealPlanId != widget.id
                          ? ElevatedButton(
                            onPressed: () {
                              groceryProvider.updateActiveMealPlan(widget.id);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.star),
                                SizedBox(width: 16),
                                Text('Simpan sebagai daftar belanja aktif'),
                              ],
                            ),
                          )
                          : (Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.star),
                              SizedBox(width: 8),
                              Text('Tersimpan sebagai daftar belanja aktif'),
                            ],
                          )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
