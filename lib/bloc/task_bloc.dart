
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskState()) {
    on<AddTask>((event, emit) {
      final task = Task(
        id: DateTime.now().microsecondsSinceEpoch,
        title: event.title,
      );

      emit(TaskState(
        tasks: [...state.tasks, task],
      ));
    });

    on<DeleteTask>((event, emit) {
      final updatedTasks = state.tasks
          .where((task) => task.id != event.id)
          .toList();

      emit(TaskState(tasks: updatedTasks));
    });

    on<ToggleTask>((event, emit) {
      final updatedTasks = state.tasks.map((task) {
        if (task.id == event.id) {
          return task.copyWith(
            isCompleted: !task.isCompleted,
          );
        }
        return task;
      }).toList();

      emit(TaskState(tasks: updatedTasks));
    });
  }
}
