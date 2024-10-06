import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/recipe_item.dart';

import '../../riverpod/state_manager.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteRecipes = ref.watch(favoriteRecipesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Recipes'),
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
        child: Text('No favorite recipes yet.'),
      )
          : ListView.builder(
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];
          return RecipeCard(
            recipe: recipe,
            onFavoritePressed: () {
              ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
            },
          );
        },
      ),
    );
  }
}