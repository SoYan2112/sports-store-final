import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/address_entity.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';
import '../widgets/address_card.dart';
import 'add_address_screen.dart';
import 'edit_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  final AddressCubit? cubit;
  final bool isSelectMode;
  final String? selectedAddressId;

  const AddressListScreen({
    super.key,
    this.cubit,
    this.isSelectMode = false,
    this.selectedAddressId,
  });

  static Route<AddressEntity?> route({
    AddressCubit? cubit,
    bool isSelectMode = false,
    String? selectedAddressId,
  }) {
    return MaterialPageRoute<AddressEntity?>(
      builder: (_) => AddressListScreen(
        cubit: cubit,
        isSelectMode: isSelectMode,
        selectedAddressId: selectedAddressId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCubit = cubit;
    if (activeCubit != null) {
      return BlocProvider.value(
        value: activeCubit,
        child: _AddressListView(
          isSelectMode: isSelectMode,
          selectedAddressId: selectedAddressId,
        ),
      );
    }

    return BlocProvider<AddressCubit>(
      create: (_) => getIt<AddressCubit>()..loadAddresses(),
      child: _AddressListView(
        isSelectMode: isSelectMode,
        selectedAddressId: selectedAddressId,
      ),
    );
  }
}

class _AddressListView extends StatelessWidget {
  final bool isSelectMode;
  final String? selectedAddressId;

  const _AddressListView({
    required this.isSelectMode,
    this.selectedAddressId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isSelectMode ? 'Chọn địa chỉ nhận hàng' : 'Địa chỉ của tôi',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is AddressError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 54,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<AddressCubit>().loadAddresses(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          List<AddressEntity> addresses = [];
          if (state is AddressLoaded) {
            addresses = state.addresses;
          } else if (state is AddressAddSuccess) {
            addresses = state.addresses;
          }

          if (addresses.isEmpty) {
            return _buildEmptyView(context);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<AddressCubit>().loadAddresses(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final item = addresses[index];
                final isSelected = isSelectMode && item.id == selectedAddressId;

                return AddressCard(
                  address: item,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelectMode) {
                      Navigator.of(context).pop(item);
                    } else {
                      final cubit = context.read<AddressCubit>();
                      Navigator.of(context).push(
                        EditAddressScreen.route(address: item, cubit: cubit),
                      );
                    }
                  },
                  onEdit: () {
                    final cubit = context.read<AddressCubit>();
                    Navigator.of(context).push(
                      EditAddressScreen.route(address: item, cubit: cubit),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            key: const Key('addNewAddressButton'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 1,
            ),
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text(
              'Thêm địa chỉ mới',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () async {
              final cubit = context.read<AddressCubit>();
              await Navigator.of(context).push(
                AddAddressScreen.route(cubit: cubit),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Chưa có địa chỉ giao hàng nào',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thêm địa chỉ nhận hàng để việc đặt đồ thể thao trở nên nhanh chóng và thuận tiện nhất.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add_location_alt_outlined, size: 20),
              label: const Text(
                'Thêm địa chỉ ngay',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              onPressed: () async {
                final cubit = context.read<AddressCubit>();
                await Navigator.of(context).push(
                  AddAddressScreen.route(cubit: cubit),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
