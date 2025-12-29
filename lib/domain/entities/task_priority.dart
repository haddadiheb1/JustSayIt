import 'package:flutter/material.dart';

enum TaskPriority {
  low(0, 'Low', Colors.green),
  medium(1, 'Medium', Colors.orange),
  high(2, 'High', Colors.red);

  final int value;
  final String displayName;
  final Color color;

  const TaskPriority(this.value, this.displayName, this.color);
}
