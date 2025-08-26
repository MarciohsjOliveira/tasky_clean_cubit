import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/task_status.dart';

class MockApi {
  final _uuid = const Uuid();

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Set up project',
      description: 'Create Flutter project && folders.',
      status: TaskStatus.done,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: '2',
      title: 'Implement login form',
      description: 'With validation && secure storage.',
      status: TaskStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: '3',
      title: 'Task list & filters',
      description: 'List, filter by status & date.',
      status: TaskStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  Future<(String token, AppUser user)> login(
      String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final user =
        AppUser(id: _uuid.v4(), email: email, name: email.split('@').first);
    final token = 'mock_jwt_${_uuid.v4()}';
    return (token, user);
  }

  Future<(String token, AppUser user)> register(
      String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    final user = AppUser(id: _uuid.v4(), email: email, name: name);
    final token = 'mock_jwt_${_uuid.v4()}';
    return (token, user);
  }

  Future<List<Task>> list(
      {TaskStatus? status, DateTime? from, DateTime? to}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _tasks.where((t) {
      final inStatus = status == null || t.status == status;
      final inFrom = from == null || !t.createdAt.isBefore(from);
      final inTo = to == null || !t.createdAt.isAfter(to);
      return inStatus && inFrom && inTo;
    }).toList();
  }

  Future<Task> create(
      {required String title,
      required String description,
      DateTime? dueDate}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      status: TaskStatus.pending,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _tasks.insert(0, task);
    return task;
  }

  Future<Task> update(Task task) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final idx = _tasks.indexWhere((e) => e.id == task.id);
    if (idx != -1) {
      final updated = task.copyWith(updatedAt: DateTime.now());
      _tasks[idx] = updated;
      return updated;
    }
    throw Exception('Task not found');
  }

  Future<void> delete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _tasks.removeWhere((e) => e.id == id);
  }

  Future<Task> toggleComplete(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final idx = _tasks.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final cur = _tasks[idx];
      final nextStatus =
          cur.status == TaskStatus.done ? TaskStatus.pending : TaskStatus.done;
      final t = cur.copyWith(status: nextStatus, updatedAt: DateTime.now());
      _tasks[idx] = t;
      return t;
    }
    throw Exception('Task not found');
  }

  Future<Task> byId(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _tasks.firstWhere((e) => e.id == id);
  }
}
