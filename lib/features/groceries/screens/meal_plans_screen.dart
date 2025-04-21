import 'package:flutter/material.dart';
import 'package:eleanor/core/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/meal_plan.dart';

class GroceriesMealPlansScreen extends StatefulWidget {
  const GroceriesMealPlansScreen({super.key});

  @override
  State<GroceriesMealPlansScreen> createState() =>
      _GroceriesMealPlansScreenState();
}

class _GroceriesMealPlansScreenState extends State<GroceriesMealPlansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealPlanProvider>().fetchMealPlans();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement create meal plan
            },
          ),
        ],
      ),
      body: Consumer<MealPlanProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.fetchMealPlans(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.mealPlans.isEmpty) {
            return const Center(
              child: Text('No meal plans found. Create one to get started!'),
            );
          }

          return ListView.builder(
            itemCount: provider.mealPlans.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final mealPlan = provider.mealPlans[index];
              return _buildMealPlanCard(mealPlan);
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildMealPlanCard(MealPlan mealPlan) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () {
          // TODO: Navigate to meal plan details
        },
        title: Text(
          mealPlan.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Created: ${mealPlan.createdAt.toString().split(' ')[0]}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mealPlan.archived)
              const Icon(Icons.archive, color: Colors.grey),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
