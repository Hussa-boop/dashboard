import 'package:dashboard/mobil/modules/screen_home/home_cubit/home_cubit.dart';
import 'package:dashboard/mobil/modules/screen_home/screen_map_parcel/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockHomeCubit extends Mock implements HomeCubit {}

void main() {
  late MockHomeCubit mockHomeCubit;

  setUp(() {
    mockHomeCubit = MockHomeCubit();
  });

  testWidgets('MapScreen should render correctly without tracking number', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const MapScreen(),
        ),
      ),
    );

    // Verify that the loading indicator is displayed initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MapScreen should render correctly with tracking number', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const MapScreen(trackingNumber: 'TRK-174510'),
        ),
      ),
    );

    // Verify that the loading indicator is displayed initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('MapScreen should have search functionality', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HomeCubit>.value(
          value: mockHomeCubit,
          child: const MapScreen(),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pump();

    // Verify that the search field is present
    expect(find.byType(TextField), findsOneWidget);
  });
}