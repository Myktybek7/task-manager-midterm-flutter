
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int id;
  final String title;
  final bool isCompleted;

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Task copyWith({
    String? title,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
