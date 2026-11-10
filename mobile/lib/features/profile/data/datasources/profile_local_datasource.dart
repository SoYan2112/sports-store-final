import '../../../../core/database/app_database.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_profile_model.dart';
import 'profile_remote_datasource.dart';

abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class ProfileLocalDataSourceImpl
    implements ProfileLocalDataSource, ProfileRemoteDataSource {
  final AppDatabase appDatabase;
  final LocalStorageService storageService;

  ProfileLocalDataSourceImpl({
    AppDatabase? appDatabase,
    required this.storageService,
  }) : appDatabase = appDatabase ?? AppDatabase.instance;

  String _getEffectiveUserId() {
    return storageService.getUserId() ?? '1';
  }

  @override
  Future<UserProfileModel> getUserProfile() async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) {
      // Fallback nếu chưa đăng nhập hoặc ID không tồn tại
      return const UserProfileModel(
        id: '1',
        fullname: 'Nguyễn Văn A',
        email: 'a@gmail.com',
        phoneNumber: '0901234567',
        gender: 'Nam',
      );
    }

    final row = results.first;
    final profile = UserProfileModel(
      id: row['id'] as String,
      fullname: row['fullname'] as String? ?? '',
      email: row['email'] as String? ?? '',
      phoneNumber: row['phone_number'] as String? ?? '',
      gender: row['gender'] as String? ?? 'Nam',
      dateOfBirth: row['date_of_birth'] != null
          ? DateTime.tryParse(row['date_of_birth'].toString())
          : null,
      avatarUrl: row['avatar_url'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'].toString())
          : null,
      status: row['status'] as String? ?? 'ACTIVE',
    );

    await storageService.saveUserProfile(
      userId: profile.id,
      name: profile.fullname,
      email: profile.email,
      phone: profile.phoneNumber,
      gender: profile.gender,
      createdAt: profile.createdAt?.toIso8601String(),
      avatar: profile.avatarUrl,
    );

    return profile;
  }

  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final db = await appDatabase.database;
    final userId = profile.id.isNotEmpty ? profile.id : _getEffectiveUserId();

    await db.update(
      'users',
      {
        'fullname': profile.fullname,
        'phone_number': profile.phoneNumber,
        'gender': profile.gender,
        'date_of_birth': profile.dateOfBirth?.toIso8601String(),
        if (profile.avatarUrl != null) 'avatar_url': profile.avatarUrl,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    await storageService.saveUserProfile(
      userId: userId,
      name: profile.fullname,
      email: profile.email,
      phone: profile.phoneNumber,
      gender: profile.gender,
      createdAt: profile.createdAt?.toIso8601String(),
      avatar: profile.avatarUrl,
    );

    return profile;
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    final results = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, oldPassword],
    );

    if (results.isEmpty) {
      throw Exception('Mật khẩu hiện tại không chính xác');
    }

    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
