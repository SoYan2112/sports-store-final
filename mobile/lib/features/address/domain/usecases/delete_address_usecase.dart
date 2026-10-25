import '../repositories/address_repository.dart';

class DeleteAddressUseCase {
  final AddressRepository repository;

  DeleteAddressUseCase(this.repository);

  Future<void> call(String addressId) async {
    await repository.deleteAddress(addressId);
  }
}
