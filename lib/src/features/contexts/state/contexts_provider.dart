import 'package:flutter/material.dart';

class LifeContext {
  final String id;
  final String name;
  final String description;
  final DateTime lastUpdated;

  const LifeContext({
    required this.id,
    required this.name,
    required this.description,
    required this.lastUpdated,
  });

  String get lastUpdatedString {
    final now = DateTime.now();
    final diff = now.difference(lastUpdated);
    if (diff.inHours < 1) return 'Just now';
    if (diff.inHours < 24) return diff.inHours.toString() + 'h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${lastUpdated.year}-${lastUpdated.month}-${lastUpdated.day}';
  }
}

class ContextsProvider extends ChangeNotifier {
  final List<LifeContext> _contexts = <LifeContext>[
    LifeContext(
      id: '1',
      name: 'general',
      description: 'General discussions and announcements',
      lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    LifeContext(
      id: '2',
      name: 'work-projects',
      description: 'Work-related projects and tasks',
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<LifeContext> get contexts => List.unmodifiable(_contexts);

  void addContext(String name, String description) {
    if (name.isEmpty) return;
    final context = LifeContext(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-'),
      description: description.isEmpty ? 'No description' : description,
      lastUpdated: DateTime.now(),
    );
    _contexts.insert(0, context);
    notifyListeners();
  }
}
