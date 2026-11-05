import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/bloc/task_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:task_manager/bloc/task_event.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/home_screen.dart';

void main() {
  testWidgets('Add and cancel task dialogs close without errors', (tester) async {
    final client = MockClient((request) async {
      if (request.method == 'GET' && request.url.path == '/tasks') {
        return http.Response('[]', 200);
      }
      if (request.method == 'POST' && request.url.path == '/tasks') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(jsonEncode({
          'id': 1,
          'title': body['title'],
          'isCompleted': false,
        }), 201);
      }
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    });
    addTearDown(client.close);
    final repository = TaskRepository(
      baseUrl: 'http://localhost:8000',
      client: client,
    );
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => TaskBloc(repository)..add(const LoadTasks()),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Test task');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Test task'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Cancelled task');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancelled task'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
