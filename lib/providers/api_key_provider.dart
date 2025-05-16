import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiKeyProvider = NotifierProvider(() {
  return ApiKeyNotifier();
});

class ApiKeyNotifier extends Notifier {
  List apiKeys = ["eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6ImU1OTViM2I1LWMzNDktNDIyNi04OTNmLWE5NDdjOTgyYzUzNyIsIm9yZ0lkIjoiNDQ3MzY2IiwidXNlcklkIjoiNDYwMjg4IiwidHlwZUlkIjoiZjA0YzUzM2MtZDY4Zi00YWJkLTgxMDctNjQ4MWI3ZDExNjBlIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDczODg5MTksImV4cCI6NDkwMzE0ODkxOX0.g5SqiJusqAmGid8KX5vzl3nDpM9HRnxrK2QML6wSRys",
    ];
  int index = 0;

  @override
  String build() {
    return apiKeys[index];
  }

  String get() {
    index = index < apiKeys.length - 1 ? index + 1 : 0;
    return apiKeys[index];
  }
}
