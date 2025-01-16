import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/cooking_timer_widget.dart';
import 'package:food_reciepe_finder/feature/riverpod/collections_provider.dart';

import '../../riverpod/state_manager.dart';
import '../model/recipe_model.dart';
import '../model/collection_model.dart';
import '../presentation/collections_screen.dart';


class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteRecipesProvider.notifier).isFavorite(recipe);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'recipe-image-${recipe.imageUrl}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(recipe.title),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(),
                  const SizedBox(height: 16),
                  CookingTimer(totalMinutes: recipe.readyInMinutes),
                  const SizedBox(height: 16),
                  _buildDietTags(),
                  const SizedBox(height: 24),
                  _buildIngredientsSection(),
                  const SizedBox(height: 24),
                  _buildInstructionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'save',
            onPressed: () => _showSaveToCollectionDialog(context, ref),
            backgroundColor: Colors.blue,
            child: const Icon(Icons.save),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'favorite',
            onPressed: () {
              ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
            },
            backgroundColor: Colors.red,
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildInfoItem(Icons.timer, '${recipe.readyInMinutes} min'),
        _buildInfoItem(Icons.people, '${recipe.servings} servings'),
        _buildInfoItem(Icons.local_fire_department, '${recipe.calories} cal'),
        _buildInfoItem(Icons.star, recipe.rating.toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(text),
      ],
    );
  }

  Widget _buildDietTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recipe.diets.map((diet) {
        return Chip(
          label: Text(diet),
          backgroundColor: Colors.green.withOpacity(0.1),
          labelStyle: const TextStyle(color: Colors.green),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...recipe.ingredients.map((ingredient) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.fiber_manual_record, size: 8),
                const SizedBox(width: 8),
                Expanded(child: Text(ingredient)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InstructionsWidget(instructions: recipe.instructions),
      ],
    );
  }

  void _showSaveToCollectionDialog(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Save to Collection'),
          ),
          ...collections.map(
            (collection) => ListTile(
              leading: const Icon(Icons.folder),
              title: Text(collection.name),
              onTap: () {
                ref.read(collectionsProvider.notifier)
                    .addRecipeToCollection(collection.id, recipe);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to ${collection.name}')),
                );
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create New Collection'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CollectionsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class InstructionsWidget extends StatefulWidget {
  final String instructions;

  const InstructionsWidget({super.key, required this.instructions});

  @override
  _InstructionsWidgetState createState() => _InstructionsWidgetState();
}

class _InstructionsWidgetState extends State<InstructionsWidget> {
  List<String> steps = [];
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    steps = widget.instructions
        .split('\n')
        .where((step) => step.trim().isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          ExpansionTile(
            initiallyExpanded: i == currentStep,
            onExpansionChanged: (expanded) {
              if (expanded) {
                setState(() => currentStep = i);
              }
            },
            title: Text('Step ${i + 1}'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(steps[i]),
              ),
            ],
          ),
      ],
    );
  }
}