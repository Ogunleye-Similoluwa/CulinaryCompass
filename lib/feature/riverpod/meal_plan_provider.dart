import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';
import '../home/model/meal_plan_model.dart';

class MealPlanNotifier extends StateNotifier<MealPlan?> {
  MealPlanNotifier() : super(null);

  void createWeeklyPlan(DateTime startDate) {
    state = MealPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
      days: {},
    );
  }

  void addMealToDay(DateTime date, Recipe recipe, MealType type) {
    if (state == null) return;

    final currentDays = Map<DateTime, DayPlan>.from(state!.days);
    final dayPlan = currentDays[date] ?? DayPlan(meals: {});
    final meals = Map<MealType, List<Recipe>>.from(dayPlan.meals);
    
    meals[type] = [...(meals[type] ?? []), recipe];
    currentDays[date] = DayPlan(meals: meals);

    state = MealPlan(
      id: state!.id,
      startDate: state!.startDate,
      days: currentDays,
    );
  }

  void removeMealFromDay(DateTime date, Recipe recipe, MealType type) {
    if (state == null) return;

    final currentDays = Map<DateTime, DayPlan>.from(state!.days);
    final dayPlan = currentDays[date];
    if (dayPlan != null) {
      final meals = Map<MealType, List<Recipe>>.from(dayPlan.meals);
      meals[type] = meals[type]?.where((meal) => meal.id != recipe.id).toList() ?? [];
      currentDays[date] = DayPlan(meals: meals);

      state = MealPlan(
        id: state!.id,
        startDate: state!.startDate,
        days: currentDays,
      );
    }
  }

  void toggleMealCompletion(DateTime date, MealType type, Recipe recipe) {
    if (state == null) return;

    final currentDays = Map<DateTime, DayPlan>.from(state!.days);
    final dayPlan = currentDays[date];
    if (dayPlan != null) {
      currentDays[date] = DayPlan(
        meals: dayPlan.meals,
        isCompleted: !dayPlan.isCompleted,
      );

      state = MealPlan(
        id: state!.id,
        startDate: state!.startDate,
        days: currentDays,
      );
    }
  }

  List<ShoppingListItem> generateShoppingList() {
    return state?.generateShoppingList() ?? [];
  }
}

final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan?>((ref) {
  return MealPlanNotifier();
});

class ShoppingListNotifier extends StateNotifier<List<ShoppingListItem>> {
  ShoppingListNotifier() : super([]);

  void togglePurchased(int index) {
    state = [
      for (var i = 0; i < state.length; i++)
        if (i == index)
          ShoppingListItem(
            ingredient: state[i].ingredient,
            quantity: state[i].quantity,
            isPurchased: !state[i].isPurchased,
          )
        else
          state[i],
    ];
  }
}

final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, List<ShoppingListItem>>((ref) {
  return ShoppingListNotifier();
});

final weeklyCaloriesProvider = Provider<Map<DateTime, int>>((ref) {
  final mealPlan = ref.watch(mealPlanProvider);
  if (mealPlan == null) return {};

  final weeklyCalories = <DateTime, int>{};
  mealPlan.days.forEach((date, dayPlan) {
    weeklyCalories[date] = dayPlan.totalCalories;
  });
  return weeklyCalories;
}); 