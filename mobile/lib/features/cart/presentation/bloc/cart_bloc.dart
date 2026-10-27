import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddToCartUseCase addToCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final RemoveFromCartUseCase removeFromCartUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addToCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.removeFromCartUseCase,
    required this.clearCartUseCase,
  }) : super(const CartInitial()) {
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveItem);
    on<ClearCartEvent>(_onClearCart);
    on<ResetCartEvent>(_onResetCart);
  }

  Future<void> _onLoadCart(
    LoadCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());
    try {
      final items = await getCartUseCase();
      emit(CartLoaded(items: items));
    } catch (e) {
      emit(CartError('Không thể tải giỏ hàng: ${e.toString()}'));
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems =
        state is CartLoaded ? (state as CartLoaded).items : <CartItemEntity>[];
    try {
      final updatedList = await addToCartUseCase(
        currentItems: currentItems,
        newItem: event.item,
      );
      emit(CartLoaded(
        items: updatedList,
        lastAddedItem: event.item,
        notificationMessage: 'Đã thêm ${event.item.name} vào giỏ hàng!',
      ));
    } catch (e) {
      emit(CartError('Không thể thêm vào giỏ hàng: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems =
        state is CartLoaded ? (state as CartLoaded).items : <CartItemEntity>[];
    try {
      final updatedList = await updateCartQuantityUseCase(
        currentItems: currentItems,
        itemId: event.itemId,
        newQuantity: event.quantity,
      );
      emit(CartLoaded(items: updatedList));
    } catch (e) {
      emit(CartError('Không thể cập nhật số lượng: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveItem(
    RemoveCartItemEvent event,
    Emitter<CartState> emit,
  ) async {
    final currentItems =
        state is CartLoaded ? (state as CartLoaded).items : <CartItemEntity>[];
    try {
      final updatedList = await removeFromCartUseCase(
        currentItems: currentItems,
        itemId: event.itemId,
      );
      emit(CartLoaded(items: updatedList));
    } catch (e) {
      emit(CartError('Không thể xóa sản phẩm khỏi giỏ hàng: ${e.toString()}'));
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      await clearCartUseCase();
      emit(const CartLoaded(items: []));
    } catch (e) {
      emit(CartError('Không thể làm trống giỏ hàng: ${e.toString()}'));
    }
  }

  void _onResetCart(
    ResetCartEvent event,
    Emitter<CartState> emit,
  ) {
    emit(const CartLoaded(items: []));
  }
}
