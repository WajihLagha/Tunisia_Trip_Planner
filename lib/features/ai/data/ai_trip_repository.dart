import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_itinerary.dart';
import 'package:tunisian_trip_planner/features/ai/models/ai_plan_request.dart';

class AiTripRepository {
  static const String _baseUrl = 'http://10.0.2.2:8080'; // FastAPI service
  static const String _planEndpoint = '/api/plan';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<AiItinerary> generatePlan(AiPlanRequest request) async {
    try {
      final response = await _dio.post(
        _planEndpoint,
        data: jsonEncode(request.toJson()),
      );

      final data = response.data;

      // Handle structured JSON response
      if (data is Map<String, dynamic>) {
        return AiItinerary.fromJson(data);
      }

      // Handle plain string response from Gemini
      if (data is String) {
        return AiItinerary.fromPlainText(data, request.tripLength);
      }

      // Handle response wrapped in a 'result' or 'itinerary' key
      if (data is Map) {
        final inner = data['itinerary'] ?? data['result'] ?? data['plan'];
        if (inner is Map<String, dynamic>) {
          return AiItinerary.fromJson(inner);
        }
        if (inner is String) {
          return AiItinerary.fromPlainText(inner, request.tripLength);
        }
      }

      throw Exception('Unexpected response format from AI service');
    } on DioException catch (e) {
      final msg = e.response?.data?.toString() ?? e.message ?? 'Network error';
      throw Exception('AI service error: $msg');
    }
  }
}
