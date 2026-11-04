
import 'package:equatable/equatable.dart';
import '../models/task.dart';

class TaskState extends Equatable {
  final List<Task> tasks;

  const TaskState({
    this.tasks = const [],
  });

  @override
  List<Object?> get props => [tasks];
}
