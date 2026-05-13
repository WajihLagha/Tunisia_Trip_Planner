class EndPoints {
  // Railway gateway. Override when needed:
  // flutter run --dart-define=API_ORIGIN=http://<local-ip>:8080
  static const String apiOrigin = String.fromEnvironment(
    'API_ORIGIN',
    defaultValue: 'https://gateway-service-production-a08f.up.railway.app',
  );
  static const String baseUrl = '$apiOrigin/api-v1/';

  // Keycloak (deployed on Render)
  static const String keycloakBaseUrl =
      'https://keycloak-irtl.onrender.com/realms/TuniWays/protocol/openid-connect/token';

  // ── Auth / User Service (8081) ────────────────────────────────────────────
  static const String login = 'login';

  static const String register = 'register';
  static const String profile = 'profile';
  static const String users = 'users';
  static const String usersByEmail = 'users/email';
  static const String usersResetPassword = 'users/reset-password';
  static const String roles = 'roles';

  // ── Places Service (8084) ─────────────────────────────────────────────────
  static const String places = 'places';
  static const String placesSearch = 'places/search';
  static const String placesFilter = 'places/filter';
  static const String itinerary = 'places/itinerary';

  // ── Accommodation Service (8082) ──────────────────────────────────────────
  static const String accommodations = 'accommodations';
  static const String accommodationDetails = 'accommodations/details';
  static const String accommodationSearch = 'accommodations/search';

  // ── Transport Service (8083) ──────────────────────────────────────────────
  // Transports CRUD
  static const String transports = 'transports';
  static String transportById(int id) => 'transports/$id';
  static String transportActivate(int id) => 'transports/$id/activate';
  static String transportDeactivate(int id) => 'transports/$id/deactivate';

  // Transport Stripe onboarding
  static String transportStripeAccount(int id) =>
      'transports/$id/stripe-account';
  static String transportStripeOnboardingLink(int id) =>
      'transports/$id/onBoarding-link';

  // Vehicles
  static const String vehicles = 'vehicles';
  static String vehicleById(int id) => 'vehicles/$id';
  static String vehiclesByTransport(int transportId) =>
      'vehicles/by-transport/$transportId';

  // Vehicle Availabilities
  static const String vehicleAvailabilities = 'vehicle-availabilities';
  static String vehicleAvailabilityById(int id) => 'vehicle-availabilities/$id';
  static String vehicleAvailabilityByVehicle(int vehicleId) =>
      'vehicle-availabilities/vehicle/$vehicleId';

  // Transport Images
  static const String transportImages = 'transport-images';
  static String transportImagesByTransport(int transportId) =>
      'transport-images/transport/$transportId';
  static String transportImageById(int id) => 'transport-images/$id';

  // ── Review Service (8085) ─────────────────────────────────────────────────
  static const String reviews = 'reviews';

  // ── Booking Service (8087) ────────────────────────────────────────────────
  static const String bookings = 'bookings';

  // ── Payment Service (8086) ────────────────────────────────────────────────
  static const String payments = 'payments';

  // ── Admin Endpoints ───────────────────────────────────────────────────────
  static const String adminPlacesInactive = 'places/admin/inactive';
  static const String adminAccommodationsInactive =
      'accommodations/admin/inactive';
  static const String adminTransportsInactive = 'transports/admin/inactive';

  // Admin activation/deactivation helpers
  static String adminActivatePlace(String id) => 'places/activate/$id';
  static String adminActivateAccommodation(int id) =>
      'accommodations/admin/$id/activate';
  static String adminActivateTransport(int id) =>
      'transports/admin/$id/activate';
}
