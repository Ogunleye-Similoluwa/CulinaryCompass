import 'recipe_model.dart';

enum MealType {
  breakfast('Breakfast', '🌅'),
  lunch('Lunch', '🌞'),
  dinner('Dinner', '🌙'),
  snack('Snack', '🍎');

  final String label;
  final String emoji;
  const MealType(this.label, this.emoji);
}

class MealPlan {
  final String id;
  final DateTime startDate;
  final Map<DateTime, DayPlan> days;
  final String name;
  final int targetCalories;

  MealPlan({
    required this.id,
    required this.startDate,
    required this.days,
    this.name = 'My Meal Plan',
    this.targetCalories = 2000,
  });

  int get totalCalories => days.values
      .expand((day) => day.meals.values)
      .fold(0, (sum, meals) => sum + meals.fold(0, (sum, meal) => sum + meal.calories));

  bool isDateWithinPlan(DateTime date) {
    final endDate = startDate.add(Duration(days: days.length));
    return date.isAfter(startDate.subtract(const Duration(days: 1))) && 
           date.isBefore(endDate.add(const Duration(days: 1)));
  }

  List<ShoppingListItem> generateShoppingList() {
    final ingredients = <String, int>{};
    
    for (final day in days.values) {
      for (final mealList in day.meals.values) {
        for (final meal in mealList) {
          for (final ingredient in meal.ingredients) {
            ingredients.update(
              ingredient,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }
      }
    }

    return ingredients.entries
        .map((e) => ShoppingListItem(
              ingredient: e.key,
              quantity: e.value,
            ))
        .toList();
  }
}

class DayPlan {
  final Map<MealType, List<Recipe>> meals;
  final int targetCalories;
  bool isCompleted;

  DayPlan({
    required this.meals,
    this.targetCalories = 2000,
    this.isCompleted = false,
  });

  int get totalCalories => meals.values
      .expand((meals) => meals)
      .fold(0, (sum, meal) => sum + meal.calories);

  bool get isOnTarget => 
      (totalCalories >= targetCalories * 0.9) && 
      (totalCalories <= targetCalories * 1.1);
}

class ShoppingListItem {
  final String ingredient;
  final int quantity;
  bool isPurchased;

  ShoppingListItem({
    required this.ingredient,
    this.quantity = 1,
    this.isPurchased = false,
  });
} 