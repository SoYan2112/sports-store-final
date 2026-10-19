import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/voucher_entity.dart';

class VoucherCard extends StatelessWidget {
  final VoucherEntity voucher;
  final VoidCallback? onApply;

  const VoucherCard({
    super.key,
    required this.voucher,
    this.onApply,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: voucher.code));
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Đã sao chép mã "${voucher.code}" vào khay nhớ tạm!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUsable = voucher.isValid;

    Color badgeColor;
    IconData badgeIcon;

    switch (voucher.type) {
      case VoucherType.freeShipping:
        badgeColor = const Color(0xFF00897B); // Teal
        badgeIcon = Icons.local_shipping_outlined;
        break;
      case VoucherType.percentage:
        badgeColor = AppColors.primary; // Orange
        badgeIcon = Icons.percent_rounded;
        break;
      case VoucherType.fixedAmount:
        badgeColor = const Color(0xFF1E88E5); // Blue
        badgeIcon = Icons.confirmation_number_outlined;
        break;
    }

    return Opacity(
      opacity: isUsable ? 1.0 : 0.6,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUsable ? Colors.grey.shade200 : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cột trái: Huy hiệu loại voucher
              Container(
                width: 72,
                decoration: BoxDecoration(
                  color: isUsable ? badgeColor : Colors.grey.shade400,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      badgeIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        voucher.type == VoucherType.freeShipping
                            ? 'FREESHIP'
                            : (voucher.type == VoucherType.percentage
                                ? '-${voucher.discountValue.toInt()}%'
                                : 'GIẢM GIÁ'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Cột giữa: Chi tiết thông tin voucher
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tiêu đề & Nhãn giảm giá
                      Text(
                        voucher.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Mô tả điều kiện
                      Text(
                        voucher.formattedMinOrder,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isUsable ? AppColors.primary : Colors.grey.shade600,
                        ),
                      ),
                      if (voucher.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          voucher.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      // Ngày hết hạn
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: voucher.isExpired ? Colors.red : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            voucher.isExpired ? 'Đã hết hạn' : voucher.formattedExpiry,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: voucher.isExpired ? Colors.red : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Đường nét đứt ngăn cách (Dashed/Dotted divider effect)
              CustomPaint(
                size: const Size(1, double.infinity),
                painter: _DashedLinePainter(
                  color: Colors.grey.shade300,
                ),
              ),

              // 4. Cột phải: Mã code và nút Sao chép / Dùng
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Text(
                        voucher.code,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (onApply != null && isUsable)
                      SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: onApply,
                          child: const Text(
                            'Dùng ngay',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    else
                      SizedBox(
                        height: 30,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isUsable ? AppColors.primary : Colors.grey,
                            side: BorderSide(
                              color: isUsable ? AppColors.primary : Colors.grey.shade400,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: isUsable ? () => _copyToClipboard(context) : null,
                          child: Text(
                            isUsable ? 'Sao chép' : 'Hết hạn',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 4;

    while (startY < size.height - 4) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

