import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class DioHelper {
  static late Dio dio;
  static String? _token;

  /// Call once at startup if a JWT is already stored in cache.
  static void setToken(String token) {
    _token = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Call on logout to wipe the in-memory token.
  static void clearToken() {
    _token = null;
    dio.options.headers.remove('Authorization');
  }

  static void init() {
    dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
  }

  static Future<Response> getData({
    required String url,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    String lang = 'en',
    String? token,
  }) async {
    final effectiveToken = token ?? _token;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'lang': lang,
      if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
      if (headers != null) ...headers,
    };

    debugPrint('[DioHelper] GET url: $url, token present: ${effectiveToken != null}');

    return await dio.get(url, queryParameters: query);
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
    final effectiveToken = token ?? _token;
    dio.options.headers = {
      'lang': lang,
      if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
      if (headers != null) ...headers,
    };
    return await dio.post(
      url, 
      data: data, 
      queryParameters: query,
      options: Options(contentType: contentType),
    );
  }

  static Future<Response> putData({
    required String url,
    Map<String, dynamic>? query,
    required Map<String, dynamic> data,
    String? token,
    String lang = 'en',
  }) async {
    final effectiveToken = token ?? _token;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'lang': lang,
      if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
    };

    return await dio.put(url, queryParameters: query, data: data);
  }

  static Future<Response> deleteData({
    required String url,
    Map<String, dynamic>? query,
    String? token,
    String lang = 'en',
  }) async {
    final effectiveToken = token ?? _token;
    dio.options.headers = {
      'Content-Type': 'application/json',
      'lang': lang,
      if (effectiveToken != null) 'Authorization': 'Bearer $effectiveToken',
    };

    return await dio.delete(url, queryParameters: query);
  }
}
