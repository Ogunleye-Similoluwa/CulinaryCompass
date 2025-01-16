// lib/services/recipe_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../home/model/recipe_model.dart';

class RecipeService {
  static const String _baseUrl = 'https://api.spoonacular.com/recipes';
  static final String? _apiKey = dotenv.env['API_KEY'];

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
    final response = await http.get(
      Uri.parse('$_baseUrl/complexSearch?type=$category&number=10&addRecipeInformation=true&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } else {
      throw Exception('Failed to load $category recipes');
    }
  }

  Future<List<Recipe>> getPopularRecipes() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/complexSearch?sort=popularity&number=10&addRecipeInformation=true&apiKey=$_apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
          .toList();
    } else {
      throw Exception('Failed to load popular recipes');
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
}