import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/advanced_search_screen.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/recipe_item.dart';
import 'package:food_reciepe_finder/feature/riverpod/state_manager.dart';
import '../model/recipe_model.dart';
import '../model/search_filter_model.dart';
import '../../riverpod/search_provider.dart';

class SearchResultsScreen extends ConsumerWidget {
  final SearchFilters filters;

  const SearchResultsScreen({
    Key? key,
    required this.filters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(searchState.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider.notifier).searchRecipes(filters);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final results = searchState.results;

    return Scaffold(
      appBar: AppBar(
        title: Text('${results.length} Results Found'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final newFilters = await Navigator.push<SearchFilters>(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdvancedSearchScreen(),
                ),
              );
              if (newFilters != null) {
                ref.read(searchProvider.notifier).searchRecipes(newFilters);
              }
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final recipe = results[index];
          return RecipeCard(
            recipe: recipe,
            onFavoritePressed: () {
              ref.read(favoriteRecipesProvider.notifier).toggleFavorite(recipe);
            },
          );
        },
      ),
    );
  }
} 