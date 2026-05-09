class EndPoints {
  static const String baseUrl = "http://192.168.0.116:8080/api-v1/";
  
  // Auth Endpoints (Keycloak)
  static const String keycloakBaseUrl = "https://keycloak-irtl.onrender.com/realms/TuniWays/protocol/openid-connect/token";
  
  // Example Microservice Endpoints
  static const String login = "login";
  static const String register = "register";
  static const String profile = "profile";
  
  // Places Service Endpoints
  static const String places = "places";
  static const String placesSearch = "places/search";
  static const String placesFilter = "places/filter";
  static const String itinerary = "places/itinerary";

  // Accommodation Service Endpoints
  static const String accommodations = "accommodations";
  static const String accommodationDetails = "accommodations/details";
  static const String accommodationSearch = "accommodations/search";

  // User Service Endpoints
  static const String users = "users";
  static const String usersByEmail = "users/email";
  static const String usersResetPassword = "users/reset-password";
  static const String roles = "roles";
  static const String reviews = "reviews";
}
