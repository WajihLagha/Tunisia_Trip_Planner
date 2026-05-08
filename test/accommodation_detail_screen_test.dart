import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunisian_trip_planner/features/accommodation/accommodation_detail_screen.dart';
import 'package:tunisian_trip_planner/features/accommodation/data/mock_accommodation_data.dart';
import 'package:tunisian_trip_planner/features/favourites/cubit/favourites_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets('AccommodationDetailScreen renders without errors', (WidgetTester tester) async {
    final hotel = MockAccommodationData.accommodations.first;
    
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<FavouritesCubit>(
          create: (_) => FavouritesCubit(),
          child: AccommodationDetailScreen(accommodation: hotel),
        ),
      ),
    );
    
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
