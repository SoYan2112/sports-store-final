import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';
import '../models/address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AddressEntity>> getAddresses() async {
    return await remoteDataSource.getAddresses();
  }

  @override
  Future<AddressEntity> addAddress(AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    return await remoteDataSource.addAddress(model);
  }

  @override
  Future<AddressEntity> updateAddress(AddressEntity address) async {
    final model = AddressModel.fromEntity(address);
    return await remoteDataSource.updateAddress(model);
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    await remoteDataSource.deleteAddress(addressId);
  }

  @override
  Future<void> setDefaultAddress(String addressId) async {
    await remoteDataSource.setDefaultAddress(addressId);
  }
}
