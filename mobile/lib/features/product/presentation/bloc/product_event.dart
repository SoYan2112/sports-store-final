import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Lấy danh sách sản phẩm lần đầu hoặc Pull-to-Refresh
class FetchProductsEvent extends ProductEvent {
  final bool isRefresh;
  final String? categoryId;
  final String? keyword;

  const FetchProductsEvent({
    this.isRefresh = false,
    this.categoryId,
    this.keyword,
  });

  @override
  List<Object?> get props => [isRefresh, categoryId, keyword];
}

/// Phân trang Infinite Scroll: tải thêm sản phẩm khi cuộn tới cuối danh sách
class FetchMoreProductsEvent extends ProductEvent {
  const FetchMoreProductsEvent();
}
