import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_states.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitialState());

  static AuthCubit get(context) => BlocProvider.of(context);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ── Keycloak Configuration ────────────────────────────────────────────────
  static const String _clientId = 'oauth-pkce';
  static const String _keycloakBase =
      'https://keycloak-irtl.onrender.com/realms/TuniWays';
  static const String _tokenEndpoint =
      '$_keycloakBase/protocol/openid-connect/token';

  List<String> currentRoles = [];
  String? currentUserId;
  String? currentEmail;

  // ── Check existing stored token on app start ──────────────────────────────
  Future<void> checkExistingAuth() async {
    emit(AuthLoadingState());
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');

      if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
        _processToken(accessToken);
        DioHelper.setToken(accessToken);
      } else if (refreshToken != null) {
        await _refreshWithToken(refreshToken);
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (e) {
      debugPrint('[AuthCubit] checkExistingAuth error: $e');
      emit(AuthUnauthenticatedState());
    }
  }

  // ── Direct username + password login (no browser required) ───────────────
  Future<void> loginWithPassword({
    required String username,
    required String password,
  }) async {
    emit(AuthLoadingState());
    try {
      // Use a plain Dio instance so we don't inject our Bearer token here
      final dio = Dio();
      final response = await dio.post(
        _tokenEndpoint,
        data: {
          'grant_type': 'password',
          'client_id': _clientId,
          'username': username.trim(),
          'password': password,
          'scope': 'openid profile email roles',
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          receiveDataWhenStatusError: true,
        ),
      );

      final accessToken = response.data['access_token'] as String?;
      final refreshToken = response.data['refresh_token'] as String?;

      if (accessToken != null) {
        // Persist tokens
        await _secureStorage.write(key: 'access_token', value: accessToken);
        if (refreshToken != null) {
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);
        }
        _processToken(accessToken);
        DioHelper.setToken(accessToken);
      } else {
        emit(AuthErrorState('Login failed: no token received.'));
      }
    } on DioException catch (e) {
      debugPrint('[AuthCubit] loginWithPassword DioError: ${e.response?.data}');
      final msg =
          e.response?.data?['error_description'] ??
          e.response?.data?['error'] ??
          'Invalid credentials. Please try again.';
      emit(AuthErrorState(msg.toString()));
    } catch (e) {
      debugPrint('[AuthCubit] loginWithPassword error: $e');
      emit(AuthErrorState('Login error: ${e.toString()}'));
    }
  }

  // ── Internal: refresh access token silently ───────────────────────────────
  Future<void> _refreshWithToken(String refreshToken) async {
    try {
      final dio = Dio();
      final response = await dio.post(
        _tokenEndpoint,
        data: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'refresh_token': refreshToken,
        },
        options: Options(contentType: 'application/x-www-form-urlencoded'),
      );

      final accessToken = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String?;

      if (accessToken != null) {
        await _secureStorage.write(key: 'access_token', value: accessToken);
        if (newRefresh != null) {
          await _secureStorage.write(key: 'refresh_token', value: newRefresh);
        }
        _processToken(accessToken);
        DioHelper.setToken(accessToken);
      } else {
        emit(AuthUnauthenticatedState());
      }
    } catch (e) {
      debugPrint('[AuthCubit] token refresh error: $e');
      emit(AuthUnauthenticatedState());
    }
  }

  // ── Get a valid token (used by DioHelper refresh callback) ────────────────
  Future<String?> getValidAccessToken() async {
    final accessToken = await _secureStorage.read(key: 'access_token');
    if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
      return accessToken;
    }
    final refreshToken = await _secureStorage.read(key: 'refresh_token');
    if (refreshToken != null) {
      try {
        await _refreshWithToken(refreshToken);
        return await _secureStorage.read(key: 'access_token');
      } catch (e) {
        debugPrint('[AuthCubit] Refresh failed: $e');
        await logout();
      }
    }
    return null;
  }

  // ── Decode token, extract roles + email, update DioHelper ─────────────────
  void _processToken(String accessToken) {
    final decoded = JwtDecoder.decode(accessToken);
    debugPrint('[AuthCubit] Decoded Token: $decoded');

    // Roles (check both realm_access and resource_access)
    currentRoles = [];
    final realmAccess = decoded['realm_access'] as Map<String, dynamic>?;
    if (realmAccess != null && realmAccess['roles'] is List) {
      currentRoles.addAll(List<String>.from(realmAccess['roles'] as List));
    }

    final resourceAccess = decoded['resource_access'] as Map<String, dynamic>?;
    if (resourceAccess != null) {
      final clientAccess = resourceAccess[_clientId] as Map<String, dynamic>?;
      if (clientAccess != null && clientAccess['roles'] is List) {
        currentRoles.addAll(List<String>.from(clientAccess['roles'] as List));
      }
    }

    // User ID
    currentUserId = decoded['sub'] as String?;

    // Email
    currentEmail =
        decoded['email'] as String? ?? decoded['preferred_username'] as String?;

    final isAdmin = _hasAdminRole;

    if (currentEmail != null) DioHelper.setUserEmail(currentEmail!);
    DioHelper.setAdminStatus(isAdmin);

    debugPrint(
      '[AuthCubit] User: $currentEmail | Roles: $currentRoles | isAdmin: $isAdmin',
    );

    emit(AuthSuccessState(roles: currentRoles, userId: currentUserId));
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    DioHelper.clearToken();
    currentRoles = [];
    currentUserId = null;
    currentEmail = null;
    emit(AuthUnauthenticatedState());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool get _hasAdminRole => currentRoles.any((role) {
    final normalized = role.toLowerCase();
    return normalized == 'admin' || normalized == 'role_admin';
  });

  bool get isAdmin => _hasAdminRole;
  bool get isProvider => currentRoles.any((r) => r.toLowerCase() == 'provider');
}
