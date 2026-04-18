import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@injectable
class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final http.Client client;

  ApiService(this.client);

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await client.delete(Uri.parse('$baseUrl$endpoint'));
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      throw Exception('API error: ${response.statusCode} - ${response.body}');
    }
  }
}
