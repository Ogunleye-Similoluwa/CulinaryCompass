import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/receipe_grid.dart';
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
    final isLoading = ref.watch(isLoadingProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Initialize the search query
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
          isLoading ? const CircularProgressIndicator() : const SizedBox.shrink(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(isLoadingProvider.notifier).state = true;
          ref.refresh(searchRecipesProvider(searchQuery));
          ref.read(isLoadingProvider.notifier).state = false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: Consumer(
                builder: (context, ref, child) {
                  final currentQuery = ref.watch(searchQueryProvider);
                  return RecipeGrid(
                    provider: ref.watch(searchRecipesProvider(currentQuery)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}