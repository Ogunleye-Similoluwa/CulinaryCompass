import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/receipe_grid.dart';
import 'package:food_reciepe_finder/feature/home/presentation/widget/receipe_search_bar.dart';

import '../../riverpod/state_manager.dart';
import 'favourite_screen.dart';
import 'category_results_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          const FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(randomRecipesProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Recipe Finder', style: TextStyle(color: Colors.black)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/grilled_chicken_salad.jpeg',
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
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: RecipeSearchBar(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Trending Recipes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildCategoriesSection(),
          ),
          SliverToBoxAdapter(
            child: _buildMealTypesSection(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Popular Recipes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(title: const Text('Popular Recipes')),
                            body: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(16),
                                  sliver: RecipeGrid(
                                    provider: ref.watch(popularRecipesProvider),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: RecipeGrid(
              provider: ref.watch(popularRecipesProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final categories = [
      {'icon': Icons.lunch_dining, 'name': 'Main Course'},
      {'icon': Icons.breakfast_dining, 'name': 'Breakfast'},
      {'icon': Icons.cake, 'name': 'Dessert'},
      {'icon': Icons.local_drink, 'name': 'Beverages'},
      {'icon': Icons.soup_kitchen, 'name': 'Soups'},
      {'icon': Icons.restaurant, 'name': 'Appetizers'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(
                categories[index]['icon'] as IconData,
                categories[index]['name'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryResultsScreen(
                title: name,
                category: name.replaceAll(' ', ''),
                isMealType: false,
              ),
            ),
          );
        },
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(name),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypesSection() {
    final mealTypes = [
      {'icon': Icons.wb_sunny_outlined, 'name': 'Breakfast'},
      {'icon': Icons.restaurant, 'name': 'Lunch'},
      {'icon': Icons.dinner_dining, 'name': 'Dinner'},
      {'icon': Icons.bakery_dining, 'name': 'Snacks'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Meal Types',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: mealTypes.length,
            itemBuilder: (context, index) {
              return _buildCategoryItem(
                mealTypes[index]['icon'] as IconData,
                mealTypes[index]['name'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
}