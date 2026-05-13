class PaymentRequest {
  final String bookingId;
  final String userId;
  final String? accommodationId;
  final String? transportId;
  final num amount;

  PaymentRequest({
    required this.bookingId,
    required this.userId,
    this.accommodationId,
    this.transportId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      if (accommodationId != null) 'accommodationId': accommodationId,
      if (transportId != null) 'transportId': transportId,
      'amount': amount,
    };
  }
}

class PaymentResponse {
  final String? id;
  final String? clientSecret;
  final String? status;

  PaymentResponse({
    this.id,
    this.clientSecret,
    this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'],
      clientSecret: json['clientSecret'],
      status: json['status'],
    );
  }
}
