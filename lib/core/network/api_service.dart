import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';

@injectable
class ApiService {
  final String baseUrl = 'https://mobileassignment1-production.up.railway.app';
  final http.Client client;

  ApiService(this.client);

  Future<dynamic> get(String endpoint) async {
    try {
      print('DEBUG API: GET $baseUrl$endpoint');
      final response = await client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Student-Task-Manager',
        },
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('DEBUG API: POST $baseUrl$endpoint - Body: $data');
      final response = await client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Student-Task-Manager',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      print('DEBUG API: PUT $baseUrl$endpoint');
      final response = await client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Student-Task-Manager',
        },
        body: json.encode(data),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic>? data) async {
    try {
      print('DEBUG API: PATCH $baseUrl$endpoint');
      final response = await client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Student-Task-Manager',
        },
        body: data != null ? json.encode(data) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      print('DEBUG API: DELETE $baseUrl$endpoint');
      final response = await client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Student-Task-Manager',
        },
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> postMultipart(String endpoint, String filePath) async {
    try {
      print('DEBUG API: MULTIPART POST $baseUrl$endpoint');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      request.headers.addAll({
        'Accept': 'application/json',
        'User-Agent': 'Flutter-Student-Task-Manager',
      });
      
      // Determine content type based on extension
      String extension = filePath.split('.').last.toLowerCase();
      String type = 'image';
      String subtype = (extension == 'png') ? 'png' : 'jpeg';

      request.files.add(await http.MultipartFile.fromPath(
        'file', 
        filePath,
        contentType: MediaType(type, subtype),
      ));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      print('DEBUG API ERROR: $e');
      throw Exception('Network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    print('DEBUG API RESPONSE: ${response.statusCode} - ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      String message = 'API error: ${response.statusCode}';
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('detail')) {
          message = errorData['detail'];
        }
      } catch (_) {
        message += ' - ${response.body}';
      }
      throw Exception(message);
    }
  }
}
