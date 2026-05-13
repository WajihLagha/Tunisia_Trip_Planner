abstract class AdminStates {}

class AdminInitialState extends AdminStates {}

// ── Inactive Places ─────────────────────────────────────────────────────────
class AdminLoadingPlacesState extends AdminStates {}

class AdminLoadedPlacesState extends AdminStates {}

class AdminErrorPlacesState extends AdminStates {
  final String message;
  AdminErrorPlacesState(this.message);
}

// ── Inactive Accommodations ──────────────────────────────────────────────────
class AdminLoadingAccommodationsState extends AdminStates {}

class AdminLoadedAccommodationsState extends AdminStates {}

class AdminErrorAccommodationsState extends AdminStates {
  final String message;
  AdminErrorAccommodationsState(this.message);
}

// ── Inactive Transports ──────────────────────────────────────────────────────
class AdminLoadingTransportsState extends AdminStates {}

class AdminLoadedTransportsState extends AdminStates {}

class AdminErrorTransportsState extends AdminStates {
  final String message;
  AdminErrorTransportsState(this.message);
}

// ── Actions (Activate/Delete) ────────────────────────────────────────────────
class AdminActionLoadingState extends AdminStates {}

class AdminActionSuccessState extends AdminStates {
  final String message;
  AdminActionSuccessState(this.message);
}

class AdminActionErrorState extends AdminStates {
  final String message;
  AdminActionErrorState(this.message);
}
