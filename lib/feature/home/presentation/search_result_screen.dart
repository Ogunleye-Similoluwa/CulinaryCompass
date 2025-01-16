import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/recipe_item.dart';
import '../../riverpod/state_manager.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final isLoadingProvider = StateProvider<bool>((ref) => false);

class SearchResultsScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  final TextEditingController searchController;

  const SearchResultsScreen({
    Key? key,
    required this.initialQuery,
    required this.searchController,
  }) : super(key: key);

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchState = ref.watch(searchStateProvider);

    // Initialize search query and perform initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (searchQuery.isEmpty) {
        ref.read(searchQueryProvider.notifier).state = widget.initialQuery;
        widget.searchController.text = widget.initialQuery;
        // Perform initial search
        ref.read(searchStateProvider.notifier).search(widget.initialQuery);
      }

      // Add scroll listener for infinite scroll
      _scrollController.addListener(() {
        if (_scrollController.position.pixels >= 
            _scrollController.position.maxScrollExtent * 0.8 && 
            !searchState.isLoading &&
            searchState.hasMore) {
          ref.read(searchStateProvider.notifier).search(searchQuery);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: widget.searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search recipes...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.searchController.clear();
                Navigator.pop(context);
              },
            ),
          ),
          onSubmitted: (newQuery) {
            if (newQuery.isNotEmpty) {
              ref.read(searchQueryProvider.notifier).state = newQuery;
              // Reset search state and perform new search
              ref.read(searchStateProvider.notifier)
                ..state = SearchState(recipes: [])
                ..search(newQuery);
            }
          },
        ),
        actions: [
          if (searchState.isLoading) 
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Direct Matches
          if (searchState.recipes.length > 0) ...[
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
                    if (index >= searchState.recipes.length ~/ 2) return null;
                    return RecipeCard(
                      recipe: searchState.recipes[index],
                      onFavoritePressed: () {
                        ref.read(favoriteRecipesProvider.notifier)
                            .toggleFavorite(searchState.recipes[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],

          // Similar Recipes
          if (searchState.recipes.length > searchState.recipes.length ~/ 2) ...[
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
                    final recipeIndex = index + (searchState.recipes.length ~/ 2);
                    if (recipeIndex >= searchState.recipes.length) return null;
                    return RecipeCard(
                      recipe: searchState.recipes[recipeIndex],
                      onFavoritePressed: () {
                        ref.read(favoriteRecipesProvider.notifier)
                            .toggleFavorite(searchState.recipes[recipeIndex]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],

          // Loading indicator at bottom
          if (searchState.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          // No more recipes indicator
          if (!searchState.hasMore && searchState.recipes.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No more recipes to load'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}