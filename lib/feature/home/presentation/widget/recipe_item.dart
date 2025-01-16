// lib/widgets/recipe_card.dart
import 'package:flutter/material.dart';

import '../../model/recipe_model.dart';
import '../receipe_detail_screen.dart';


class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onFavoritePressed;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
          tag: 'recipe-image-${recipe.id}',
          child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                       recipe.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                      )
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: onFavoritePressed,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text('${recipe.readyInMinutes} min'),
                        const Spacer(),
                        const Icon(Icons.local_fire_department, size: 16),
                        const SizedBox(width: 4),
                        Text('${recipe.calories} cal'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}