import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch sử đơn hàng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Đơn hàng của bạn',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Dữ liệu mẫu - 3 đơn hàng',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: 20),
          _OrderCard(
            orderId: 'SS000123',
            date: '25/10/2026',
            status: 'Chờ xác nhận',
            statusColor: AppColors.primary,
            productName: 'Giày Nike Air Zoom Pegasus',
            productInfo: 'Size 42 - Đen - x1',
            total: '2.500.000 ₫',
            icon: Icons.directions_run_rounded,
          ),
          SizedBox(height: 16),
          _OrderCard(
            orderId: 'SS000122',
            date: '22/10/2026',
            status: 'Đang giao',
            statusColor: Colors.blue,
            productName: 'Áo thể thao Adidas Training',
            productInfo: 'Size L - Trắng - x2',
            total: '1.200.000 ₫',
            icon: Icons.checkroom_rounded,
          ),
          SizedBox(height: 16),
          _OrderCard(
            orderId: 'SS000118',
            date: '15/10/2026',
            status: 'Đã giao',
            statusColor: Colors.green,
            productName: 'Bóng đá Puma Orbita',
            productInfo: 'Size 5 - Trắng - x1',
            total: '650.000 ₫',
            icon: Icons.sports_soccer_rounded,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.orderId,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.productName,
    required this.productInfo,
    required this.total,
    required this.icon,
  });

  final String orderId;
  final String date;
  final String status;
  final Color statusColor;
  final String productName;
  final String productInfo;
  final String total;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '#$orderId',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ngày đặt: $date',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const Divider(height: 28),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      productInfo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Tổng thanh toán',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
