import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';
import 'db_helper.dart';

@injectable
class TaskDao {
  final DbHelper dbHelper;

  TaskDao(this.dbHelper);

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await dbHelper.database;
    return await db.insert(
      'tasks',
      task,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTasksByUserId(int userId) async {
    final db = await dbHelper.database;
    return await db.query(
      'tasks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'due_date ASC',
    );
  }

  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await dbHelper.database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await dbHelper.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// Replaces all local tasks for [userId] with [tasks] from the remote API.
  Future<void> syncTasks(List<Map<String, dynamic>> tasks, int userId) async {
    final db = await dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('tasks', where: 'user_id = ?', whereArgs: [userId]);
      for (final raw in tasks) {
        final r = Map<String, dynamic>.from(raw);
        final id = r['id'] as int?;
        final dynamic completed = r['is_completed'];
        final int completedInt = completed is bool
            ? (completed ? 1 : 0)
            : (completed is int ? completed : 0);
        final row = <String, dynamic>{
          if (id != null) 'id': id,
          'user_id': userId,
          'title': r['title'] as String,
          'description': r['description'] as String?,
          'due_date': r['due_date'] as String,
          'priority': r['priority'] as String,
          'is_completed': completedInt,
        };
        await txn.insert(
          'tasks',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
