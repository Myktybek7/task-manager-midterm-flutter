
import 'package:equatable/equatable.dart';
import '../models/task.dart';

enum TaskStatus {
  initial,
  loading,
  success,
  failure,
}

class TaskState extends Equatable {
  final List<Task> tasks;
  final TaskStatus status;
  final String? error;

  const TaskState({
    this.tasks = const [],
    this.status = TaskStatus.initial,
    this.error,
  });

  @override
  List<Object?> get props => [tasks, status, error];
}
