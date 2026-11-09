import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/storage/local_storage_service.dart';
import 'package:mobile/features/profile/presentation/screens/change_password_screen.dart';

class MockDio extends Mock implements Dio {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockDio mockDio;
  late MockLocalStorageService mockStorageService;

  setUp(() {
    mockDio = MockDio();
    mockStorageService = MockLocalStorageService();
    when(() => mockStorageService.getAccessToken()).thenReturn('fake_token_123');
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangePasswordScreen(
                    dio: mockDio,
                    storageService: mockStorageService,
                  ),
                ),
              );
            },
            child: const Text('Open Change Password'),
          ),
        ),
      ),
    );
  }

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.tap(find.text('Open Change Password'));
    await tester.pumpAndSettle();
  }

  group('ChangePasswordScreen Widget Tests', () {
    testWidgets('renders all 3 password fields and action button',
        (tester) async {
      await openScreen(tester);

      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Bảo mật tài khoản'), findsOneWidget);
      expect(find.text('Mật khẩu hiện tại'), findsOneWidget);
      expect(find.text('Mật khẩu mới'), findsOneWidget);
      expect(find.text('Xác nhận mật khẩu mới'), findsOneWidget);
      expect(find.text('Cập nhật mật khẩu'), findsOneWidget);
      expect(find.byKey(const Key('submit_change_password_button')),
          findsOneWidget);
    });

    testWidgets('validates required fields when submitted empty',
        (tester) async {
      await openScreen(tester);

      await tester.tap(find.byKey(const Key('submit_change_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập mật khẩu hiện tại'), findsOneWidget);
      expect(find.text('Vui lòng nhập mật khẩu mới'), findsOneWidget);
      expect(find.text('Vui lòng xác nhận mật khẩu mới'), findsOneWidget);
    });

    testWidgets('validates new password min length 6 chars', (tester) async {
      await openScreen(tester);

      await tester.enterText(
          find.byKey(const Key('current_password_field')), 'oldpass123');
      await tester.enterText(
          find.byKey(const Key('new_password_field')), '12345');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), '12345');

      await tester.tap(find.byKey(const Key('submit_change_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu mới phải có ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('validates new password not same as current password',
        (tester) async {
      await openScreen(tester);

      await tester.enterText(
          find.byKey(const Key('current_password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('new_password_field')), 'password123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'password123');

      await tester.tap(find.byKey(const Key('submit_change_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu mới không được trùng mật khẩu cũ'),
          findsOneWidget);
    });

    testWidgets('validates confirm password matches new password',
        (tester) async {
      await openScreen(tester);

      await tester.enterText(
          find.byKey(const Key('current_password_field')), 'oldpass123');
      await tester.enterText(
          find.byKey(const Key('new_password_field')), 'newpass123');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'different123');

      await tester.tap(find.byKey(const Key('submit_change_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Mật khẩu xác nhận không khớp'), findsOneWidget);
    });

    testWidgets('toggles password visibility on suffix icon tap',
        (tester) async {
      await openScreen(tester);

      final visibilityOffIcons = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityOffIcons, findsNWidgets(3));

      await tester.tap(visibilityOffIcons.first);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });

    testWidgets('submits successfully and shows success snackbar',
        (tester) async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/auth/change-password'),
          statusCode: 200,
          data: {'success': true, 'message': 'Đổi mật khẩu thành công!'},
        ),
      );

      await openScreen(tester);

      await tester.enterText(
          find.byKey(const Key('current_password_field')), 'oldpass123');
      await tester.enterText(
          find.byKey(const Key('new_password_field')), 'newpass456');
      await tester.enterText(
          find.byKey(const Key('confirm_password_field')), 'newpass456');

      await tester.tap(find.byKey(const Key('submit_change_password_button')));
      await tester.pumpAndSettle();

      expect(find.text('Đổi mật khẩu thành công!'), findsOneWidget);
    });
  });
}
