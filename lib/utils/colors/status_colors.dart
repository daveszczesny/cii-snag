import 'package:flutter/material.dart';

class StatusColors extends ThemeExtension<StatusColors> {
  final Color? todo;
  final Color? inProgress;
  final Color? completed;
  final Color? blocked;

  StatusColors({
    this.todo,
    this.inProgress,
    this.completed,
    this.blocked,
  });

  @override
  StatusColors copyWith({
    Color? todo,
    Color? inProgress,
    Color? completed,
    Color? blocked,
  }) {
    return StatusColors(
      todo: todo ?? this.todo,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      blocked: blocked ?? this.blocked,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) {
      return this;
    }
    return StatusColors(
      todo: Color.lerp(todo, other.todo, t),
      inProgress: Color.lerp(inProgress, other.inProgress, t),
      completed: Color.lerp(completed, other.completed, t),
      blocked: Color.lerp(blocked, other.blocked, t),
    );
  }
}