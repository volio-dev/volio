import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiKeyProvider = NotifierProvider(() {
  return ApiKeyNotifier();
});

class ApiKeyNotifier extends Notifier {
  List apiKeys = ["eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6ImU1OTViM2I1LWMzNDktNDIyNi04OTNmLWE5NDdjOTgyYzUzNyIsIm9yZ0lkIjoiNDQ3MzY2IiwidXNlcklkIjoiNDYwMjg4IiwidHlwZUlkIjoiZjA0YzUzM2MtZDY4Zi00YWJkLTgxMDctNjQ4MWI3ZDExNjBlIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDczODg5MTksImV4cCI6NDkwMzE0ODkxOX0.g5SqiJusqAmGid8KX5vzl3nDpM9HRnxrK2QML6wSRys",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjZlZmMzYTQ3LWQ3YzEtNGZlYy05NWUyLTg1ZDEwMmEwMGFhZiIsIm9yZ0lkIjoiNDQ3Mzk1IiwidXNlcklkIjoiNDYwMzE5IiwidHlwZUlkIjoiOTdiNjRhMDQtNGM5Mi00NzkyLWJkM2EtNmE3ZDViNzY1Y2QyIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDczOTc5NzcsImV4cCI6NDkwMzE1Nzk3N30.O18RV7fnWfgPnKc84SCt6XbjZXQ9Kx7d_Xc_VObKrZ4",
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJub25jZSI6IjIyODFhOTI3LTlmZmEtNGY5MS1hYzg0LWVlYzBmMmE3Zjc4NCIsIm9yZ0lkIjoiNDM5MTAxIiwidXNlcklkIjoiNDUxNzQ0IiwidHlwZUlkIjoiYThmMTcxOTQtOWUzZi00MzkyLWI3ZWYtZDU0N2NhMjM1ZDRhIiwidHlwZSI6IlBST0pFQ1QiLCJpYXQiOjE3NDM1MDYyNzEsImV4cCI6NDg5OTI2NjI3MX0.qQESIfuQqwFZguH2K_ffmZrNIZm9KzKBHP9FrWfIeVA"
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

