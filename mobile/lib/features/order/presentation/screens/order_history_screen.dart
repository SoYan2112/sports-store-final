import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/order_repository.dart';
import 'order_detail_screen.dart';

class _OrderItemData {
  final String orderId;
  final String date;
  String status;
  Color statusColor;
  final String productName;
  final String productInfo;
  final String total;
  final IconData icon;

  _OrderItemData({
    required this.orderId,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.productName,
    required this.productInfo,
    required this.total,
    required this.icon,
  });
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final List<_OrderItemData> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  // Tải và đồng bộ đơn hàng từ local storage
  Future<void> _loadOrders() async {
    try {
      final repository = getIt<OrderRepository>();
      final localOrders = await repository.getOrders();
      if (!mounted) return;

      setState(() {
        for (final item in _orders) {
          final match = localOrders
              .where((o) => o.id == item.orderId)
              .firstOrNull;
          if (match != null) {
            item.status = match.status;
            final lower = match.status.toLowerCase();
            if (lower.contains('hủy') || lower.contains('cancel')) {
              item.statusColor = Colors.red;
            } else if (lower.contains('chờ') || lower.contains('pending')) {
              item.statusColor = AppColors.primary;
            } else if (lower.contains('đang')) {
              item.statusColor = Colors.blue;
            } else {
              item.statusColor = Colors.green;
            }
          }
        }

        for (final order in localOrders) {
          final exists = _orders.any((item) => item.orderId == order.id);
          if (!exists) {
            final dateStr =
                '${order.createdAt.day.toString().padLeft(2, '0')}/${order.createdAt.month.toString().padLeft(2, '0')}/${order.createdAt.year}';
            final firstItem = order.items.isNotEmpty ? order.items.first : null;
            final lower = order.status.toLowerCase();
            final isCancelled =
                lower.contains('hủy') || lower.contains('cancel');
            final isPending =
                lower.contains('chờ') || lower.contains('pending');
            final isShipping = lower.contains('đang');

            _orders.insert(
              0,
              _OrderItemData(
                orderId: order.id,
                date: dateStr,
                status: order.status,
                statusColor: isCancelled
                    ? Colors.red
                    : (isPending
                          ? AppColors.primary
                          : (isShipping ? Colors.blue : Colors.green)),
                productName: firstItem?.name ?? 'Sản phẩm thể thao',
                productInfo: firstItem != null
                    ? 'Size ${firstItem.selectedSize} - x${firstItem.quantity}'
                    : 'Đơn hàng thể thao',
                total:
                    '${order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫',
                icon: Icons.directions_run_rounded,
              ),
            );
          }
        }
      });
    } catch (_) {}
  }

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
        children: [
          const Text(
            'Đơn hàng của bạn',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_orders.length} đơn hàng gần nhất',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          ..._orders.map((order) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _OrderCard(
                data: order,
                onStatusChanged: (newStatus) {
                  setState(() {
                    order.status = newStatus;
                    order.statusColor = Colors.red;
                  });
                  _loadOrders();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.data, this.onStatusChanged});

  final _OrderItemData data;
  final ValueChanged<String>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(
                orderId: data.orderId,
                date: data.date,
                status: data.status,
                statusColor: data.statusColor,
                productName: data.productName,
                productInfo: data.productInfo,
                total: data.total,
                icon: data.icon,
                onStatusChanged: (newStatus) {
                  data.status = newStatus;
                  data.statusColor = Colors.red;
                  onStatusChanged?.call(newStatus);
                },
              ),
            ),
          );
          onStatusChanged?.call(data.status);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '#${data.orderId}',
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
                    color: data.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    data.status,
                    style: TextStyle(
                      color: data.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày đặt: ${data.date}',
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
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(data.icon, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data.productInfo,
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
                  data.total,
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
      ),
    );
  }
}
