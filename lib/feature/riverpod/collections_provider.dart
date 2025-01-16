import 'package:food_reciepe_finder/feature/home/model/collection_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/home/model/recipe_model.dart';
class CollectionsNotifier extends StateNotifier<List<RecipeCollection>> {
  CollectionsNotifier() : super([]);

  void addCollection(String name, String description) {
    final collection = RecipeCollection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
    );
    state = [...state, collection];
  }

  void addRecipeToCollection(String collectionId, Recipe recipe) {
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
  }

  void removeRecipeFromCollection(String collectionId, Recipe recipe) {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        final recipes = collection.recipes.where((r) => r.id != recipe.id).toList();
        return collection.copyWith(recipes: recipes);
      }
      return collection;
    }).toList();
  }

  void toggleCollectionSharing(String collectionId) {
    state = state.map((collection) {
      if (collection.id == collectionId) {
        return collection.copyWith(isShared: !collection.isShared);
      }
      return collection;
    }).toList();
  }

  void deleteCollection(String collectionId) {
    state = state.where((collection) => collection.id != collectionId).toList();
  }
}

final collectionsProvider = StateNotifierProvider<CollectionsNotifier, List<RecipeCollection>>((ref) {
  return CollectionsNotifier();
}); 