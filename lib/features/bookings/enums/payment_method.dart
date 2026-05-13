enum PaymentMethod {
  cash,
  creditCard,
  paypal,
  stripe
}

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.creditCard:
        return 'CREDIT_CARD';
      case PaymentMethod.paypal:
        return 'PAYPAL';
      case PaymentMethod.stripe:
        return 'STRIPE';
    }
  }

  static PaymentMethod fromString(String val) {
    switch (val) {
      case 'CREDIT_CARD':
        return PaymentMethod.creditCard;
      case 'PAYPAL':
        return PaymentMethod.paypal;
      case 'STRIPE':
        return PaymentMethod.stripe;
      case 'CASH':
      default:
        return PaymentMethod.cash;
    }
  }
}
