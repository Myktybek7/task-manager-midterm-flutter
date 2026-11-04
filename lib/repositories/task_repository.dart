
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class TaskRepository {
  final String baseUrl;
  final http.Client client;

  TaskRepository({
    required this.baseUrl,
    required this.client,
  });

  Future<List<Task>> getTasks() async {
    final response = await client.get(
      Uri.parse('$baseUrl/tasks'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tasks: ${response.statusCode}');
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) => Task.fromJson(item)).toList();
  }

  Future<Task> addTask(String title) async {
    final response = await client.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add task: ${response.statusCode}');
    }

    return Task.fromJson(jsonDecode(response.body));
  }

  Future<Task> updateTask(Task task) async {
    final response = await client.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'isCompleted': !task.isCompleted,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update task: ${response.statusCode}');
    }

    return Task.fromJson(jsonDecode(response.body));
  }

  Future<void> deleteTask(int id) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/tasks/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.statusCode}');
    }
  }
}
