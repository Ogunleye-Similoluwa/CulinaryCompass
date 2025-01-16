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
  final String? area;
  final String? category;
  final List<String> tags;
  final String? youtubeUrl;

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
    this.area,
    this.category,
    this.tags = const [],
    this.youtubeUrl,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'].toString(),
      title: json['title'],
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      readyInMinutes: json['readyInMinutes'] ?? 0,
      servings: json['servings'] ?? 1,
      diets: List<String>.from(json['diets'] ?? []),
      ingredients: List<String>.from(
        json['extendedIngredients']?.map((i) => i['original']) ?? 
        json['ingredients'] ?? []
      ),
      instructions: json['instructions'] ?? '',
      rating: (json['spoonacularScore'] ?? 0.0) / 20,
      calories: json['nutrition']?['nutrients']?.firstWhere(
        (n) => n['name'] == 'Calories',
        orElse: () => {'amount': 0},
      )['amount']?.round() ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      area: json['area'],
      category: json['category'],
      tags: List<String>.from(json['tags'] ?? []),
      youtubeUrl: json['youtubeUrl'],
    );
  }

  factory Recipe.fromMealDB(Map<String, dynamic> json) {
    // Extract ingredients and measures
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty && ingredient != " ") {
        ingredients.add('${measure ?? ""} ${ingredient.trim()}'.trim());
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      title: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      readyInMinutes: 30,
      servings: 4,
      diets: [json['strCategory'] ?? ''],
      ingredients: ingredients,
      instructions: json['strInstructions'] ?? '',
      rating: 0.0,
      calories: 0,
      // Add additional fields if available
      area: json['strArea'],
      category: json['strCategory'],
      tags: json['strTags']?.split(',') ?? [],
      youtubeUrl: json['strYoutube'],
    );
  }

  factory Recipe.fromEdamam(Map<String, dynamic> json) {
    try {
      return Recipe(
        id: json['uri']?.toString().split('#').last ?? '',
        title: json['label'] ?? 'Unknown Recipe',
        imageUrl: json['image'] ?? '',
        readyInMinutes: (json['totalTime'] ?? 30).toInt(),
        servings: (json['yield'] ?? 4).toInt(),
        diets: List<String>.from(json['dietLabels'] ?? []),
        ingredients: List<String>.from(json['ingredientLines'] ?? []),
        instructions: json['url'] ?? '',
        rating: 0.0,
        calories: (json['calories'] ?? 0).round(),
      );
    } catch (e) {
      print('Error parsing Edamam recipe: $e');
      return Recipe(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Error Loading Recipe',
        imageUrl: '',
        readyInMinutes: 30,
        servings: 4,
        diets: [],
        ingredients: [],
        instructions: '',
        rating: 0.0,
        calories: 0,
      );
    }
  }

  static List<String> _extractIngredients(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      String? measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('$measure $ingredient'.trim());
      }
    }
    return ingredients;
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
      area: area,
      category: category,
      tags: tags,
      youtubeUrl: youtubeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'ingredients': ingredients,
      'instructions': instructions,
      'readyInMinutes': readyInMinutes,
      'servings': servings,
      'calories': calories,
      'rating': rating,
      'isFavorite': isFavorite,
    };
  }

  @override
  List<Object?> get props => [id, title, imageUrl, readyInMinutes, servings, diets, isFavorite, ingredients, instructions, rating, calories, area, category, tags, youtubeUrl];
}