import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'edit_profile_screen.dart';

/// ============================================================================
/// MÀN HÌNH XEM HỒ SƠ CÁ NHÂN (USER PROFILE SCREEN - UC-26)
/// ============================================================================
/// Màn hình này chịu trách nhiệm:
/// 1. Tải và hiển thị chi tiết hồ sơ người dùng (Họ tên, Email, SĐT, Giới tính, Ngày tham gia).
/// 2. Hỗ trợ thao tác kéo để làm mới (Pull-to-refresh) dữ liệu.
/// 3. Điều hướng sang màn hình Chỉnh sửa hồ sơ (UC-27) và tự động đồng bộ lại UI khi lưu xong.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  /// Phương thức static tạo Route điều hướng đến UserProfileScreen.
  /// Tự động khởi tạo và cung cấp [ProfileCubit] từ GetIt dependency injection,
  /// đồng thời kích hoạt gọi ngay hàm [loadProfile()] để tải dữ liệu ban đầu.
  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => BlocProvider<ProfileCubit>(
        create: (_) => getIt<ProfileCubit>()..loadProfile(),
        child: const UserProfileScreen(),
      ),
    );
  }

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Vòng đời khởi tạo: Tự động tải profile nếu cubit chưa có dữ liệu (ở trạng thái ProfileInitial)
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is ProfileInitial) {
      cubit.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // Thanh tiêu đề AppBar với nút quay lại
      appBar: AppBar(
        title: const Text(
          'Hồ sơ cá nhân',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(), // Quay lại màn hình trước
        ),
      ),
      // BlocBuilder theo dõi trạng thái ProfileCubit để render giao diện tương ứng
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          // Trạng thái 1: Đang tải dữ liệu -> Hiện vòng xoay tiến trình Loading
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } 
          // Trạng thái 2: Có lỗi xảy ra -> Hiện giao diện thông báo lỗi kèm nút "Thử lại"
          else if (state is ProfileError) {
            return _buildErrorView(state.message);
          } 
          // Trạng thái 3: Tải thành công -> Render nội dung chi tiết hồ sơ người dùng
          else if (state is ProfileLoaded) {
            return _buildProfileContent(state.profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Giao diện hiển thị khi xảy ra lỗi trong quá trình tải hồ sơ
  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon cảnh báo lỗi
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Không thể tải thông tin hồ sơ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            // Nội dung chi tiết lỗi
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Nút bấm "Thử lại": Kích hoạt gọi lại loadProfile() từ ProfileCubit
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => context.read<ProfileCubit>().loadProfile(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử lại', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện chính hiển thị đầy đủ thông tin hồ sơ khi ở trạng thái ProfileLoaded
  Widget _buildProfileContent(UserProfileEntity profile) {
    return RefreshIndicator(
      color: AppColors.primary,
      // Hỗ trợ kéo vuốt màn hình để làm mới (Refresh) thông tin từ SQLite / API
      onRefresh: () => context.read<ProfileCubit>().refreshProfile(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 1. Thẻ Avatar, Tên định danh & Huy hiệu thành viên phong cách thể thao
          _buildAvatarCard(profile),
          const SizedBox(height: 20),

          // 2. Tiêu đề mục thông tin cá nhân
          _buildSectionHeader('Thông tin cá nhân', Icons.badge_outlined),
          const SizedBox(height: 10),

          // 3. Thẻ bảng chi tiết: Họ tên, Email, SĐT, Giới tính, Ngày tham gia, Trạng thái
          _buildDetailsCard(profile),
          const SizedBox(height: 24),

          // 4. Nút bấm chuyển sang màn hình Chỉnh sửa hồ sơ (UC-27)
          _buildEditProfileButton(profile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Thẻ Avatar & Tên định danh người dùng phong cách thể thao
  Widget _buildAvatarCard(UserProfileEntity profile) {
    // Trích xuất ký tự đầu tiên của họ tên để làm Avatar (ví dụ: "Nguyễn Văn A" -> 'N')
    final initialLetter = profile.fullname.trim().isNotEmpty
        ? profile.fullname.trim().substring(0, 1).toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Khung Avatar tròn kèm icon tích xanh xác thực
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFFFE8D6),
                  child: Text(
                    initialLetter,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ),
                // Icon checkmark xác thực ở góc dưới bên phải avatar
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Họ và tên hiển thị nổi bật
          Text(
            profile.fullname.isNotEmpty ? profile.fullname : 'Khách hàng',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          // Địa chỉ Email
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Huy hiệu thành viên (Badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: Colors.blueAccent,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Thành viên Thể thao',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tiêu đề phân đoạn với icon đại diện
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Thẻ Card chứa toàn bộ thông tin chi tiết từng trường của hồ sơ
  Widget _buildDetailsCard(UserProfileEntity profile) {
    // Định dạng ngày tham gia theo chuẩn Việt Nam dd/MM/yyyy
    final joinDateFormatted = profile.createdAt != null
        ? '${profile.createdAt!.day.toString().padLeft(2, '0')}/${profile.createdAt!.month.toString().padLeft(2, '0')}/${profile.createdAt!.year}'
        : '10/01/2026';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dòng 1: Họ và tên
          _buildInfoRow(
            label: 'Họ và tên',
            value: profile.fullname.isNotEmpty ? profile.fullname : 'Chưa cập nhật',
            icon: Icons.person_outline_rounded,
          ),
          _buildDivider(),
          // Dòng 2: Địa chỉ Email (Không đổi)
          _buildInfoRow(
            label: 'Địa chỉ Email',
            value: profile.email.isNotEmpty ? profile.email : 'Chưa cập nhật',
            icon: Icons.email_outlined,
          ),
          _buildDivider(),
          // Dòng 3: Số điện thoại
          _buildInfoRow(
            label: 'Số điện thoại',
            value: profile.phoneNumber.isNotEmpty
                ? profile.phoneNumber
                : 'Chưa cập nhật',
            icon: Icons.phone_outlined,
          ),
          _buildDivider(),
          // Dòng 4: Giới tính
          _buildInfoRow(
            label: 'Giới tính',
            value: profile.gender,
            icon: Icons.wc_outlined,
          ),
          _buildDivider(),
          // Dòng 5: Ngày tham gia
          _buildInfoRow(
            label: 'Ngày tham gia',
            value: joinDateFormatted,
            icon: Icons.calendar_today_outlined,
          ),
          _buildDivider(),
          // Dòng 6: Trạng thái tài khoản (Badge nhãn "Hoạt động")
          _buildInfoRow(
            label: 'Trạng thái tài khoản',
            value: 'Đang hoạt động',
            icon: Icons.shield_outlined,
            customTrailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Text(
                'Hoạt động',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget dùng chung để hiển thị một dòng thông tin gồm Icon, Tiêu đề (label) và Giá trị (value)
  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Widget? customTrailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.grey.shade600),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nhãn mô tả (VD: "Họ và tên", "Số điện thoại")
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                // Giá trị tương ứng
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ?customTrailing,
        ],
      ),
    );
  }

  /// Nút bấm mở màn hình Chỉnh sửa hồ sơ (EditProfileScreen - UC-27)
  Widget _buildEditProfileButton(UserProfileEntity profile) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        key: const Key('editProfileButton'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        onPressed: () async {
          // Điều hướng sang EditProfileScreen và chờ kết quả trả về khi người dùng nhấn "Lưu"
          final updated = await Navigator.of(context).push<UserProfileEntity?>(
            EditProfileScreen.route(profile: profile),
          );
          // Nếu có thông tin mới được trả về, cập nhật state của ProfileCubit ngay tại chỗ
          // mà không cần phải reload lại toàn bộ trang từ cơ sở dữ liệu
          if (updated != null && mounted) {
            context.read<ProfileCubit>().updateLoadedProfile(updated);
          }
        },
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text(
          'Chỉnh sửa hồ sơ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// Đường phân cách mảnh giữa các dòng thông tin
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 54,
      endIndent: 18,
      color: Colors.grey.shade100,
    );
  }
}
