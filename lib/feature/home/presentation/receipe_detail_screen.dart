import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/cooking_timer_widget.dart';

import '../../riverpod/state_manager.dart';
import '../model/recipe_model.dart';


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
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(),
                  SizedBox(height: 16),
                  CookingTimer(totalMinutes: recipe.readyInMinutes),
                  SizedBox(height: 16),
                  _buildDietTags(),
                  SizedBox(height: 24),
                  _buildIngredientsSection(),
                  SizedBox(height: 24),
                  _buildInstructionsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
        ),
        backgroundColor: Colors.red,
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
        SizedBox(height: 4),
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
          labelStyle: TextStyle(color: Colors.green),
        );
      }).toList(),
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ...recipe.ingredients.map((ingredient) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(Icons.fiber_manual_record, size: 8),
                SizedBox(width: 8),
                Expanded(child: Text(ingredient)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Instructions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        InstructionsWidget(instructions: recipe.instructions),
      ],
    );
  }
}

class InstructionsWidget extends StatefulWidget {
  final String instructions;

  const InstructionsWidget({Key? key, required this.instructions})
      : super(key: key);

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
                padding: EdgeInsets.all(16),
                child: Text(steps[i]),
              ),
            ],
          ),
      ],
    );
  }
}