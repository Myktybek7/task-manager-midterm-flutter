import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/bloc/task_bloc.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('Add and cancel task dialogs close without errors', (tester) async {
    await tester.pumpWidget(
      BlocProvider(create: (_) => TaskBloc(), child: const MyApp()),
    );
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
