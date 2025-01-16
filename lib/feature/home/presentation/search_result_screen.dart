import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/receipe_grid.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/recipe_item.dart';
import '../../riverpod/state_manager.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final isLoadingProvider = StateProvider<bool>((ref) => false);

class SearchResultsScreen extends ConsumerWidget {
  final String initialQuery;
  final TextEditingController searchController;

  const SearchResultsScreen({
    Key? key,
    required this.initialQuery,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchRecipesProvider(searchQuery));

    // Initialize search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchQuery.isEmpty) {
        ref.read(searchQueryProvider.notifier).state = initialQuery;
        searchController.text = initialQuery;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                searchController.clear();
                Navigator.pop(context);
              },
            ),
          ),
          onSubmitted: (newQuery) {
            if (newQuery.isNotEmpty) {
              ref.read(isLoadingProvider.notifier).state = true;
              ref.read(searchQueryProvider.notifier).state = newQuery;
              ref.read(isLoadingProvider.notifier).state = false;
            }
          },
        ),
        actions: [
          ref.watch(isLoadingProvider) ? const CircularProgressIndicator() : const SizedBox.shrink(),
        ],
      ),
      body: searchResults.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text('No recipes found'));
          }

          return CustomScrollView(
            slivers: [
              // Direct Matches
              if (recipes.length > 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Direct Matches',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= recipes.length ~/ 2) return null;
                        return RecipeCard(
                          recipe: recipes[index],
                          onFavoritePressed: () {
                            ref.read(favoriteRecipesProvider.notifier)
                                .toggleFavorite(recipes[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],

              // Similar Recipes
              if (recipes.length > recipes.length ~/ 2) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Similar Recipes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final recipeIndex = index + (recipes.length ~/ 2);
                        if (recipeIndex >= recipes.length) return null;
                        return RecipeCard(
                          recipe: recipes[recipeIndex],
                          onFavoritePressed: () {
                            ref.read(favoriteRecipesProvider.notifier)
                                .toggleFavorite(recipes[recipeIndex]);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}