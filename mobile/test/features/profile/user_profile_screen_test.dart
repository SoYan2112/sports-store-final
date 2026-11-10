import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/profile/domain/entities/user_profile_entity.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:mobile/features/profile/presentation/cubit/profile_state.dart';
import 'package:mobile/features/profile/presentation/screens/user_profile_screen.dart';

class MockProfileCubit extends MockCubit<ProfileState> implements ProfileCubit {}

void main() {
  late MockProfileCubit mockProfileCubit;

  final testProfile = UserProfileEntity(
    id: '1',
    fullname: 'Trần Hoàng Nhật',
    email: 'nhatth@gmail.com',
    phoneNumber: '0901234567',
    gender: 'Nam',
    createdAt: DateTime(2026, 1, 10),
    status: 'ACTIVE',
  );

  setUp(() {
    mockProfileCubit = MockProfileCubit();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<ProfileCubit>.value(
        value: mockProfileCubit,
        child: const UserProfileScreen(),
      ),
    );
  }

  group('UserProfileScreen Widget Tests', () {
    testWidgets('renders loading indicator when ProfileLoading', (tester) async {
      when(() => mockProfileCubit.state).thenReturn(const ProfileLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Hồ sơ cá nhân'), findsOneWidget);
    });

    testWidgets('renders all user profile details when ProfileLoaded', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      when(() => mockProfileCubit.state).thenReturn(ProfileLoaded(profile: testProfile));

      await tester.pumpWidget(buildTestWidget());

      // Header AppBar
      expect(find.text('Hồ sơ cá nhân'), findsOneWidget);

      // Avatar initial & text
      expect(find.text('T'), findsOneWidget);
      expect(find.text('Trần Hoàng Nhật'), findsNWidgets(2)); // Avatar card & Info row
      expect(find.text('nhatth@gmail.com'), findsNWidgets(2)); // Avatar card & Info row
      expect(find.text('Thành viên Thể thao'), findsOneWidget);

      // Section titles
      expect(find.text('Thông tin cá nhân'), findsOneWidget);

      // Detail fields
      expect(find.text('0901234567'), findsOneWidget);
      expect(find.text('Nam'), findsOneWidget);
      expect(find.text('10/01/2026'), findsOneWidget);
      expect(find.text('Hoạt động'), findsOneWidget);

      // Edit button
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
    });

    testWidgets('renders error view and triggers retry when ProfileError', (tester) async {
      when(() => mockProfileCubit.state).thenReturn(
        const ProfileError('Không thể kết nối máy chủ'),
      );
      when(() => mockProfileCubit.loadProfile()).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Không thể tải thông tin hồ sơ'), findsOneWidget);
      expect(find.text('Không thể kết nối máy chủ'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      // Bấm nút Thử lại
      await tester.tap(find.text('Thử lại'));
      await tester.pump();

      verify(() => mockProfileCubit.loadProfile()).called(1);
    });
  });
}
