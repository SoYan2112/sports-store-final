import '../../../../core/database/app_database.dart';
import '../../domain/entities/user.dart';

class AuthService {
  final AppDatabase _db = AppDatabase.instance;

  Future<User?> authenticate({
    required String email,
    required String password,
  }) async {
    final db = await _db.database;
    final cleanEmail = email.trim().toLowerCase();

    final results = await db.query(
      'users',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [cleanEmail, password],
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return User(
      id: int.tryParse(row['id'].toString()) ?? 1,
      fullname: row['fullname'] as String? ?? '',
      email: row['email'] as String? ?? '',
      password: row['password'] as String? ?? '',
      phoneNumber: row['phone_number'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now(),
    );
  }

  Future<User> register({
    required String fullname,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    final db = await _db.database;
    final cleanEmail = email.trim().toLowerCase();
    final cleanPhone = phoneNumber.trim();

    // 1. Kiểm tra trùng Email
    final emailCheck = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [cleanEmail],
    );
    if (emailCheck.isNotEmpty) {
      throw Exception('Email này đã được sử dụng');
    }

    // 2. Kiểm tra trùng Số điện thoại
    final phoneCheck = await db.query(
      'users',
      where: 'phone_number = ?',
      whereArgs: [cleanPhone],
    );
    if (phoneCheck.isNotEmpty) {
      throw Exception('Số điện thoại này đã được sử dụng');
    }

    // 3. Tạo ID mới
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final count = (countResult.first['count'] as num?)?.toInt() ?? 0;
    final newId = count + 1;
    final now = DateTime.now();

    // 4. Lưu vào SQLite
    await db.insert('users', {
      'id': newId.toString(),
      'fullname': fullname.trim(),
      'email': cleanEmail,
      'phone_number': cleanPhone,
      'password': password,
      'gender': 'Nam',
      'created_at': now.toIso8601String(),
      'status': 'ACTIVE',
    });

    return User(
      id: newId,
      fullname: fullname.trim(),
      email: cleanEmail,
      phoneNumber: cleanPhone,
      password: password,
      createdAt: now,
    );
  }
}
