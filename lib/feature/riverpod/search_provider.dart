import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/riverpod/collections_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/model/recipe_model.dart';
import '../home/model/search_filter_model.dart';
import 'dart:convert';

class SearchState {
  final List<Recipe> results;
  final bool isLoading;
  final String? error;
  final SearchFilters filters;

  SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
    this.filters = const SearchFilters(),
  });

  SearchState copyWith({
    List<Recipe>? results,
    bool? isLoading,
    String? error,
    SearchFilters? filters,
  }) {
    return SearchState(
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SharedPreferences _prefs;
  static const _offlineKey = 'offline_recipes';

  SearchNotifier(this._prefs) : super(SearchState());

  Future<void> searchRecipes(SearchFilters filters) async {
    state = state.copyWith(isLoading: true, filters: filters);

    try {
      List<Recipe> results = [];

      if (filters.onlyOfflineRecipes) {
        results = await _searchOfflineRecipes(filters);
      } else {
        results = await _searchOnlineRecipes(filters);
        if (results.isEmpty) {
          // If online search fails, try offline
          results = await _searchOfflineRecipes(filters);
        }
      }

      state = state.copyWith(
        results: results,
        isLoading: false,
        error: results.isEmpty ? 'No recipes found' : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to search recipes. Please try again later.',
      );
    }
  }

  Future<List<Recipe>> _searchOfflineRecipes(SearchFilters filters) async {
    final String? cached = _prefs.getString(_offlineKey);
    if (cached == null) return [];

    final List<Recipe> allRecipes = (jsonDecode(cached) as List)
        .map((json) => Recipe.fromJson(json))
        .toList();

    return _applyFilters(allRecipes, filters);
  }

  Future<List<Recipe>> _searchOnlineRecipes(SearchFilters filters) async {
    // TODO: Implement API call with filters
    // This is where you'd make the API call with the filters
    return [];
  }

  List<Recipe> _applyFilters(List<Recipe> recipes, SearchFilters filters) {
    return recipes.where((recipe) {
      // Filter by cooking time
      if (filters.maxCookingTime != null &&
          recipe.readyInMinutes > filters.maxCookingTime!) {
        return false;
      }

      // Filter by ingredients
      if (filters.ingredients.isNotEmpty) {
        final recipeIngredients = recipe.ingredients
            .map((i) => i.toLowerCase())
            .toList();
        if (!filters.ingredients.every(
            (i) => recipeIngredients.any((ri) => ri.contains(i.toLowerCase())))) {
          return false;
        }
      }

      // Filter by cuisine type
      if (filters.cuisineType != null &&
          recipe.area?.toLowerCase() != filters.cuisineType?.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();
  }

  Future<void> _cacheRecipes(List<Recipe> recipes) async {
    final existing = await _searchOfflineRecipes(const SearchFilters());
    final allRecipes = {...existing, ...recipes}.toList();
    final encoded = jsonEncode(allRecipes.map((r) => r.toJson()).toList());
    await _prefs.setString(_offlineKey, encoded);
  }

  Future<void> saveRecipeOffline(Recipe recipe) async {
    final recipes = await _searchOfflineRecipes(const SearchFilters());
    if (!recipes.any((r) => r.id == recipe.id)) {
      recipes.add(recipe);
      final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
      await _prefs.setString(_offlineKey, encoded);
    }
  }

  Future<void> removeRecipeOffline(String recipeId) async {
    final recipes = await _searchOfflineRecipes(const SearchFilters());
    recipes.removeWhere((r) => r.id == recipeId);
    final encoded = jsonEncode(recipes.map((r) => r.toJson()).toList());
    await _prefs.setString(_offlineKey, encoded);
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SearchNotifier(prefs);
});

final searchResultsProvider = Provider<List<Recipe>>((ref) {
  return ref.watch(searchProvider).results;
}); 