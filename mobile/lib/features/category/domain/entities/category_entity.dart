import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String description;
  final int itemCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.description = '',
    this.itemCount = 0,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, description, itemCount];
}

