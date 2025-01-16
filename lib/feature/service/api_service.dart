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

  Future<List<Recipe>> searchRecipes(String query, {int page = 1}) async {
    try {
      List<Recipe> allResults = [];
      final offset = (page - 1) * 5;
      
      // Search from Spoonacular with pagination
      try {
        final spoonacularResponse = await http.get(
          Uri.parse('$_baseUrl/complexSearch?query=$query&number=5&offset=$offset&addRecipeInformation=true&apiKey=$_apiKey'),
        );
        if (spoonacularResponse.statusCode == 200) {
          final data = json.decode(spoonacularResponse.body);
          final spoonacularResults = (data['results'] as List)
              .map((recipe) => Recipe.fromJson(recipe))
              .toList();
          allResults.addAll(spoonacularResults);
        }
      } catch (e) {
        print('Spoonacular search error: $e');
      }

      // Search from TheMealDB (take different slice based on page)
      try {
        final mealDbResponse = await http.get(
          Uri.parse('$_mealDbUrl/search.php?s=$query'),
        );
        if (mealDbResponse.statusCode == 200) {
          final data = json.decode(mealDbResponse.body);
          final meals = data['meals'] as List?;
          if (meals != null) {
            final startIndex = (page - 1) * 5;
            final endIndex = startIndex + 5;
            final pageSlice = meals.skip(startIndex).take(5).toList();
            
            final mealDbResults = await Future.wait(
              pageSlice.map((meal) async {
                final detailedRecipe = await getMealDetails(meal['idMeal']);
                return detailedRecipe;
              }).whereType<Future<Recipe?>>(),
            );
            allResults.addAll(mealDbResults.whereType<Recipe>());
          }
        }
      } catch (e) {
        print('MealDB search error: $e');
      }

      // Get similar recipes if we have any results
      if (allResults.isNotEmpty && allResults.first.id.isNotEmpty) {
        try {
          final similarResponse = await http.get(
            Uri.parse('$_baseUrl/${allResults.first.id}/similar?apiKey=$_apiKey&number=3'),
          );
          if (similarResponse.statusCode == 200) {
            final List<dynamic> similarData = json.decode(similarResponse.body);
            for (var recipe in similarData) {
              try {
                final detailedRecipe = await getRecipeDetails(recipe['id'].toString());
                allResults.add(detailedRecipe);
              } catch (e) {
                print('Error getting detailed recipe: $e');
              }
            }
          }
        } catch (e) {
          print('Similar recipes error: $e');
        }
      }

      // If still no results, try getting some random recipes from the category
      if (allResults.isEmpty) {
        try {
          final categoryResults = await getRecipesByCategory(query);
          allResults.addAll(categoryResults.take(5));
        } catch (e) {
          print('Category search error: $e');
        }
      }

      return allResults;
    } catch (e) {
      print('Search error: $e');
      return [];
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