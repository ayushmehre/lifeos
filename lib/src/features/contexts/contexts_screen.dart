import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/contexts_provider.dart';

class ContextsScreen extends StatelessWidget {
  const ContextsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContextsProvider>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final controller = TextEditingController();
                final description = TextEditingController();
                final created = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Create new context'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: controller,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: description,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
                if (created == true) {
                  provider.addContext(
                    controller.text.trim(),
                    description.text.trim(),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Context'),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: provider.contexts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final c = provider.contexts[i];
              return ListTile(
                title: Text('#' + c.name),
                subtitle: Text(c.description),
                trailing: Text(c.lastUpdatedString),
              );
            },
          ),
        ),
      ],
    );
  }
}
