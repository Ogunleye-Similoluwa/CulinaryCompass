import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';
import '../model/meal_plan_model.dart';
import '../../riverpod/meal_plan_provider.dart';
import 'widget/add_meal_dialog.dart';
import 'package:intl/intl.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  DateTime _selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final mealPlan = ref.watch(mealPlanProvider);
    final weeklyCalories = ref.watch(weeklyCaloriesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal Planner'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Daily Plan'),
              Tab(text: 'Weekly Overview'),
              Tab(text: 'Shopping List'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDailyPlanTab(mealPlan),
            _buildWeeklyOverviewTab(weeklyCalories),
            _buildShoppingListTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddMealDialog(context),
          label: const Text('Add Meal'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildDailyPlanTab(MealPlan? mealPlan) {
    if (mealPlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No meal plan created yet'),
            ElevatedButton(
              onPressed: () => _createNewPlan(),
              child: const Text('Create New Plan'),
            ),
          ],
        ),
      );
    }

    final dayPlan = mealPlan.days[_selectedDate];
    
    return Column(
      children: [
        _buildDateSelector(),
        if (dayPlan != null) ...[
          _buildCalorieProgress(dayPlan),
          Expanded(
            child: ListView.builder(
              itemCount: MealType.values.length,
              itemBuilder: (context, index) {
                final mealType = MealType.values[index];
                final meals = dayPlan.meals[mealType] ?? [];
                return _buildMealTypeSection(mealType, meals);
              },
            ),
          ),
        ] else
          const Center(child: Text('No meals planned for this day')),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(DateFormat('EEEE, MMMM d').format(_selectedDate)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });
              },
            ),
          ],
        ),
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime.now().subtract(const Duration(days: 365)),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            setState(() => _selectedDate = date);
          }
        },
      ),
    );
  }

  Widget _buildCalorieProgress(DayPlan dayPlan) {
    final progress = dayPlan.totalCalories / dayPlan.targetCalories;
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${dayPlan.totalCalories} / ${dayPlan.targetCalories} cal',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              color: _getProgressColor(progress),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.9) return Colors.orange;
    if (progress > 1.1) return Colors.red;
    return Colors.green;
  }

  Widget _buildMealTypeSection(MealType type, List<Recipe> meals) {
    return ExpansionTile(
      leading: Text(type.emoji, style: const TextStyle(fontSize: 24)),
      title: Text(type.label),
      subtitle: Text('${meals.length} meals planned'),
      children: [
        ...meals.map((meal) => _buildMealTile(meal)),
        ListTile(
          leading: const Icon(Icons.add_circle_outline),
          title: const Text('Add meal'),
          onTap: () => _showAddMealDialog(context, mealType: type),
        ),
      ],
    );
  }

  Widget _buildMealTile(Recipe recipe) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(recipe.imageUrl),
      ),
      title: Text(recipe.title),
      subtitle: Text('${recipe.calories} calories'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          // TODO: Implement meal removal
        },
      ),
    );
  }

  void _createNewPlan() {
    // TODO: Show dialog to configure new plan
  }

  void _showAddMealDialog(BuildContext context, {MealType? mealType}) {
    showDialog(
      context: context,
      builder: (context) => AddMealDialog(
        selectedDate: _selectedDate,
        initialMealType: mealType,
      ),
    );
  }

  Widget _buildWeeklyOverviewTab(Map<DateTime, int> weeklyCalories) {
    return ListView.builder(
      itemCount: weeklyCalories.length,
      itemBuilder: (context, index) {
        final date = weeklyCalories.keys.elementAt(index);
        final calories = weeklyCalories[date];
        return ListTile(
          title: Text(date.toString().split(' ')[0]),
          trailing: Text('$calories calories'),
        );
      },
    );
  }

  Widget _buildShoppingListTab() {
    final shoppingList = ref.watch(shoppingListProvider);
    return ListView.builder(
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        final item = shoppingList[index];
        return CheckboxListTile(
          title: Text(item.ingredient),
          subtitle: Text('Quantity: ${item.quantity}'),
          value: item.isPurchased,
          onChanged: (value) {
            ref.read(shoppingListProvider.notifier).togglePurchased(index);
          },
        );
      },
    );
  }
}

class _WeeklyPlanTab extends StatelessWidget {
  final MealPlan? mealPlan;

  const _WeeklyPlanTab({required this.mealPlan});

  @override
  Widget build(BuildContext context) {
    if (mealPlan == null) {
      return const Center(child: Text('No meal plan created yet'));
    }
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        final date = mealPlan!.startDate.add(Duration(days: index));
        final dayPlan = mealPlan!.days[date];
        return Card(
          child: ListTile(
            title: Text(date.toString().split(' ')[0]),
            subtitle: Text('${dayPlan?.meals.length ?? 0} meals planned'),
          ),
        );
      },
    );
  }
}

class _ShoppingListTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingList = ref.watch(shoppingListProvider);
    return ListView.builder(
      itemCount: shoppingList.length,
      itemBuilder: (context, index) {
        final item = shoppingList[index];
        return CheckboxListTile(
          title: Text(item.ingredient),
          subtitle: Text('Quantity: ${item.quantity}'),
          value: item.isPurchased,
            onChanged: (value) {
            ref.read(shoppingListProvider.notifier).togglePurchased(index);
          },
        );
      },
    );
  }
}

class _CaloriesTab extends StatelessWidget {
  final Map<DateTime, int> weeklyCalories;

  const _CaloriesTab({required this.weeklyCalories});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: weeklyCalories.length,
      itemBuilder: (context, index) {
        final date = weeklyCalories.keys.elementAt(index);
        final calories = weeklyCalories[date];
        return ListTile(
          title: Text(date.toString().split(' ')[0]),
          trailing: Text('$calories calories'),
        );
      },
    );
  }
} 