import '../../../../core/database/app_database.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_profile_model.dart';
import 'profile_remote_datasource.dart';

/// ============================================================================
/// PROFILE LOCAL DATA SOURCE (SQLITE + CACHE)
/// ============================================================================
/// Định nghĩa các thao tác trực tiếp với cơ sở dữ liệu SQLite cục bộ (Bảng users)
/// và bộ nhớ tạm SharedPreferences.
abstract class ProfileLocalDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

/// Triển khai nguồn dữ liệu cục bộ sử dụng [AppDatabase] (SQLite) và [LocalStorageService]
class ProfileLocalDataSourceImpl
    implements ProfileLocalDataSource, ProfileRemoteDataSource {
  final AppDatabase appDatabase;
  final LocalStorageService storageService;

  ProfileLocalDataSourceImpl({
    AppDatabase? appDatabase,
    required this.storageService,
  }) : appDatabase = appDatabase ?? AppDatabase.instance;

  /// Lấy ID người dùng hiện tại đang đăng nhập từ Session SharedPreferences
  String _getEffectiveUserId() {
    return storageService.getUserId() ?? '1';
  }

  /// 1. LẤY HỒ SƠ NGƯỜI DÙNG TỪ SQLITE (Bảng 'users')
  @override
  Future<UserProfileModel> getUserProfile() async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    // Truy vấn dữ liệu từ bảng users dựa vào ID người dùng hiện tại
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    // Nếu chưa có record trong database, trả về dữ liệu mẫu mặc định
    if (results.isEmpty) {
      return const UserProfileModel(
        id: '1',
        fullname: 'Nguyễn Văn A',
        email: 'a@gmail.com',
        phoneNumber: '0901234567',
        gender: 'Nam',
      );
    }

    // Ánh xạ bản ghi SQLite row sang UserProfileModel
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

    // Đồng bộ thông tin vừa tải vào cache SharedPreferences để truy xuất nhanh
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

  /// 2. CẬP NHẬT HỒ SƠ NGƯỜI DÙNG VÀO SQLITE & CACHE
  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final db = await appDatabase.database;
    final userId = profile.id.isNotEmpty ? profile.id : _getEffectiveUserId();

    // Bước 1: Chạy lệnh UPDATE trực tiếp vào bảng 'users' của SQLite
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

    // Bước 2: Đồng bộ ngay thông tin mới vào SharedPreferences
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

  /// 3. ĐỔI MẬT KHẨU TÀI KHOẢN (Bảng 'users')
  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final db = await appDatabase.database;
    final userId = _getEffectiveUserId();

    // Kiểm tra mật khẩu cũ có khớp trong cơ sở dữ liệu không
    final results = await db.query(
      'users',
      where: 'id = ? AND password = ?',
      whereArgs: [userId, oldPassword],
    );

    if (results.isEmpty) {
      throw Exception('Mật khẩu hiện tại không chính xác');
    }

    // Cập nhật mật khẩu mới
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
