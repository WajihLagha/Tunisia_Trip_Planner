import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunisian_trip_planner/features/transport/car_detail_screen.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';

void main() {
  testWidgets('CarDetailScreen renders without errors', (WidgetTester tester) async {
    final vehicle = VehicleModel(
      vehicleType: 'SUV',
      vehicleModel: 'Toyota Land Cruiser',
      vehicleYear: 2023,
      vehiclePlate: '123 TU 4567',
      vehicleCapacity: 5,
      vehiclePrice: 150.0,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: CarDetailScreen(vehicle: vehicle),
      ),
    );
    
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
