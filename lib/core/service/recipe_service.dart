import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecipeService {
  final _client = http.Client();
  static const _mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      // Try MealDB first
      final recipes = await _searchMealDB(query);
      if (recipes.isNotEmpty) return recipes;

      // Fallback to local cache if network fails
      return _getLocalRecipes(query);
    } catch (e) {
      print('Search error: $e');
      // Return empty list instead of throwing
      return [];
    }
  }

  Future<List<Recipe>> _searchMealDB(String query) async {
    try {
      final response = await _client
          .get(Uri.parse('$_mealDbBaseUrl/search.php?s=${Uri.encodeComponent(query)}'))
          .timeout(const Duration(seconds: 5)); // Add timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        
        if (meals != null) {
          return meals
              .map((json) => Recipe.fromMealDB(json))
              .where((recipe) => recipe.title.isNotEmpty)
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('MealDB search error: $e');
      return [];
    }
  }

  Future<List<Recipe>> _getLocalRecipes(String query) async {
    // Implement local search from cached recipes
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_recipes');
    if (cached != null) {
      final List<dynamic> recipes = jsonDecode(cached);
      return recipes
          .map((json) => Recipe.fromJson(json))
          .where((recipe) => 
              recipe.title.toLowerCase().contains(query.toLowerCase()) ||
              recipe.ingredients.any((i) => 
                  i.toLowerCase().contains(query.toLowerCase())))
          .toList();
    }
    return [];
  }

  Future<Recipe?> getRecipeDetails(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$_mealDbBaseUrl/lookup.php?i=$id'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        if (meals?.isNotEmpty ?? false) {
          return Recipe.fromMealDB(meals!.first);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching recipe details: $e');
      return _getLocalRecipeDetails(id);
    }
  }

  Future<Recipe?> _getLocalRecipeDetails(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('cached_recipes');
    if (cached != null) {
      final List<dynamic> recipes = jsonDecode(cached);
      final recipeJson = recipes.firstWhere(
        (json) => json['id'].toString() == id,
        orElse: () => null,
      );
      if (recipeJson != null) {
        return Recipe.fromJson(recipeJson);
      }
    }
    return null;
  }
} 