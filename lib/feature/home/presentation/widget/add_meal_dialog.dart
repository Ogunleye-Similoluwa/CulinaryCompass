import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../model/meal_plan_model.dart';
import '../../../riverpod/meal_plan_provider.dart';

class AddMealDialog extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final MealType? initialMealType;

  const AddMealDialog({
    Key? key, 
    required this.selectedDate,
    this.initialMealType,
  }) : super(key: key);

  @override
  ConsumerState<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends ConsumerState<AddMealDialog> {
  late DateTime selectedDate;
  late MealType selectedType;
  int servings = 1;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
    selectedType = widget.initialMealType ?? MealType.breakfast;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Meal'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() => selectedDate = date);
              }
            },
          ),
          DropdownButtonFormField<MealType>(
            value: selectedType,
            items: MealType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedType = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Meal Type'),
          ),
          Row(
            children: [
              const Text('Servings:'),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  if (servings > 1) {
                    setState(() => servings--);
                  }
                },
              ),
              Text('$servings'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() => servings++);
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // TODO: Add meal to plan
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
} 