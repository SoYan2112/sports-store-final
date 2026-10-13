import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile/app/app.dart';

void main() {
  testWidgets('SportsStoreApp starts at login page', (tester) async {
    await tester.pumpWidget(const SportsStoreApp());

    expect(find.byKey(const Key('loginButton')), findsOneWidget);
    expect(
      find.text('Demo account: an@sportsstore.com / 123456'),
      findsOneWidget,
    );
  });
}
