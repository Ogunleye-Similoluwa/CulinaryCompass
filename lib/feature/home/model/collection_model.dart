import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';

class RecipeCollection {
  final String id;
  final String name;
  final String description;
  final List<Recipe> recipes;
  final DateTime createdAt;
  final bool isShared;

  RecipeCollection({
    required this.id,
    required this.name,
    this.description = '',
    this.recipes = const [],
    DateTime? createdAt,
    this.isShared = false,
  }) : createdAt = createdAt ?? DateTime.now();

  RecipeCollection copyWith({
    String? name,
    String? description,
    List<Recipe>? recipes,
    bool? isShared,
  }) {
    return RecipeCollection(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      recipes: recipes ?? this.recipes,
      createdAt: createdAt,
      isShared: isShared ?? this.isShared,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'recipes': recipes.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isShared': isShared,
    };
  }

  factory RecipeCollection.fromJson(Map<String, dynamic> json) {
    return RecipeCollection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      recipes: (json['recipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isShared: json['isShared'],
    );
  }
} 