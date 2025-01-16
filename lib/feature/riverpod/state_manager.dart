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

// Add a class to handle search state
class SearchState {
  final List<Recipe> recipes;
  final bool isLoading;
  final int page;
  final bool hasMore;

  SearchState({
    required this.recipes,
    this.isLoading = false,
    this.page = 1,
    this.hasMore = true,
  });

  SearchState copyWith({
    List<Recipe>? recipes,
    bool? isLoading,
    int? page,
    bool? hasMore,
  }) {
    return SearchState(
      recipes: recipes ?? this.recipes,
      isLoading: isLoading ?? this.isLoading,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Create a notifier for search state
class SearchNotifier extends StateNotifier<SearchState> {
  final RecipeService _recipeService;
  String _lastQuery = '';

  SearchNotifier(this._recipeService) : super(SearchState(recipes: []));

  Future<void> search(String query) async {
    if (query != _lastQuery) {
      state = SearchState(recipes: [], isLoading: true);
      _lastQuery = query;
    } else {
      if (state.isLoading || !state.hasMore) return; // Prevent duplicate requests
      state = state.copyWith(isLoading: true);
    }

    try {
      final newRecipes = await _recipeService.searchRecipes(query, page: state.page);
      state = state.copyWith(
        recipes: state.page == 1 ? newRecipes : [...state.recipes, ...newRecipes],
        isLoading: false,
        hasMore: newRecipes.isNotEmpty,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, hasMore: false);
    }
  }
}

// Update the provider
final searchStateProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref.watch(recipeServiceProvider));
});