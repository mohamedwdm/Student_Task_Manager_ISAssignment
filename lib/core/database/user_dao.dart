import 'package:sqflite/sqflite.dart';
import 'package:injectable/injectable.dart';
import 'db_helper.dart';

@injectable
class UserDao {
  final DbHelper dbHelper;

  UserDao(this.dbHelper);

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await dbHelper.database;
    return await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAllUsers() async {
    final db = await dbHelper.database;
    await db.delete('users');
  }
}
