import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/model/collection_model.dart';
import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionsNotifier extends StateNotifier<List<RecipeCollection>> {
  static const String _key = 'collections';
  final SharedPreferences _prefs;

  CollectionsNotifier(this._prefs) : super([]) {
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final String? collectionsJson = _prefs.getString(_key);
    if (collectionsJson != null) {
      final List<dynamic> decoded = jsonDecode(collectionsJson);
      state = decoded.map((json) => RecipeCollection.fromJson(json)).toList();
    }
  }

  Future<void> _saveCollections() async {
    final String encoded = jsonEncode(state.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, encoded);
  }

  Future<void> addCollection(String name, String description) async {
    final collection = RecipeCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );
    state = [...state, collection];
    await _saveCollections();
  }

  Future<void> addRecipeToCollection(String collectionId, Recipe recipe) async {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        final recipes = [...collection.recipes];
        if (!recipes.contains(recipe)) {
          recipes.add(recipe);
        }
        return collection.copyWith(recipes: recipes);
      }
      return collection;
    }).toList();
    await _saveCollections();
  }

  Future<void> removeRecipeFromCollection(String collectionId, Recipe recipe) async {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        final recipes = collection.recipes.where((r) => r.id != recipe.id).toList();
        return collection.copyWith(recipes: recipes);
      }
      return collection;
    }).toList();
    await _saveCollections();
  }

  Future<void> toggleCollectionSharing(String collectionId) async {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        return collection.copyWith(isShared: !collection.isShared);
      }
      return collection;
    }).toList();
    await _saveCollections();
  }

  Future<void> deleteCollection(String collectionId) async {
    state = state.where((collection) => collection.id != collectionId).toList();
    await _saveCollections();
  }
}

final collectionsProvider = StateNotifierProvider<CollectionsNotifier, List<RecipeCollection>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CollectionsNotifier(prefs);
});

// Add this provider to handle SharedPreferences initialization
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
}); 