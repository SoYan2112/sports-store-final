import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/address_entity.dart';

/// ============================================================================
/// ADDRESS CARD WIDGET - THẺ HIỂN THỊ ĐỊA CHỈ NHẬN HÀNG
/// ============================================================================
/// Widget hiển thị thông tin tóm tắt của một địa chỉ giao hàng:
/// - Tên người nhận & Số điện thoại.
/// - Địa chỉ chi tiết và địa chỉ 3 cấp (Phường/Xã, Quận/Huyện, Tỉnh/Thành phố).
/// - Badge loại địa chỉ (Nhà riêng / Văn phòng) và Badge "Mặc định".
/// - Viền viền đậm nếu đang được chọn ([isSelected = true]) trong Checkout.
class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isSelected;

  const AddressCard({
    super.key,
    required this.address,
    this.onTap,
    this.onEdit,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : (address.isDefault
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : Colors.transparent),
          width: isSelected ? 2 : (address.isDefault ? 1.5 : 0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng 1: Tên người nhận & SĐT
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              address.recipientName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            height: 14,
                            width: 1,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          Text(
                            address.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Hàng 2: Địa chỉ cụ thể
                Text(
                  address.streetAddress,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),

                // Hàng 3: Phường/Xã, Quận/Huyện, Tỉnh/Thành
                Text(
                  '${address.ward}, ${address.district}, ${address.province}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Hàng 4: Các Tag phân loại (Loại địa chỉ & Mặc định)
                Row(
                  children: [
                    // Badge: Nhà riêng / Văn phòng
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            address.label == AddressLabel.office
                                ? Icons.business_outlined
                                : Icons.home_outlined,
                            size: 13,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            address.label.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge: Mặc định (Nếu có)
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          'Mặc định',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Nút bấm sửa dạng Text
                    if (onEdit != null)
                      GestureDetector(
                        onTap: onEdit,
                        child: Text(
                          'Chỉnh sửa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
