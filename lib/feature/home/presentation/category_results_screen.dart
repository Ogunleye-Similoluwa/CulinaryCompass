import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/receipe_grid.dart';
import 'package:food_reciepe_finder/feature/riverpod/state_manager.dart';


class CategoryResultsScreen extends ConsumerWidget {
  final String title;
  final String category;
  final bool isMealType;

  const CategoryResultsScreen({
    Key? key,
    required this.title,
    required this.category,
    this.isMealType = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = isMealType 
        ? ref.watch(mealTypeRecipesProvider(category))
        : ref.watch(categoryRecipesProvider(category));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: RecipeGrid(provider: provider),
          ),
        ],
      ),
    );
  }
} 