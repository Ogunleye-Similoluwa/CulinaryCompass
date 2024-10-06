// lib/models/recipe.dart
import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String title;
  final String imageUrl;
  final int readyInMinutes;
  final int servings;
  final List<String> diets;
  final bool isFavorite;
  final List<String> ingredients;
  final String instructions;
  final double rating;
  final int calories;

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.readyInMinutes,
    required this.servings,
    this.diets = const [],
    this.isFavorite = false,
    this.ingredients = const [],
    this.instructions = '',
    this.rating = 0.0,
    this.calories = 0,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      title: json['title'],
      imageUrl: json['image'],
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      diets: List<String>.from(json['diets'] ?? []),
      ingredients: List<String>.from(json['extendedIngredients']?.map((i) => i['original']) ?? []),
      instructions: json['instructions'] ?? '',
      rating: (json['spoonacularScore'] ?? 0.0) / 20, 
      calories: json['nutrition']?['nutrients']?.firstWhere(
            (n) => n['name'] == 'Calories',
        orElse: () => {'amount': 0},
      )['amount']?.round() ?? 0,
    );
  }

  Recipe copyWith({
    bool? isFavorite,
  }) {
    return Recipe(
      id: id,
      title: title,
      imageUrl: imageUrl,
      readyInMinutes: readyInMinutes,
      servings: servings,
      diets: diets,
      isFavorite: isFavorite ?? this.isFavorite,
      ingredients: ingredients,
      instructions: instructions,
      rating: rating,
      calories: calories,
    );
  }

  @override
  List<Object?> get props => [id, title, imageUrl, readyInMinutes, servings, diets, isFavorite, ingredients, instructions, rating, calories];
}