import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/transport/cubit/transport_states.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';
import 'package:tunisian_trip_planner/features/transport/enums/transport_type.dart';
import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_image_model.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';
import 'package:flutter/foundation.dart';

class TransportCubit extends Cubit<TransportStates> {
  TransportCubit() : super(TransportInitialState());

  static TransportCubit get(context) => BlocProvider.of(context);

  String selectedCity = 'All';

  // All transports (unfiltered)
  List<TransportModel> _allTransports = [];

  // Filtered transports based on selected city
  List<TransportModel> get filteredTransports {
    if (selectedCity == 'All') return _allTransports;
    return _allTransports
        .where((t) => t.cityId.toLowerCase() == selectedCity.toLowerCase())
        .toList();
  }

  Future<void> loadTransports() async {
    emit(TransportLoadingState());
    try {
      final response = await DioHelper.getData(url: EndPoints.transports);
      if (response.statusCode == 200) {
        // Handle both paginated response ('content') or direct list
        final List<dynamic> data = response.data['content'] ?? response.data;
        // Parse basic transport data
        List<TransportModel> baseTransports = data.map((json) => TransportModel.fromJson(json)).toList();
        
        // Fetch images and vehicles for each transport concurrently
        _allTransports = await Future.wait(
          baseTransports.map((t) async {
            if (t.id == null) return t;

            List<TransportImageModel> fetchedImages = t.images;
            List<VehicleModel> fetchedVehicles = t.vehicles;

            try {
              // Concurrently fetch both images and vehicles for this transport
              dynamic imgResponse;
              dynamic vehResponse;

              await Future.wait([
                () async {
                  try {
                    imgResponse = await DioHelper.getData(url: EndPoints.transportImagesByTransport(t.id!));
                  } catch (_) {}
                }(),
                () async {
                  try {
                    vehResponse = await DioHelper.getData(url: EndPoints.vehiclesByTransport(t.id!));
                  } catch (_) {}
                }(),
              ]);

              if (imgResponse != null && imgResponse?.statusCode == 200) {
                final List<dynamic> imgData = imgResponse.data;
                fetchedImages = imgData.map((e) => TransportImageModel.fromJson(e)).toList();
              }

              if (vehResponse != null && vehResponse?.statusCode == 200) {
                final List<dynamic> vehData = vehResponse.data;
                fetchedVehicles = vehData.map((e) => VehicleModel.fromJson(e)).toList();
              }
            } catch (e) {
              debugPrint('[TransportCubit] Error enriching transport ${t.id}: $e');
            }

            return t.copyWith(images: fetchedImages, vehicles: fetchedVehicles);
          }),
        );
        
        emit(TransportLoadedState(
          transports: filteredTransports,
          selectedCity: selectedCity,
        ));
      } else {
        emit(TransportErrorState('Failed to load transports: ${response.statusCode}'));
      }
    } catch (e) {
      debugPrint('[TransportCubit] Error loading transports from API: $e');
      // Fallback to mock data during local development if API is unreachable
      debugPrint('[TransportCubit] Falling back to mock data...');
      _allTransports = _getMockTransports();
      emit(TransportLoadedState(
        transports: filteredTransports,
        selectedCity: selectedCity,
      ));
    }
  }

  void filterByCity(String city) {
    selectedCity = city;
    emit(TransportLoadedState(
      transports: filteredTransports,
      selectedCity: selectedCity,
    ));
  }

  // ── Mock data ──────────────────────────────────────────
  List<TransportModel> _getMockTransports() {
    return [
      TransportModel(
        id: 1,
        name: 'Sahara Explorers',
        description:
            'Experience the Mediterranean coast with our curated fleet of luxury vehicles. We specialize in providing seamless journeys from the bustling medinas to the serene oasis resorts. Every vehicle is meticulously maintained to ensure your comfort, safety, and a touch of elegance on every road.',
        type: TransportType.carRental,
        averageRating: 4.9,
        totalReviews: 124,
        cityId: 'Tunis',
        address: 'Avenue Habib Bourguiba, Tunis, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 71 234 567',
        contactEmail: 'contact@saharaexplorers.tn',
        priceMin: 85.0,
        priceMax: 450.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 1,
            transportId: 1,
            vehicleType: 'Luxury SUV',
            vehicleModel: 'Range Rover Velar',
            vehicleYear: 2024,
            vehicleColor: 'Santorini Black',
            vehicleCapacity: 5,
            vehiclePrice: 180,
            fuelType: FuelType.diesel,
            quantity: 2,
          ),
          VehicleModel(
            id: 2,
            transportId: 1,
            vehicleType: 'Convertible',
            vehicleModel: 'Porsche Cayenne',
            vehicleYear: 2023,
            vehicleColor: 'Carrara White',
            vehicleCapacity: 5,
            vehiclePrice: 350,
            fuelType: FuelType.petrol,
            quantity: 1,
          ),
          VehicleModel(
            id: 3,
            transportId: 1,
            vehicleType: 'SUV',
            vehicleModel: 'Mercedes-Benz G-Class',
            vehicleYear: 2024,
            vehicleColor: 'Obsidian Black',
            vehicleCapacity: 5,
            vehiclePrice: 450,
            fuelType: FuelType.diesel,
            quantity: 1,
          ),
        ],
      ),
      TransportModel(
        id: 2,
        name: 'Azure Coast Travel',
        description:
            'Coastal transport and excursion services along the Mediterranean. From Sousse\'s medina to the pristine beaches of Port El Kantaoui, we make every journey an experience.',
        type: TransportType.carRental,
        averageRating: 4.7,
        totalReviews: 89,
        cityId: 'Sousse',
        address: 'Rue de la Plage, Sousse, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 73 456 789',
        contactEmail: 'info@azurecoast.tn',
        priceMin: 65.0,
        priceMax: 95.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 4,
            transportId: 2,
            vehicleType: 'Sedan',
            vehicleModel: 'Toyota Corolla',
            vehicleYear: 2023,
            vehicleColor: 'Silver Metallic',
            vehicleCapacity: 5,
            vehiclePrice: 65,
            fuelType: FuelType.petrol,
            quantity: 3,
          ),
          VehicleModel(
            id: 5,
            transportId: 2,
            vehicleType: 'SUV',
            vehicleModel: 'Hyundai Tucson',
            vehicleYear: 2024,
            vehicleColor: 'Amazon Grey',
            vehicleCapacity: 5,
            vehiclePrice: 95,
            fuelType: FuelType.diesel,
            quantity: 2,
          ),
        ],
      ),
      TransportModel(
        id: 3,
        name: 'Medina Heritage Tours',
        description:
            'Cultural heritage transport services in historic city centers. Explore Tunis, Carthage, and Sidi Bou Said with our knowledgeable drivers.',
        type: TransportType.taxi,
        averageRating: 4.8,
        totalReviews: 210,
        cityId: 'Tunis',
        address: 'Place de la Kasbah, Tunis, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 71 987 654',
        contactEmail: 'tours@medinaheritage.tn',
        priceMin: 55.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 6,
            transportId: 3,
            vehicleType: 'Van',
            vehicleModel: 'Mercedes V-Class',
            vehicleYear: 2024,
            vehicleColor: 'Selenite Grey',
            vehicleCapacity: 7,
            vehiclePrice: 150,
            fuelType: FuelType.hybrid,
            quantity: 2,
          ),
          VehicleModel(
            id: 7,
            transportId: 3,
            vehicleType: 'Van',
            vehicleModel: 'VW Multivan',
            vehicleYear: 2023,
            vehicleColor: 'Starlight Blue',
            vehicleCapacity: 7,
            vehiclePrice: 120,
            fuelType: FuelType.diesel,
            quantity: 1,
          ),
        ],
      ),
      TransportModel(
        id: 4,
        name: 'Carthage Express',
        description:
            'Fast and reliable bus service connecting major Tunisian cities. Comfortable seats, AC, and WiFi on board.',
        type: TransportType.bus,
        averageRating: 4.5,
        totalReviews: 312,
        cityId: 'Ariana',
        address: 'Gare Routière, Ariana, Tunisia',
        stripeOnboarded: false,
        contactPhone: '+216 71 111 222',
        contactEmail: 'booking@carthageexpress.tn',
        priceMin: 25.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 8,
            transportId: 4,
            vehicleType: 'Bus',
            vehicleModel: 'Iveco Magelys',
            vehicleYear: 2022,
            vehicleColor: 'White',
            vehicleCapacity: 50,
            vehiclePrice: 25,
            fuelType: FuelType.diesel,
            quantity: 5,
          ),
        ],
      ),
      TransportModel(
        id: 5,
        name: 'Djerba Sun Rides',
        description:
            'Island transport with scenic coastal routes. Electric vehicles for a green travel experience on Djerba island.',
        type: TransportType.carRental,
        averageRating: 4.6,
        totalReviews: 67,
        cityId: 'Médenine',
        address: 'Zone Touristique, Djerba, Médenine',
        stripeOnboarded: true,
        contactPhone: '+216 75 222 333',
        contactEmail: 'rent@djerbarides.tn',
        priceMin: 90.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 9,
            transportId: 5,
            vehicleType: 'Electric Sedan',
            vehicleModel: 'Tesla Model 3',
            vehicleYear: 2024,
            vehicleColor: 'Pearl White',
            vehicleCapacity: 5,
            vehiclePrice: 200,
            fuelType: FuelType.electric,
            quantity: 2,
          ),
          VehicleModel(
            id: 10,
            transportId: 5,
            vehicleType: 'Electric Hatchback',
            vehicleModel: 'Renault Zoe',
            vehicleYear: 2023,
            vehicleColor: 'Highland Grey',
            vehicleCapacity: 5,
            vehiclePrice: 80,
            fuelType: FuelType.electric,
            quantity: 3,
          ),
        ],
      ),
      TransportModel(
        id: 6,
        name: 'Sfax City Cabs',
        description:
            'Reliable taxi network covering greater Sfax area. Available 24/7 for airport transfers and city rides.',
        type: TransportType.taxi,
        averageRating: 4.3,
        totalReviews: 156,
        cityId: 'Sfax',
        address: 'Centre Ville, Sfax, Tunisia',
        stripeOnboarded: false,
        contactPhone: '+216 74 333 444',
        contactEmail: 'dispatch@sfaxcabs.tn',
        priceMin: 30.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 11,
            transportId: 6,
            vehicleType: 'Sedan',
            vehicleModel: 'Peugeot 301',
            vehicleYear: 2022,
            vehicleColor: 'Iron Grey',
            vehicleCapacity: 5,
            vehiclePrice: 30,
            fuelType: FuelType.petrol,
            quantity: 8,
          ),
        ],
      ),
      TransportModel(
        id: 7,
        name: 'Kairouan Heritage Rides',
        description:
            'Comfortable rides through the holy city and surrounding areas. Discover the Great Mosque and historic sites in style.',
        type: TransportType.carRental,
        averageRating: 4.4,
        totalReviews: 93,
        cityId: 'Kairouan',
        address: 'Avenue de la République, Kairouan, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 77 444 555',
        contactEmail: 'info@kairouanrides.tn',
        priceMin: 70.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 12,
            transportId: 7,
            vehicleType: 'SUV',
            vehicleModel: 'Toyota RAV4 Hybrid',
            vehicleYear: 2024,
            vehicleColor: 'Lunar Rock',
            vehicleCapacity: 5,
            vehiclePrice: 110,
            fuelType: FuelType.hybrid,
            quantity: 2,
          ),
          VehicleModel(
            id: 13,
            transportId: 7,
            vehicleType: 'SUV',
            vehicleModel: 'Kia Sportage',
            vehicleYear: 2023,
            vehicleColor: 'Snow White Pearl',
            vehicleCapacity: 5,
            vehiclePrice: 85,
            fuelType: FuelType.diesel,
            quantity: 1,
          ),
        ],
      ),
      TransportModel(
        id: 8,
        name: 'Bizerte Blue Lagoon Transport',
        description:
            'Scenic coastal transport services in northern Tunisia. Perfect for exploring Bizerte\'s old port and beautiful lagoons.',
        type: TransportType.carRental,
        averageRating: 4.7,
        totalReviews: 78,
        cityId: 'Bizerte',
        address: 'Port de Plaisance, Bizerte, Tunisia',
        stripeOnboarded: false,
        contactPhone: '+216 72 555 666',
        contactEmail: 'reservations@bluelagoon.tn',
        priceMin: 60.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 14,
            transportId: 8,
            vehicleType: 'SUV',
            vehicleModel: 'Dacia Duster',
            vehicleYear: 2023,
            vehicleColor: 'Slate Grey',
            vehicleCapacity: 5,
            vehiclePrice: 55,
            fuelType: FuelType.petrol,
            quantity: 3,
          ),
        ],
      ),
      TransportModel(
        id: 9,
        name: 'Tozeur Oasis Shuttle',
        description:
            'Desert oasis excursions and airport transfers. Explore Chebika, Tamerza, and Mides canyons with experienced local guides.',
        type: TransportType.bus,
        averageRating: 4.8,
        totalReviews: 45,
        cityId: 'Tozeur',
        address: 'Place des Martyrs, Tozeur, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 76 666 777',
        contactEmail: 'tours@oasisshuttle.tn',
        priceMin: 40.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 15,
            transportId: 9,
            vehicleType: 'Luxury SUV',
            vehicleModel: 'Toyota Land Cruiser',
            vehicleYear: 2024,
            vehicleColor: 'Magnetic Grey',
            vehicleCapacity: 7,
            vehiclePrice: 250,
            fuelType: FuelType.diesel,
            quantity: 2,
          ),
          VehicleModel(
            id: 16,
            transportId: 9,
            vehicleType: 'Minibus',
            vehicleModel: 'Mercedes Sprinter',
            vehicleYear: 2023,
            vehicleColor: 'Arctic White',
            vehicleCapacity: 16,
            vehiclePrice: 180,
            fuelType: FuelType.diesel,
            quantity: 1,
          ),
        ],
      ),
      TransportModel(
        id: 10,
        name: 'Nabeul Comfort Cars',
        description:
            'Premium car rental for Cap Bon peninsula exploration. From Hammamet beaches to Kelibia fortress, travel in comfort.',
        type: TransportType.carRental,
        averageRating: 4.5,
        totalReviews: 102,
        cityId: 'Nabeul',
        address: 'Avenue Habib Thameur, Nabeul, Tunisia',
        stripeOnboarded: true,
        contactPhone: '+216 72 777 888',
        contactEmail: 'rent@nabeulcars.tn',
        priceMin: 75.0,
        images: [],
        vehicles: [
          VehicleModel(
            id: 17,
            transportId: 10,
            vehicleType: 'Hatchback',
            vehicleModel: 'Volkswagen Golf',
            vehicleYear: 2023,
            vehicleColor: 'Atlantic Blue',
            vehicleCapacity: 5,
            vehiclePrice: 70,
            fuelType: FuelType.petrol,
            quantity: 4,
          ),
          VehicleModel(
            id: 18,
            transportId: 10,
            vehicleType: 'SUV',
            vehicleModel: 'BMW X3',
            vehicleYear: 2024,
            vehicleColor: 'Carbon Black',
            vehicleCapacity: 5,
            vehiclePrice: 160,
            fuelType: FuelType.diesel,
            quantity: 1,
          ),
        ],
      ),
    ];
  }
}
