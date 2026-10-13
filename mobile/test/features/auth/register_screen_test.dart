import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:mobile/features/auth/presentation/cubit/register_cubit.dart';
import 'package:mobile/features/auth/presentation/screens/register_screen.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class FakeRegisterParams extends Fake implements RegisterParams {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late RegisterCubit registerCubit;

  final tUser = User(
    id: 1,
    fullname: 'Trần Hoàng Nhật',
    email: 'hoangnhat@example.com',
    phoneNumber: '0901234567',
    password: 'password123',
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(FakeRegisterParams());
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    registerCubit = RegisterCubit(registerUseCase: mockRegisterUseCase);
  });

  tearDown(() {
    registerCubit.close();
  });

  Widget createWidgetUnderTest({void Function(User user)? onRegisterSuccess}) {
    return MaterialApp(
      home: BlocProvider<RegisterCubit>.value(
        value: registerCubit,
        child: RegisterScreen(onRegisterSuccess: onRegisterSuccess),
      ),
    );
  }

  testWidgets(
      'RegisterScreen renders title, all input fields, and register CTA button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    // Kiểm tra tiêu đề chính
    expect(find.text('TẠO TÀI KHOẢN'), findsOneWidget);

    // Kiểm tra các trường nhập liệu
    expect(find.byKey(const Key('fullnameField')), findsOneWidget);
    expect(find.byKey(const Key('emailField')), findsOneWidget);
    expect(find.byKey(const Key('phoneField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);

    // Kiểm tra nút Đăng ký
    expect(find.byKey(const Key('registerButton')), findsOneWidget);
    expect(find.text('ĐĂNG KÝ NGAY'), findsOneWidget);
  });

  testWidgets(
      'RegisterScreen shows inline validation errors when fields are empty',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    final registerButton = find.byKey(const Key('registerButton'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    // Kiểm tra các lỗi inline xuất hiện
    expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
    expect(find.text('Vui lòng nhập địa chỉ email'), findsOneWidget);
    expect(find.text('Vui lòng nhập số điện thoại'), findsOneWidget);
    expect(find.text('Vui lòng nhập mật khẩu'), findsOneWidget);
    expect(find.text('Vui lòng xác nhận lại mật khẩu'), findsOneWidget);
  });

  testWidgets(
      'RegisterScreen shows error when Vietnamese phone number is invalid',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(
        find.byKey(const Key('fullnameField')), 'Trần Hoàng Nhật');
    await tester.enterText(
        find.byKey(const Key('emailField')), 'hoangnhat@gmail.com');
    await tester.enterText(
        find.byKey(const Key('phoneField')), '123456'); // SĐT không hợp lệ
    await tester.enterText(
        find.byKey(const Key('passwordField')), '123456');
    await tester.enterText(
        find.byKey(const Key('confirmPasswordField')), '123456');

    final registerButton = find.byKey(const Key('registerButton'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Số điện thoại không hợp lệ.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'RegisterScreen shows error when email format is invalid',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createWidgetUnderTest());

    await tester.enterText(
        find.byKey(const Key('fullnameField')), 'Trần Hoàng Nhật');
    await tester.enterText(
        find.byKey(const Key('emailField')), 'invalid-email-format'); // Email sai định dạng
    await tester.enterText(
        find.byKey(const Key('phoneField')), '0901234567');
    await tester.enterText(
        find.byKey(const Key('passwordField')), '123456');
    await tester.enterText(
        find.byKey(const Key('confirmPasswordField')), '123456');

    final registerButton = find.byKey(const Key('registerButton'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Email không hợp lệ (ví dụ: user@example.com)'),
      findsOneWidget,
    );
  });

  testWidgets('RegisterScreen calls register when all inputs are valid',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    when(() => mockRegisterUseCase(any())).thenAnswer((_) async => tUser);

    var callbackCalled = false;
    await tester.pumpWidget(createWidgetUnderTest(
      onRegisterSuccess: (user) {
        callbackCalled = true;
      },
    ));

    await tester.enterText(
        find.byKey(const Key('fullnameField')), 'Trần Hoàng Nhật');
    await tester.enterText(
        find.byKey(const Key('emailField')), 'hoangnhat@gmail.com');
    await tester.enterText(
        find.byKey(const Key('phoneField')), '0901234567');
    await tester.enterText(
        find.byKey(const Key('passwordField')), '123456');
    await tester.enterText(
        find.byKey(const Key('confirmPasswordField')), '123456');

    final registerButton = find.byKey(const Key('registerButton'));
    await tester.ensureVisible(registerButton);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    verify(() => mockRegisterUseCase(any())).called(1);
    expect(callbackCalled, isTrue);
  });
}
