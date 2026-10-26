import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {
  const AddressInitial();
}

class AddressLoading extends AddressState {
  const AddressLoading();
}

class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressLoaded({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}

class AddressAddLoading extends AddressState {
  const AddressAddLoading();
}

class AddressAddSuccess extends AddressState {
  final AddressEntity newAddress;
  final List<AddressEntity> addresses;

  const AddressAddSuccess({
    required this.newAddress,
    required this.addresses,
  });

  @override
  List<Object?> get props => [newAddress, addresses];
}

class AddressUpdateLoading extends AddressState {
  const AddressUpdateLoading();
}

class AddressUpdateSuccess extends AddressState {
  final AddressEntity updatedAddress;
  final List<AddressEntity> addresses;

  const AddressUpdateSuccess({
    required this.updatedAddress,
    required this.addresses,
  });

  @override
  List<Object?> get props => [updatedAddress, addresses];
}

class AddressDeleteLoading extends AddressState {
  const AddressDeleteLoading();
}

class AddressDeleteSuccess extends AddressState {
  final String deletedAddressId;
  final List<AddressEntity> addresses;

  const AddressDeleteSuccess({
    required this.deletedAddressId,
    required this.addresses,
  });

  @override
  List<Object?> get props => [deletedAddressId, addresses];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
