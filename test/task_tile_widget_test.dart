import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task_model.dart';
import 'package:task_manager/screens/task_screen.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  testWidgets('test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: TaskTile(
              task: Task(
                id: 'id-test-tile-task',
                title: 'Title test tile task',
                description:
                    'Some description for the test on pressing the task tile',
                category: TaskCategory.personal,
                dueDate: DateTime.parse('2024-11-28T11:30:00.000'),
                priority: TaskPriority.medium,
              ),
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Tap on the TaskTile
    await tester.tap(find.byType(TaskTile));

    // Wait for navigation
    await tester.pumpAndSettle();

    // Check if the navigation to AddEditTaskScreen occurred
    expect(find.byType(AddEditTaskScreen), findsOneWidget);
  });
}
