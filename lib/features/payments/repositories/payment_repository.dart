import 'package:tunisian_trip_planner/features/payments/models/payment_dto.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';

class PaymentRepository {
  Future<PaymentResponse> createPaymentIntent(PaymentRequest request) async {
    final response = await DioHelper.postData(
      url: '${EndPoints.payments}/create',
      data: request.toJson(),
    );

    if (response.statusCode == 200) {
      return PaymentResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to create payment intent');
    }
  }
}
