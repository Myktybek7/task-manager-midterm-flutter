
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'bloc/task_bloc.dart';
import 'bloc/task_event.dart';
import 'repositories/task_repository.dart';
import 'screens/home_screen.dart';

void main() {
  final baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:8000'
      : 'http://127.0.0.1:8000';

  runApp(MyApp(baseUrl: baseUrl));
}

class MyApp extends StatelessWidget {
  final String baseUrl;

  const MyApp({
    super.key,
    required this.baseUrl,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => TaskRepository(
        baseUrl: baseUrl,
        client: http.Client(),
      ),
      dispose: (repository) => repository.client.close(),
      child: BlocProvider(
        create: (context) => TaskBloc(
          context.read<TaskRepository>(),
        )..add(const LoadTasks()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Task Manager',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
