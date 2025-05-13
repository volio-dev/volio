import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<dynamic>> fetchJsonData(String url) async {
    final response = await _dio.get(url);
    final data = response.data;

    if (data is List) {
      return data;
    } else if (data is Map) {
      return [data]; // Objekt als Liste zurückgeben
    } else {
      throw Exception('Unerwartetes Datenformat: ${data.runtimeType}');
    }
  }
}
