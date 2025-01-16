import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/riverpod/search_provider.dart';
import '../model/search_filter_model.dart';

class AdvancedSearchScreen extends ConsumerStatefulWidget {
  const AdvancedSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final _ingredientController = TextEditingController();
  final List<String> _ingredients = [];
  SearchFilters _filters = const SearchFilters();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _search,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIngredientsSection(),
            const Divider(),
            _buildTimeFilter(),
            const Divider(),
            _buildDifficultyFilter(),
            const Divider(),
            _buildCuisineFilter(),
            const Divider(),
            _buildOfflineToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ingredientController,
                decoration: const InputDecoration(
                  hintText: 'Add ingredient',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addIngredient,
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: _ingredients.map((ingredient) {
            return Chip(
              label: Text(ingredient),
              onDeleted: () => _removeIngredient(ingredient),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cooking Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: _filters.maxCookingTime?.toDouble() ?? 60,
          min: 0,
          max: 180,
          divisions: 18,
          label: '${_filters.maxCookingTime ?? 60} minutes',
          onChanged: (value) {
            setState(() {
              _filters = _filters.copyWith(maxCookingTime: value.round());
            });
          },
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Difficulty Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: DifficultyLevel.values.map((level) {
            return ChoiceChip(
              label: Text('${level.emoji} ${level.label}'),
              selected: _filters.difficulty == level,
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(
                    difficulty: selected ? level : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCuisineFilter() {
    final cuisines = ['Italian', 'Chinese', 'Mexican', 'Indian', 'Japanese', 'Thai'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cuisine Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: cuisines.map((cuisine) {
            return ChoiceChip(
              label: Text(cuisine),
              selected: _filters.cuisineType == cuisine,
              onSelected: (selected) {
                setState(() {
                  _filters = _filters.copyWith(
                    cuisineType: selected ? cuisine : null,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOfflineToggle() {
    return SwitchListTile(
      title: const Text('Show Only Offline Recipes'),
      value: _filters.onlyOfflineRecipes,
      onChanged: (value) {
        setState(() {
          _filters = _filters.copyWith(onlyOfflineRecipes: value);
        });
      },
    );
  }

  void _addIngredient() {
    final ingredient = _ingredientController.text.trim();
    if (ingredient.isNotEmpty && !_ingredients.contains(ingredient)) {
      setState(() {
        _ingredients.add(ingredient);
        _filters = _filters.copyWith(ingredients: _ingredients);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
      _filters = _filters.copyWith(ingredients: _ingredients);
    });
  }

  void _search() {
    ref.read(searchProvider.notifier).searchRecipes(_filters);
    Navigator.pop(context, _filters);
  }
} 