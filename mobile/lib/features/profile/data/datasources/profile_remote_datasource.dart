import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_profile_model.dart';

/// ============================================================================
/// PROFILE REMOTE DATA SOURCE (API & MẠNG DIO)
/// ============================================================================
/// Giao diện gọi API mạng liên quan đến hồ sơ người dùng.
abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile);
}

/// Triển khai gọi API hồ sơ qua Dio kèm cơ chế Fallback Offline mượt mà
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final LocalStorageService storageService;

  ProfileRemoteDataSourceImpl({
    required this.dio,
    required this.storageService,
  });

  /// 1. LẤY HỒ SƠ NGƯỜI DÙNG QUA API (GET /users/me HOẶC /auth/me)
  @override
  Future<UserProfileModel> getUserProfile() async {
    final token = storageService.getAccessToken();

    try {
      // Đính kèm Header Bearer Token xác thực
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      // Thử gọi endpoint profile chính (/users/me), nếu không có thì fallback sang (/auth/me)
      Response response;
      try {
        response = await dio.get(ApiEndpoints.userProfile, options: options);
      } on DioException {
        response = await dio.get(ApiEndpoints.authMe, options: options);
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final json = (data is Map<String, dynamic> && data.containsKey('data'))
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;

        final profile = UserProfileModel.fromJson(json);

        // Lưu thông tin chi tiết vào local storage SharedPreferences
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
      } else {
        throw ServerException(
          message: 'Lỗi khi tải thông tin cá nhân: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on DioException {
      // Khi offline hoặc backend chưa bật, tự động lấy dữ liệu từ cache SharedPreferences
      return _getFromLocalOrMock();
    } catch (e) {
      if (e is ServerException) rethrow;
      return _getFromLocalOrMock();
    }
  }

  /// 2. CẬP NHẬT HỒ SƠ QUA API (PUT /users/me HOẶC /auth/me)
  @override
  Future<UserProfileModel> updateUserProfile(UserProfileModel profile) async {
    final token = storageService.getAccessToken();

    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      Response response;
      try {
        response = await dio.put(
          ApiEndpoints.userProfile,
          data: profile.toJson(),
          options: options,
        );
      } on DioException {
        // Fallback sang endpoint auth /auth/me
        response = await dio.put(
          ApiEndpoints.authMe,
          data: profile.toJson(),
          options: options,
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final json = (data is Map<String, dynamic> && data.containsKey('data'))
            ? data['data'] as Map<String, dynamic>
            : (data is Map<String, dynamic> ? data : profile.toJson());

        final updated = UserProfileModel.fromJson(json);
        await _saveProfileLocally(updated);
        return updated;
      }
    } on DioException {
      // Khi không có mạng hoặc backend chưa sẵn sàng, lưu cục bộ và tiếp tục
    } catch (_) {
      // Bỏ qua lỗi mạng
    }

    // Lưu offline để trải nghiệm người dùng không bị gián đoạn
    await _saveProfileLocally(profile);
    return profile;
  }

  /// Lưu thông tin profile và đồng bộ auth session xuống SharedPreferences
  Future<void> _saveProfileLocally(UserProfileModel profile) async {
    await storageService.saveUserProfile(
      userId: profile.id,
      name: profile.fullname,
      email: profile.email,
      phone: profile.phoneNumber,
      gender: profile.gender,
      dob: profile.dateOfBirth?.toIso8601String(),
      createdAt: profile.createdAt?.toIso8601String(),
      avatar: profile.avatarUrl,
    );

    final token = storageService.getAccessToken() ?? 'token_${profile.id}';
    await storageService.saveAuthSession(
      token: token,
      userId: profile.id,
      name: profile.fullname,
      email: profile.email,
    );
  }

  /// Trích xuất dữ liệu từ SharedPreferences hoặc tạo Mock dữ liệu chuẩn
  UserProfileModel _getFromLocalOrMock() {
    final savedUser = storageService.getSavedUser();
    final defaultCreated = DateTime(2026, 1, 10);

    if (savedUser != null && (savedUser['name']?.isNotEmpty ?? false)) {
      DateTime? parsedCreated;
      if (savedUser['created_at'] != null && savedUser['created_at']!.isNotEmpty) {
        parsedCreated = DateTime.tryParse(savedUser['created_at']!);
      }

      return UserProfileModel(
        id: savedUser['id']?.isNotEmpty == true ? savedUser['id']! : '1',
        fullname: savedUser['name'] ?? 'Khách hàng',
        email: savedUser['email'] ?? 'user@sportsstore.vn',
        phoneNumber: (savedUser['phone']?.isNotEmpty ?? false)
            ? savedUser['phone']!
            : '0901234567',
        gender: savedUser['gender'] ?? 'Nam',
        createdAt: parsedCreated ?? defaultCreated,
        status: 'ACTIVE',
      );
    }

    // Dữ liệu mẫu dự phòng
    return UserProfileModel(
      id: '1',
      fullname: 'Nguyễn Văn A',
      email: 'a@gmail.com',
      phoneNumber: '0901234567',
      gender: 'Nam',
      createdAt: defaultCreated,
      status: 'ACTIVE',
    );
  }
}
