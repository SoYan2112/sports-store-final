import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/edit_profile_state.dart';
import 'package:mobile/features/profile/presentation/screens/edit_profile_screen.dart';

class MockEditProfileCubit extends MockCubit<EditProfileState>
    implements EditProfileCubit {}

void main() {
  late MockEditProfileCubit mockEditProfileCubit;

  final initialProfile = UserProfileEntity(
    id: '1',
    fullname: 'Trần Hoàng Nhật',
    email: 'nhatth@gmail.com',
    phoneNumber: '0901234567',
    gender: 'Nam',
    createdAt: DateTime(2026, 1, 10),
    status: 'ACTIVE',
  );

  setUpAll(() {
    registerFallbackValue(initialProfile);
  });

  setUp(() {
    mockEditProfileCubit = MockEditProfileCubit();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<EditProfileCubit>.value(
        value: mockEditProfileCubit,
        child: EditProfileScreen(initialProfile: initialProfile),
      ),
    );
  }

  group('EditProfileScreen Widget Tests', () {
    testWidgets('renders all fields with pre-filled profile information',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockEditProfileCubit.state).thenReturn(const EditProfileInitial());

      await tester.pumpWidget(buildTestWidget());

      // Header
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);

      // Pre-filled values
      expect(find.text('Trần Hoàng Nhật'), findsOneWidget);
      expect(find.text('nhatth@gmail.com'), findsOneWidget);
      expect(find.text('0901234567'), findsOneWidget);
      expect(find.text('Nam'), findsOneWidget);
      expect(find.text('Nữ'), findsOneWidget);
      expect(find.text('Khác'), findsOneWidget);

      // Save button
      expect(find.byKey(const Key('saveProfileButton')), findsOneWidget);
    });

    testWidgets('validates required name field', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockEditProfileCubit.state).thenReturn(const EditProfileInitial());

      await tester.pumpWidget(buildTestWidget());

      // Xóa họ tên và bấm Lưu
      await tester.enterText(find.byKey(const Key('nameField')), '');
      await tester.tap(find.byKey(const Key('saveProfileButton')));
      await tester.pump();

      expect(find.text('Vui lòng nhập họ và tên'), findsOneWidget);
      verifyNever(() => mockEditProfileCubit.updateProfile(any()));
    });

    testWidgets('validates Vietnamese phone format', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockEditProfileCubit.state).thenReturn(const EditProfileInitial());

      await tester.pumpWidget(buildTestWidget());

      // Nhập số điện thoại sai định dạng
      await tester.enterText(find.byKey(const Key('phoneField')), '123456');
      await tester.tap(find.byKey(const Key('saveProfileButton')));
      await tester.pump();

      expect(
        find.text('Số điện thoại không hợp lệ (ví dụ: 0901234567)'),
        findsOneWidget,
      );
      verifyNever(() => mockEditProfileCubit.updateProfile(any()));
    });

    testWidgets('triggers updateProfile when valid inputs are submitted',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockEditProfileCubit.state).thenReturn(const EditProfileInitial());
      when(() => mockEditProfileCubit.updateProfile(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      // Cập nhật tên và số điện thoại mới
      await tester.enterText(find.byKey(const Key('nameField')), 'Trần Hoàng Nhật Mới');
      await tester.enterText(find.byKey(const Key('phoneField')), '0987654321');
      await tester.tap(find.byKey(const Key('saveProfileButton')));
      await tester.pump();

      verify(() => mockEditProfileCubit.updateProfile(any(
            that: isA<UserProfileEntity>()
                .having((p) => p.fullname, 'fullname', 'Trần Hoàng Nhật Mới')
                .having((p) => p.phoneNumber, 'phoneNumber', '0987654321'),
          ))).called(1);
    });

    testWidgets('shows loading spinner when EditProfileLoading',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockEditProfileCubit.state).thenReturn(const EditProfileLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
