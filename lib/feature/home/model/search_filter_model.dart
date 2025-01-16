enum DifficultyLevel {
  easy('Easy', '🟢'),
  medium('Medium', '🟡'),
  hard('Hard', '🔴');

  final String label;
  final String emoji;
  const DifficultyLevel(this.label, this.emoji);
}

class SearchFilters {
  final List<String> ingredients;
  final int? maxCookingTime;
  final DifficultyLevel? difficulty;
  final String? cuisineType;
  final bool onlyOfflineRecipes;

  const SearchFilters({
    this.ingredients = const [],
    this.maxCookingTime,
    this.difficulty,
    this.cuisineType,
    this.onlyOfflineRecipes = false,
  });

  SearchFilters copyWith({
    List<String>? ingredients,
    int? maxCookingTime,
    DifficultyLevel? difficulty,
    String? cuisineType,
    bool? onlyOfflineRecipes,
  }) {
    return SearchFilters(
      ingredients: ingredients ?? this.ingredients,
      maxCookingTime: maxCookingTime ?? this.maxCookingTime,
      difficulty: difficulty ?? this.difficulty,
      cuisineType: cuisineType ?? this.cuisineType,
      onlyOfflineRecipes: onlyOfflineRecipes ?? this.onlyOfflineRecipes,
    );
  }
} 