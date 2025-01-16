import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../search_result_screen.dart';

class RecipeSearchBar extends ConsumerStatefulWidget {
  const RecipeSearchBar({Key? key}) : super(key: key);

  @override
  _RecipeSearchBarState createState() => _RecipeSearchBarState();
}

class _RecipeSearchBarState extends ConsumerState<RecipeSearchBar> {
  final _searchController = TextEditingController();

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SearchResultsScreen(
            initialQuery: _searchController.text,
            searchController: _searchController,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToSearch(context),
      child: TextField(
        controller: _searchController,
        enabled: false,
        decoration: InputDecoration(
          hintText: 'Search recipes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              _navigateToSearch(context);
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}