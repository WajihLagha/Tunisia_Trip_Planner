class EndPoints {
  static const String baseUrl = "http://localhost:8080/api-v1/";
  
  // Auth Endpoints (Keycloak)
  static const String keycloakBaseUrl = "https://keycloak-irtl.onrender.com/realms/TuniWays/protocol/openid-connect/token";
  
  // Example Microservice Endpoints
  static const String login = "login";
  static const String register = "register";
  static const String profile = "profile";
}
