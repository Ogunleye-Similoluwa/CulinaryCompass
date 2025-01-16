import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/collection_model.dart';
import 'widget/recipe_item.dart';

class CollectionDetailScreen extends ConsumerWidget {
  final RecipeCollection collection;

  const CollectionDetailScreen({Key? key, required this.collection}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(collection.name),
            Text(
              '${collection.recipes.length} recipes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: collection.recipes.isEmpty
          ? const Center(child: Text('No recipes in this collection'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: collection.recipes.length,
              itemBuilder: (context, index) {
                final recipe = collection.recipes[index];
                return RecipeCard(
                  recipe: recipe,
                  onFavoritePressed: () {},
                );
              },
            ),
    );
  }
} 