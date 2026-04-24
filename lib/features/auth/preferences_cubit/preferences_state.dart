class PreferencesState {
  final String? address;
  final List<String> travelStyle;
  final String? companions;
  final String? budget;
  final List<String> accommodation;
  final List<String> transport;
  final String? ageGroup;

  const PreferencesState({
    this.address,
    this.travelStyle = const [],
    this.companions,
    this.budget,
    this.accommodation = const [],
    this.transport = const [],
    this.ageGroup,
  });

  // ── Per-step validations ──────────────────────────────────────
  bool get step1Valid =>
      address != null && address!.trim().isNotEmpty && ageGroup != null;
  bool get step2Valid => travelStyle.isNotEmpty && companions != null;
  bool get step3Valid => budget != null && accommodation.isNotEmpty;
  bool get step4Valid => transport.isNotEmpty;

  /// How many steps are fully completed (used for the header progress).
  int get completedSteps =>
      (step1Valid ? 1 : 0) +
      (step2Valid ? 1 : 0) +
      (step3Valid ? 1 : 0) +
      (step4Valid ? 1 : 0);

  PreferencesState copyWith({
    String? address,
    List<String>? travelStyle,
    String? companions,
    String? budget,
    List<String>? accommodation,
    List<String>? transport,
    String? ageGroup,
  }) {
    return PreferencesState(
      address: address ?? this.address,
      travelStyle: travelStyle ?? this.travelStyle,
      companions: companions ?? this.companions,
      budget: budget ?? this.budget,
      accommodation: accommodation ?? this.accommodation,
      transport: transport ?? this.transport,
      ageGroup: ageGroup ?? this.ageGroup,
    );
  }

  /// Serialize for local cache.
  Map<String, dynamic> toJson() => {
        'address': address,
        'pref_travel_style': travelStyle,
        'pref_companions': companions,
        'pref_budget': budget,
        'pref_accommodation': accommodation,
        'pref_transport': transport,
        'age_group': ageGroup,
      };

  /// Rebuild from local cache.
  factory PreferencesState.fromJson(Map<dynamic, dynamic> data) {
    return PreferencesState(
      address: data['address'] as String?,
      travelStyle: List<String>.from(data['pref_travel_style'] ?? []),
      companions: data['pref_companions'] as String?,
      budget: data['pref_budget'] as String?,
      accommodation: List<String>.from(data['pref_accommodation'] ?? []),
      transport: List<String>.from(data['pref_transport'] ?? []),
      ageGroup: data['age_group'] as String?,
    );
  }
}
