import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/presentation/cubit/auth_state.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit mockAuthCubit;

  setUp(() {
    mockAuthCubit = MockAuthCubit();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: mockAuthCubit,
        child: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Logout UI & Flow', () {
    testWidgets('renders user info and logout card when authenticated',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(
        const AuthAuthenticated(
          token: 'token_123',
          userId: '1',
          userName: 'Nguyễn Văn A',
          userEmail: 'a@gmail.com',
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // Kiểm tra tiêu đề màn hình
      expect(find.text('Tài khoản'), findsOneWidget);

      // Kiểm tra thẻ thông tin cá nhân (Avatar, Tên, Email)
      expect(find.text('N'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('a@gmail.com'), findsOneWidget);

      // Kiểm tra thẻ Kho Voucher & Ưu đãi
      expect(find.text('Kho Voucher & Ưu đãi'), findsOneWidget);
      expect(find.text('Xem mã giảm giá & freeship có sẵn'), findsOneWidget);

      // Kiểm tra thẻ Đăng xuất
      expect(find.text('Đăng xuất'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('tapping logout opens confirmation dialog and can cancel',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(
        const AuthAuthenticated(
          token: 'token_123',
          userId: '1',
          userName: 'Nguyễn Văn A',
          userEmail: 'a@gmail.com',
        ),
      );

      await tester.pumpWidget(buildTestWidget());

      // Bấm vào nút Đăng xuất
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      // Kiểm tra hiển thị AlertDialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Bạn có chắc chắn muốn đăng xuất không?'), findsOneWidget);
      expect(find.text('Hủy'), findsOneWidget);

      // Bấm Hủy
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      // Dialog đóng lại và không gọi logout
      expect(find.byType(AlertDialog), findsNothing);
      verifyNever(() => mockAuthCubit.logout());
    });

    testWidgets('confirming logout calls authCubit.logout()', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(
        const AuthAuthenticated(
          token: 'token_123',
          userId: '1',
          userName: 'Nguyễn Văn A',
          userEmail: 'a@gmail.com',
        ),
      );
      when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      // Bấm nút Đăng xuất để mở dialog
      await tester.tap(find.text('Đăng xuất'));
      await tester.pumpAndSettle();

      // Trong dialog có 2 nút "Đăng xuất" (1 ở card, 1 ở action button)
      // Tìm TextButton có chữ Đăng xuất
      final confirmBtn = find.widgetWithText(TextButton, 'Đăng xuất');
      expect(confirmBtn, findsOneWidget);

      await tester.tap(confirmBtn);
      await tester.pump();

      // Xác minh authCubit.logout() được gọi
      verify(() => mockAuthCubit.logout()).called(1);
    });
  });
}

