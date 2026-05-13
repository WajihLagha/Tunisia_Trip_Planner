enum BookingState { pending, inPayment, confirmed, cancelled }

extension BookingStateExtension on BookingState {
  String get value {
    switch (this) {
      case BookingState.pending:
        return 'PENDING';
      case BookingState.inPayment:
        return 'IN_PAYMENT';
      case BookingState.confirmed:
        return 'CONFIRMED';
      case BookingState.cancelled:
        return 'CANCELLED';
    }
  }

  static BookingState fromString(String val) {
    switch (val) {
      case 'IN_PAYMENT':
        return BookingState.inPayment;
      case 'CONFIRMED':
        return BookingState.confirmed;
      case 'CANCELLED':
        return BookingState.cancelled;
      case 'PENDING':
      default:
        return BookingState.pending;
    }
  }
}
