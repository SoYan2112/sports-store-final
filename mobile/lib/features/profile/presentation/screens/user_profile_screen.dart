import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

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
    // Tự động tải profile nếu cubit chưa có dữ liệu
    final cubit = context.read<ProfileCubit>();
    if (cubit.state is ProfileInitial) {
      cubit.loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } else if (state is ProfileError) {
            return _buildErrorView(state.message);
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(state.profile);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
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

  Widget _buildProfileContent(UserProfileEntity profile) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<ProfileCubit>().refreshProfile(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // 1. Thẻ Avatar & Tên định danh phong cách thể thao
          _buildAvatarCard(profile),
          const SizedBox(height: 20),

          // 2. Thẻ Thông tin cá nhân chi tiết
          _buildSectionHeader('Thông tin cá nhân', Icons.badge_outlined),
          const SizedBox(height: 10),
          _buildDetailsCard(profile),
          const SizedBox(height: 24),

          
          const SizedBox(height: 10),
          // _buildSecurityCard(),
          // const SizedBox(height: 32),

          // 4. Nút chỉnh sửa hồ sơ (UC-27)
          _buildEditProfileButton(profile),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(UserProfileEntity profile) {
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

  Widget _buildDetailsCard(UserProfileEntity profile) {
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
          _buildInfoRow(
            label: 'Họ và tên',
            value: profile.fullname.isNotEmpty ? profile.fullname : 'Chưa cập nhật',
            icon: Icons.person_outline_rounded,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: 'Địa chỉ Email',
            value: profile.email.isNotEmpty ? profile.email : 'Chưa cập nhật',
            icon: Icons.email_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: 'Số điện thoại',
            value: profile.phoneNumber.isNotEmpty
                ? profile.phoneNumber
                : 'Chưa cập nhật',
            icon: Icons.phone_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: 'Giới tính',
            value: profile.gender,
            icon: Icons.wc_outlined,
          ),
          _buildDivider(),
          _buildInfoRow(
            label: 'Ngày tham gia',
            value: joinDateFormatted,
            icon: Icons.calendar_today_outlined,
          ),
          _buildDivider(),
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
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
          final updated = await Navigator.of(context).push<UserProfileEntity?>(
            EditProfileScreen.route(profile: profile),
          );
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
