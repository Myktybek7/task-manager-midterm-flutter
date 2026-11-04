
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc(this.repository) : super(const TaskState()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskState(
        tasks: state.tasks,
        status: TaskStatus.loading,
      ));

      try {
        final tasks = await repository.getTasks();

        emit(TaskState(
          tasks: tasks,
          status: TaskStatus.success,
        ));
      } catch (e) {
        emit(TaskState(
          tasks: state.tasks,
          status: TaskStatus.failure,
          error: e.toString(),
        ));
      }
    });

    on<AddTask>((event, emit) async {
      emit(TaskState(
        tasks: state.tasks,
        status: TaskStatus.loading,
      ));

      try {
        final task = await repository.addTask(event.title);

        emit(TaskState(
          tasks: [...state.tasks, task],
          status: TaskStatus.success,
        ));
      } catch (e) {
        emit(TaskState(
          tasks: state.tasks,
          status: TaskStatus.failure,
          error: e.toString(),
        ));
      }
    });

    on<ToggleTask>((event, emit) async {
      emit(TaskState(
        tasks: state.tasks,
        status: TaskStatus.loading,
      ));

      try {
        final task = state.tasks.firstWhere(
          (task) => task.id == event.id,
        );

        final updatedTask = await repository.updateTask(task);

        final tasks = state.tasks.map((item) {
          return item.id == updatedTask.id ? updatedTask : item;
        }).toList();

        emit(TaskState(
          tasks: tasks,
          status: TaskStatus.success,
        ));
      } catch (e) {
        emit(TaskState(
          tasks: state.tasks,
          status: TaskStatus.failure,
          error: e.toString(),
        ));
      }
    });

    on<DeleteTask>((event, emit) async {
      emit(TaskState(
        tasks: state.tasks,
        status: TaskStatus.loading,
      ));

      try {
        await repository.deleteTask(event.id);

        emit(TaskState(
          tasks: state.tasks
              .where((task) => task.id != event.id)
              .toList(),
          status: TaskStatus.success,
        ));
      } catch (e) {
        emit(TaskState(
          tasks: state.tasks,
          status: TaskStatus.failure,
          error: e.toString(),
        ));
      }
    });
  }
}
