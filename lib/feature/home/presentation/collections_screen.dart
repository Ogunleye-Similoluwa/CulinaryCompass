import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_reciepe_finder/feature/riverpod/collections_provider.dart';
import 'collection_detail_screen.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(collectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCollectionDialog(context, ref),
          ),
        ],
      ),
      body: collections.isEmpty
          ? const Center(child: Text('No collections yet'))
          : ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(collection.name),
                  subtitle: Text(
                    '${collection.recipes.length} recipes • ${collection.isShared ? 'Shared' : 'Private'}',
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(collection.isShared ? 'Make Private' : 'Share'),
                        onTap: () => ref
                            .read(collectionsProvider.notifier)
                            .toggleCollectionSharing(collection.id),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () => ref
                            .read(collectionsProvider.notifier)
                            .deleteCollection(collection.id),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CollectionDetailScreen(collection: collection),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddCollectionDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Collection Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                ref.read(collectionsProvider.notifier).addCollection(
                      nameController.text,
                      descController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
} 