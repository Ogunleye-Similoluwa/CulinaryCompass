import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/recipe_item.dart';

import '../../../riverpod/state_manager.dart';
import '../../model/recipe_model.dart';


class RecipeGrid extends ConsumerWidget {
  final FutureProvider<List<Recipe>> provider;

  const RecipeGrid({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(provider);

    return recipesAsync.when(
      data: (recipes) => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final recipe = recipes[index];
            return RecipeCard(
              recipe: recipe,
              onFavoritePressed: () {
                ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
              },
            );
          },
          childCount: recipes.length,
        ),
      ),
      loading: () => SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(child: Text('Error loading recipes')),
      ),
    );
  }
}