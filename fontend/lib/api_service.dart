import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8080/api/';
  static const storage = FlutterSecureStorage();
  static final _dateFormatter = DateFormat('yyyy-MM-dd');


  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['data']['token'];
      await storage.write(key: 'auth_token', value: token);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> signup(String fullName, String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullName,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Signup failed: ${response.body}');
    }
  }


  Future<void> logout() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.post(
      Uri.parse('${baseUrl}logout/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      await storage.delete(key: 'auth_token');
    } else {
      throw Exception('Logout failed: ${response.body}');
    }
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<List<dynamic>> fetchProjects() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}projects/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results']['data'] == null) {
        return []; 
      }
      return data['results']['data'];
    } else {
      throw Exception('Failed to fetch projects: ${response.body}');
    }
  }

  Future<void> createProject(String title) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${baseUrl}projects/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create project: ${response.body}');
    }
  }

  Future<void> deleteProject(int projectId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('${baseUrl}projects/$projectId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete project: ${response.body}');
    }
  }

  Future<List<dynamic>> fetchTasks(int projectId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('${baseUrl}projects/$projectId/tasks/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results']['data'] == null) {
        return []; 
      }
      return data['results']['data'];
    } else {
      throw Exception('Failed to fetch tasks: ${response.body}');
    }
  }

  Future<void> createTask(
    int projectId,
    String title,
    DateTime dueDate,
    bool isCompleted,
  ) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${baseUrl}projects/$projectId/tasks/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'deadline': _dateFormatter.format(dueDate),
        'is_completed': isCompleted,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<void> deleteTask(int projectId, int taskId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('${baseUrl}projects/$projectId/tasks/$taskId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> userProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No token found');
    final response = await http.get(
      Uri.parse('${baseUrl}profile/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch profile data: ${response.body}');
    }
  }
}
