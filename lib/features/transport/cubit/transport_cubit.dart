import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tunisian_trip_planner/features/transport/cubit/transport_states.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_availability_model.dart';
import 'package:tunisian_trip_planner/features/transport/enums/transport_type.dart';
import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';

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
        .where((t) => t.city.toLowerCase() == selectedCity.toLowerCase())
        .toList();
  }

  void loadTransports() {
    emit(TransportLoadingState());
    try {
      // Mock data — replace with API call later
      _allTransports = _getMockTransports();
      emit(TransportLoadedState(
        transports: filteredTransports,
        selectedCity: selectedCity,
      ));
    } catch (e) {
      emit(TransportErrorState(e.toString()));
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
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.DIESEL,
        rating: 4.9,
        reviewCount: 124,
        city: 'Tunis',
        address: 'Avenue Habib Bourguiba, Tunis, Tunisia',
        isFeatured: true,
        isVerifiedPartner: true,
        phone: '+216 71 234 567',
        email: 'contact@saharaexplorers.tn',
        pricePerDay: 85.0,
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
            fuelType: FuelType.DIESEL,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 1, vehicleId: 1, isAvailable: true),
            ],
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
            fuelType: FuelType.PETROL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 2, vehicleId: 2, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 3, vehicleId: 3, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 2,
        name: 'Azure Coast Travel',
        description:
            'Coastal transport and excursion services along the Mediterranean. From Sousse\'s medina to the pristine beaches of Port El Kantaoui, we make every journey an experience.',
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.PETROL,
        rating: 4.7,
        reviewCount: 89,
        city: 'Sousse',
        address: 'Rue de la Plage, Sousse, Tunisia',
        isFeatured: false,
        isVerifiedPartner: true,
        phone: '+216 73 456 789',
        email: 'info@azurecoast.tn',
        pricePerDay: 65.0,
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
            fuelType: FuelType.PETROL,
            quantity: 3,
            availabilities: const [
              VehicleAvailabilityModel(id: 4, vehicleId: 4, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 5, vehicleId: 5, isAvailable: false),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 3,
        name: 'Medina Heritage Tours',
        description:
            'Cultural heritage transport services in historic city centers. Explore Tunis, Carthage, and Sidi Bou Said with our knowledgeable drivers.',
        type: TransportType.TAXI,
        fuelType: FuelType.HYBRID,
        rating: 4.8,
        reviewCount: 210,
        city: 'Tunis',
        address: 'Place de la Kasbah, Tunis, Tunisia',
        isFeatured: false,
        isVerifiedPartner: true,
        phone: '+216 71 987 654',
        email: 'tours@medinaheritage.tn',
        pricePerDay: 55.0,
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
            fuelType: FuelType.HYBRID,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 6, vehicleId: 6, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 7, vehicleId: 7, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 4,
        name: 'Carthage Express',
        description:
            'Fast and reliable bus service connecting major Tunisian cities. Comfortable seats, AC, and WiFi on board.',
        type: TransportType.BUS,
        fuelType: FuelType.DIESEL,
        rating: 4.5,
        reviewCount: 312,
        city: 'Ariana',
        address: 'Gare Routière, Ariana, Tunisia',
        isFeatured: true,
        isVerifiedPartner: false,
        phone: '+216 71 111 222',
        email: 'booking@carthageexpress.tn',
        pricePerDay: 25.0,
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
            fuelType: FuelType.DIESEL,
            quantity: 5,
            availabilities: const [
              VehicleAvailabilityModel(id: 8, vehicleId: 8, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 5,
        name: 'Djerba Sun Rides',
        description:
            'Island transport with scenic coastal routes. Electric vehicles for a green travel experience on Djerba island.',
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.ELECTRIC,
        rating: 4.6,
        reviewCount: 67,
        city: 'Médenine',
        address: 'Zone Touristique, Djerba, Médenine',
        isFeatured: false,
        isVerifiedPartner: true,
        phone: '+216 75 222 333',
        email: 'rent@djerbarides.tn',
        pricePerDay: 90.0,
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
            fuelType: FuelType.ELECTRIC,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 9, vehicleId: 9, isAvailable: true),
            ],
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
            fuelType: FuelType.ELECTRIC,
            quantity: 3,
            availabilities: const [
              VehicleAvailabilityModel(id: 10, vehicleId: 10, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 6,
        name: 'Sfax City Cabs',
        description:
            'Reliable taxi network covering greater Sfax area. Available 24/7 for airport transfers and city rides.',
        type: TransportType.TAXI,
        fuelType: FuelType.PETROL,
        rating: 4.3,
        reviewCount: 156,
        city: 'Sfax',
        address: 'Centre Ville, Sfax, Tunisia',
        isFeatured: false,
        isVerifiedPartner: false,
        phone: '+216 74 333 444',
        email: 'dispatch@sfaxcabs.tn',
        pricePerDay: 30.0,
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
            fuelType: FuelType.PETROL,
            quantity: 8,
            availabilities: const [
              VehicleAvailabilityModel(id: 11, vehicleId: 11, isAvailable: false),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 7,
        name: 'Kairouan Heritage Rides',
        description:
            'Comfortable rides through the holy city and surrounding areas. Discover the Great Mosque and historic sites in style.',
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.HYBRID,
        rating: 4.4,
        reviewCount: 93,
        city: 'Kairouan',
        address: 'Avenue de la République, Kairouan, Tunisia',
        isFeatured: true,
        isVerifiedPartner: true,
        phone: '+216 77 444 555',
        email: 'info@kairouanrides.tn',
        pricePerDay: 70.0,
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
            fuelType: FuelType.HYBRID,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 12, vehicleId: 12, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 13, vehicleId: 13, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 8,
        name: 'Bizerte Blue Lagoon Transport',
        description:
            'Scenic coastal transport services in northern Tunisia. Perfect for exploring Bizerte\'s old port and beautiful lagoons.',
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.PETROL,
        rating: 4.7,
        reviewCount: 78,
        city: 'Bizerte',
        address: 'Port de Plaisance, Bizerte, Tunisia',
        isFeatured: false,
        isVerifiedPartner: false,
        phone: '+216 72 555 666',
        email: 'reservations@bluelagoon.tn',
        pricePerDay: 60.0,
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
            fuelType: FuelType.PETROL,
            quantity: 3,
            availabilities: const [
              VehicleAvailabilityModel(id: 14, vehicleId: 14, isAvailable: true),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 9,
        name: 'Tozeur Oasis Shuttle',
        description:
            'Desert oasis excursions and airport transfers. Explore Chebika, Tamerza, and Mides canyons with experienced local guides.',
        type: TransportType.BUS,
        fuelType: FuelType.DIESEL,
        rating: 4.8,
        reviewCount: 45,
        city: 'Tozeur',
        address: 'Place des Martyrs, Tozeur, Tunisia',
        isFeatured: true,
        isVerifiedPartner: true,
        phone: '+216 76 666 777',
        email: 'tours@oasisshuttle.tn',
        pricePerDay: 40.0,
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
            fuelType: FuelType.DIESEL,
            quantity: 2,
            availabilities: const [
              VehicleAvailabilityModel(id: 15, vehicleId: 15, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 16, vehicleId: 16, isAvailable: false),
            ],
          ),
        ],
      ),
      TransportModel(
        id: 10,
        name: 'Nabeul Comfort Cars',
        description:
            'Premium car rental for Cap Bon peninsula exploration. From Hammamet beaches to Kelibia fortress, travel in comfort.',
        type: TransportType.CAR_RENTAL,
        fuelType: FuelType.PETROL,
        rating: 4.5,
        reviewCount: 102,
        city: 'Nabeul',
        address: 'Avenue Habib Thameur, Nabeul, Tunisia',
        isFeatured: false,
        isVerifiedPartner: true,
        phone: '+216 72 777 888',
        email: 'rent@nabeulcars.tn',
        pricePerDay: 75.0,
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
            fuelType: FuelType.PETROL,
            quantity: 4,
            availabilities: const [
              VehicleAvailabilityModel(id: 17, vehicleId: 17, isAvailable: true),
            ],
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
            fuelType: FuelType.DIESEL,
            quantity: 1,
            availabilities: const [
              VehicleAvailabilityModel(id: 18, vehicleId: 18, isAvailable: true),
            ],
          ),
        ],
      ),
    ];
  }
}
