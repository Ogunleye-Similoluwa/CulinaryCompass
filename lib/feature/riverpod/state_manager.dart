// lib/providers/recipe_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/model/recipe_model.dart';
import '../service/api_service.dart';


final recipeServiceProvider = Provider((ref) => RecipeService());

final randomRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final recipeService = ref.read(recipeServiceProvider);
  return recipeService.getRandomRecipes();
});

final searchRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, query) async {
  final recipeService = ref.read(recipeServiceProvider);
  return recipeService.searchRecipes(query);
});

final favoriteRecipesProvider = StateNotifierProvider<FavoriteRecipesNotifier, List<Recipe>>((ref) {
  return FavoriteRecipesNotifier();
});

final categoryRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, category) async {
  final recipeService = RecipeService();
  return recipeService.getRecipesByCategory(category);
});

final popularRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final recipeService = RecipeService();
  return recipeService.getPopularRecipes();
});

final mealTypeRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, mealType) async {
  final recipeService = RecipeService();
  return recipeService.getRecipesByCategory(mealType.toLowerCase());
});

class FavoriteRecipesNotifier extends StateNotifier<List<Recipe>> {
  FavoriteRecipesNotifier() : super([]);

  void toggleFavorite(Recipe recipe) {
    final index = state.indexWhere((r) => r.id == recipe.id);
    if (index >= 0) {
      state = state.where((r) => r.id != recipe.id).toList();
    } else {
      state = [...state, recipe.copyWith(isFavorite: true)];
    }
  }

  bool isFavorite(Recipe recipe) {
    return state.any((r) => r.id == recipe.id);
  }
}