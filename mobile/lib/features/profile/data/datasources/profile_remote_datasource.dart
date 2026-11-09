import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;
  final LocalStorageService storageService;

  ProfileRemoteDataSourceImpl({
    required this.dio,
    required this.storageService,
  });

  @override
  Future<UserProfileModel> getUserProfile() async {
    final token = storageService.getAccessToken();

    try {
      final options = Options(
        headers: {
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      // Thử gọi endpoint profile (/users/me hoặc /auth/me)
      Response response;
      try {
        response = await dio.get(ApiEndpoints.userProfile, options: options);
      } on DioException {
        // Fallback sang endpoint auth /auth/me
        response = await dio.get(ApiEndpoints.authMe, options: options);
      }

      if (response.statusCode == 200) {
        final data = response.data;
        final json = (data is Map<String, dynamic> && data.containsKey('data'))
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;

        final profile = UserProfileModel.fromJson(json);

        // Lưu thông tin chi tiết vào local storage
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
      // Khi offline hoặc backend chưa bật, lấy dữ liệu từ cache / mock
      return _getFromLocalOrMock();
    } catch (e) {
      if (e is ServerException) rethrow;
      return _getFromLocalOrMock();
    }
  }

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

    // Mặc định cho trường hợp chạy kiểm thử hoặc chưa có cache
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

