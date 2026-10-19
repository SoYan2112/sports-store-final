import 'package:equatable/equatable.dart';
import '../../domain/entities/voucher_entity.dart';

abstract class VoucherState extends Equatable {
  const VoucherState();

  @override
  List<Object?> get props => [];
}

class VoucherInitial extends VoucherState {
  const VoucherInitial();
}

class VoucherLoading extends VoucherState {
  const VoucherLoading();
}

class VoucherLoaded extends VoucherState {
  final List<VoucherEntity> vouchers;

  const VoucherLoaded({required this.vouchers});

  @override
  List<Object?> get props => [vouchers];
}

class VoucherError extends VoucherState {
  final String message;

  const VoucherError({required this.message});

  @override
  List<Object?> get props => [message];
}

