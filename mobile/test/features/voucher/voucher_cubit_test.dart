import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/voucher/domain/entities/voucher_entity.dart';
import 'package:mobile/features/voucher/domain/usecases/get_vouchers_usecase.dart';
import 'package:mobile/features/voucher/presentation/cubit/voucher_cubit.dart';
import 'package:mobile/features/voucher/presentation/cubit/voucher_state.dart';

class MockGetVouchersUseCase extends Mock implements GetVouchersUseCase {}

void main() {
  late MockGetVouchersUseCase mockGetVouchersUseCase;
  late VoucherCubit voucherCubit;

  final tNow = DateTime.now();
  final tVouchers = [
    VoucherEntity(
      id: 'v_summer20',
      code: 'SUMMER20',
      title: 'Giảm 20% đơn từ 400k',
      description: 'Áp dụng cho toàn bộ đồ thể thao',
      type: VoucherType.percentage,
      discountValue: 20,
      minOrderValue: 400000,
      startDate: tNow.subtract(const Duration(days: 1)),
      endDate: tNow.add(const Duration(days: 10)),
    ),
    VoucherEntity(
      id: 'v_freeship',
      code: 'FREESHIP',
      title: 'Miễn phí vận chuyển',
      description: 'Freeship đơn từ 300k',
      type: VoucherType.freeShipping,
      discountValue: 35000,
      minOrderValue: 300000,
      startDate: tNow.subtract(const Duration(days: 1)),
      endDate: tNow.add(const Duration(days: 10)),
    ),
  ];

  setUp(() {
    mockGetVouchersUseCase = MockGetVouchersUseCase();
    voucherCubit = VoucherCubit(getVouchersUseCase: mockGetVouchersUseCase);
  });

  tearDown(() {
    voucherCubit.close();
  });

  group('VoucherCubit', () {
    test('initial state should be VoucherInitial', () {
      expect(voucherCubit.state, const VoucherInitial());
    });

    blocTest<VoucherCubit, VoucherState>(
      'emits [VoucherLoading, VoucherLoaded] when fetchVouchers succeeds',
      build: () {
        when(() => mockGetVouchersUseCase())
            .thenAnswer((_) async => tVouchers);
        return voucherCubit;
      },
      act: (cubit) => cubit.fetchVouchers(),
      expect: () => [
        const VoucherLoading(),
        VoucherLoaded(vouchers: tVouchers),
      ],
      verify: (_) {
        verify(() => mockGetVouchersUseCase()).called(1);
      },
    );

    blocTest<VoucherCubit, VoucherState>(
      'emits [VoucherLoading, VoucherError] when fetchVouchers fails',
      build: () {
        when(() => mockGetVouchersUseCase())
            .thenThrow(Exception('Server error'));
        return voucherCubit;
      },
      act: (cubit) => cubit.fetchVouchers(),
      expect: () => [
        const VoucherLoading(),
        const VoucherError(
          message: 'Không thể tải danh sách voucher ưu đãi. Vui lòng thử lại.',
        ),
      ],
      verify: (_) {
        verify(() => mockGetVouchersUseCase()).called(1);
      },
    );
  });
}

