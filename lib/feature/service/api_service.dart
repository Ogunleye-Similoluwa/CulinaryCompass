// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../home/model/recipe_model.dart';

class RecipeService {
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';
  static final String? _apiKey = dotenv.env['API_KEY'];

  // TheMealDB API (free, no auth needed)
  static const String _mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> getRandomRecipes({int number = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/random?number=$number&apiKey=$_apiKey'),
    );
print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['recipes'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/complexSearch?query=$query&number=10&addRecipeInformation=true&apiKey=$_apiKey'),
    );
    print(response.body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  Future<Recipe> getRecipeDetails(String id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$id/information?apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      return Recipe.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_mealDbUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        if (meals == null) return [];
        
        // Fetch full details for each recipe
        List<Recipe> recipes = [];
        for (var meal in meals.take(10)) {
          final detailedRecipe = await getMealDetails(meal['idMeal']);
          if (detailedRecipe != null) {
            recipes.add(detailedRecipe);
          }
        }
        return recipes;
      } else {
        throw Exception('Failed to load $category recipes');
      }
    } catch (e) {
      print('Error in getRecipesByCategory: $e');
      return [];
    }
  }

  Future<Recipe?> getMealDetails(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_mealDbUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        if (meals == null || meals.isEmpty) return null;
        return Recipe.fromMealDB(meals.first);
      }
    } catch (e) {
      print('Error fetching meal details: $e');
    }
    return null;
  }

  Future<List<Recipe>> getPopularRecipes() async {
    try {
      List<Recipe> recipes = [];
      // Fetch multiple recipes by making multiple calls
      for (int i = 0; i < 10; i++) {
        final response = await http.get(
          Uri.parse('$_mealDbUrl/random.php'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final meals = data['meals'] as List?;
          if (meals != null && meals.isNotEmpty) {
            final detailedRecipe = await getMealDetails(meals.first['idMeal']);
            if (detailedRecipe != null) {
              recipes.add(detailedRecipe);
            }
          }
        }
      }
      return recipes;
    } catch (e) {
      print('Error in getPopularRecipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getSimilarRecipes(String recipeId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$recipeId/similar?apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load similar recipes');
    }
  }

  Future<List<Recipe>> getMealTypeRecipes(String mealType) async {
    try {
      final response = await http.get(
        Uri.parse('$_mealDbUrl/filter.php?c=$mealType'),
      );
      print('MealType Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final meals = data['meals'] as List?;
        if (meals == null) return [];
        return meals.take(10).map((meal) => Recipe.fromMealDB(meal)).toList();
      } else {
        throw Exception('Failed to load $mealType recipes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMealTypeRecipes: $e');
      return [];
    }
  }
}