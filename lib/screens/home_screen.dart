import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void showAddTaskDialog(BuildContext context) {
    final taskBloc = context.read<TaskBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => _AddTaskDialog(onAdd: (title) {
        taskBloc.add(AddTask(title));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task Manager'),
        centerTitle: true,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state.tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Add your first task!'),
            );
          }

          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) {
                      context.read<TaskBloc>().add(
                        ToggleTask(task.id),
                      );
                    },
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<TaskBloc>().add(
                        DeleteTask(task.id),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Enter task title'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final title = _controller.text.trim();
            if (title.isNotEmpty) {
              widget.onAdd(title);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
