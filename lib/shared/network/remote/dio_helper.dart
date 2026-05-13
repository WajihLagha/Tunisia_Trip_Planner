import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class DioHelper {
  static late Dio dio;
  static String? _token;
  static String? _userEmail;
  static bool _isAdmin = false;

  /// Call once at startup if a JWT is already stored in cache.
  static void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Store the logged-in user's email (used in X-User-Email header).
  static void setUserEmail(String email) {
    _userEmail = email;
  }

  /// Store whether the current user is an admin (used in X-User-IsAdmin header).
  static void setAdminStatus(bool isAdmin) {
    _isAdmin = isAdmin;
  }

  /// Call on logout to wipe all in-memory state.
  static void clearToken() {
    _token = null;
    _userEmail = null;
    _isAdmin = false;
    dio.options.headers.remove('Authorization');
  }

  /// Callback assigned by AuthCubit to silently refresh the JWT.
  static Future<String?> Function()? onTokenRefresh;

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // ── 401 Auto-Refresh Interceptor ────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 && onTokenRefresh != null) {
            debugPrint(
              '[DioHelper] 401 Unauthorized caught. Attempting token refresh...',
            );
            final newToken = await onTokenRefresh!();
            if (newToken != null) {
              debugPrint(
                '[DioHelper] Token refreshed successfully. Retrying request...',
              );
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              try {
                final retryResponse = await dio.fetch(e.requestOptions);
                return handler.resolve(retryResponse);
              } catch (retryError) {
                return handler.next(e);
              }
            } else {
              debugPrint('[DioHelper] Token refresh failed.');
            }
          }
          return handler.next(e);
        },
      ),
    );

    // ── Pretty Logger (debug builds only) ──────────────────────────────────
    if (kDebugMode) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            debugPrint('[DioHelper] → ${options.method} ${options.uri}');
            debugPrint(
              '[DioHelper]   auth=${options.headers.containsKey('Authorization')} '
              'email=${options.headers['X-User-Email'] ?? '-'} '
              'isAdmin=${options.headers['X-User-IsAdmin']}',
            );
            if (options.data != null) {
              debugPrint('[DioHelper]   body: ${options.data}');
            }
            return handler.next(options);
          },
          onResponse: (response, handler) {
            debugPrint(
              '[DioHelper] ← ${response.statusCode} ${response.requestOptions.uri}',
            );
            return handler.next(response);
          },
          onError: (error, handler) {
            debugPrint(
              '[DioHelper] ✗ ${error.response?.statusCode} ${error.requestOptions.uri}: ${error.message}',
            );
            return handler.next(error);
          },
        ),
      );
    }
  }

  /// Builds the standard headers, always merging X-User-Email and X-User-IsAdmin
  /// when we have a logged-in user (required by transport/accommodation services).
  static Map<String, dynamic> _buildHeaders({
    Map<String, dynamic>? extra,
    String lang = 'en',
  }) {
    return {
      'Content-Type': 'application/json',
      'lang': lang,
      if (_token != null) 'Authorization': 'Bearer $_token',
      if (_userEmail != null) 'X-User-Email': _userEmail!,
      'X-User-IsAdmin': _isAdmin.toString(),
      if (extra != null) ...extra,
    };
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String lang = 'en',
    String? token,
  }) async {
    final effectiveHeaders = _buildHeaders(extra: headers, lang: lang);
    if (token != null) effectiveHeaders['Authorization'] = 'Bearer $token';

    return await dio.get(
      url,
      queryParameters: query,
      options: Options(headers: effectiveHeaders),
    );
  }

  static Future<Response> postData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    Map<String, dynamic>? headers,
    String? token,
    String lang = 'en',
    String contentType = 'application/json',
  }) async {
    final effectiveHeaders = _buildHeaders(extra: headers, lang: lang);
    if (token != null) effectiveHeaders['Authorization'] = 'Bearer $token';

    return await dio.post(
      url,
      data: data,
      queryParameters: query,
      options: Options(headers: effectiveHeaders, contentType: contentType),
    );
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required dynamic data,
    Map<String, dynamic>? headers,
    String? token,
    String lang = 'en',
  }) async {
    final effectiveHeaders = _buildHeaders(extra: headers, lang: lang);
    if (token != null) effectiveHeaders['Authorization'] = 'Bearer $token';

    return await dio.put(
      url,
      data: data,
      queryParameters: query,
      options: Options(headers: effectiveHeaders),
    );
  }

  static Future<Response> patchData({
    required String url,
    Map<String, dynamic>? query,
    dynamic data,
    Map<String, dynamic>? headers,
    String? token,
    String lang = 'en',
  }) async {
    final effectiveHeaders = _buildHeaders(extra: headers, lang: lang);
    if (token != null) effectiveHeaders['Authorization'] = 'Bearer $token';

    return await dio.patch(
      url,
      data: data,
      queryParameters: query,
      options: Options(headers: effectiveHeaders),
    );
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String? token,
    String lang = 'en',
  }) async {
    final effectiveHeaders = _buildHeaders(extra: headers, lang: lang);
    if (token != null) effectiveHeaders['Authorization'] = 'Bearer $token';

    return await dio.delete(
      url,
      queryParameters: query,
      options: Options(headers: effectiveHeaders),
    );
  }
}
