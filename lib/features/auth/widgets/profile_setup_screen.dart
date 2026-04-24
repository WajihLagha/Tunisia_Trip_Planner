import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/auth/preferences_cubit/preferences_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/preferences_cubit/preferences_state.dart';
import 'package:tunisian_trip_planner/features/home_layout/widgets/home_layout.dart';
import 'package:tunisian_trip_planner/shared/widgets/components.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

// ───────────────────────────────────────────────────────────────────────────
//  ROOT SCREEN
// ───────────────────────────────────────────────────────────────────────────
class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PreferencesCubit(),
      child: const _PreferencesBody(),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  STATEFUL BODY
// ───────────────────────────────────────────────────────────────────────────
class _PreferencesBody extends StatefulWidget {
  const _PreferencesBody();

  @override
  State<_PreferencesBody> createState() => _PreferencesBodyState();
}

class _PreferencesBodyState extends State<_PreferencesBody> {
  int _currentStep = 0;
  bool _isLoadingLocation = false;

  // Controller keeps the address field in sync when GPS fills it
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _setStep(int step) => setState(() => _currentStep = step);

  // ── Real GPS → reverse-geocode → city/town ──────────────────────────────
  Future<void> _detectLocation(PreferencesCubit cubit) async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showToast(
          msg: 'Location permission denied',
          state: ToastStates.warning,
        );
        return;
      }

      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      final List<Placemark> marks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        final city = p.locality?.isNotEmpty == true
            ? p.locality!
            : p.subAdministrativeArea ?? p.administrativeArea ?? '';
        final country = p.country ?? '';
        final full = [city, country].where((s) => s.isNotEmpty).join(', ');
        _addressController.text = full;
        cubit.updateAddress(full);
      }
    } catch (_) {
      showToast(
        msg: 'Could not detect location. Try again.',
        state: ToastStates.error,
      );
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // ── Open OSM map picker, wait for selected address ───────────────────────
  Future<void> _openMapPicker(BuildContext ctx, PreferencesCubit cubit) async {
    final String? address = await Navigator.push<String>(
      ctx,
      MaterialPageRoute(builder: (_) => const _MapPickerScreen()),
    );
    if (address != null && mounted) {
      _addressController.text = address;
      cubit.updateAddress(address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.surfaceLight,
          body: Column(
            children: [
              _HeaderWidget(state: state),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Theme(
                    data: _stepperTheme(context),
                    child: Stepper(
                      currentStep: _currentStep,
                      type: StepperType.vertical,
                      physics: const NeverScrollableScrollPhysics(),
                      // ── Step indicator: 44×44 numbered circles ──────
                      stepIconBuilder: (stepIndex, stepState) {
                        final bool active = stepIndex == _currentStep;
                        final bool done = stepState == StepState.complete;
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? AppColors.primaryDark
                                : active
                                    ? AppColors.primary
                                    : AppColors.surfaceVariantL,
                            border: Border.all(
                              color: done || active
                                  ? Colors.transparent
                                  : AppColors.borderColor,
                              width: 1.5,
                            ),
                            boxShadow: done || active
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryDark
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20)
                                : Text(
                                    '${stepIndex + 1}',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: active
                                          ? Colors.white
                                          : AppColors.mutedText,
                                    ),
                                  ),
                          ),
                        );
                      },
                      controlsBuilder: (_, __) => const SizedBox.shrink(),
                      onStepTapped: (step) {
                        if (step < _currentStep) _setStep(step);
                      },
                      steps: [
                        _buildStep1(context, state),
                        _buildStep2(context, state),
                        _buildStep3(context, state),
                        _buildStep4(context, state),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _BottomCTA(
            currentStep: _currentStep,
            state: state,
            onSetStep: _setStep,
          ),
        );
      },
    );
  }

  // ─── STEP 1 — Location & Age ─────────────────────────────────────────────
  Step _buildStep1(BuildContext context, PreferencesState state) {
    final cubit = PreferencesCubit.get(context);

    final List<Map<String, String>> ageGroups = [
      {'label': '18-25', 'icon': '🎓'},
      {'label': '26-35', 'icon': '💼'},
      {'label': '36-50', 'icon': '🏡'},
      {'label': '50+', 'icon': '🌿'},
    ];

    return Step(
      title: _stepTitle('Location & Age', _currentStep >= 0),
      subtitle: _stepSubtitle('Where are you from? How old are you?'),
      isActive: _currentStep >= 0,
      state: state.step1Valid ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('📍 YOUR LOCATION'),
          const SizedBox(height: 8),

          // ── Address text field ──────────────────────────────────
          TextField(
            controller: _addressController,
            onChanged: cubit.updateAddress,
            style: GoogleFonts.nunito(color: AppColors.onSurfaceLight, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Type your city or use GPS below…',
              hintStyle: GoogleFonts.nunito(color: AppColors.mutedText, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.primary, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 10),

          // ── GPS  +  Map picker buttons ─────────────────────────
          Row(
            children: [
              // GPS button
              Expanded(
                child: GestureDetector(
                  onTap: _isLoadingLocation
                      ? null
                      : () => _detectLocation(cubit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariantL,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.borderColor, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        else
                          const Icon(Icons.my_location_rounded,
                              color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _isLoadingLocation ? 'Detecting…' : 'My Location',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Map picker button
              Expanded(
                child: GestureDetector(
                  onTap: () => _openMapPicker(context, cubit),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.map_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Choose on Map',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _sectionLabel('AGE GROUP'),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: ageGroups.map((ag) {
              final selected = state.ageGroup == ag['label'];
              return GestureDetector(
                onTap: () => cubit.updateAgeGroup(ag['label']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green800 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.green800 : AppColors.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.green800.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ag['icon']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        ag['label']!,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── STEP 2 — Travel Style & Companions ──────────────────────────────────
  Step _buildStep2(BuildContext context, PreferencesState state) {
    final cubit = PreferencesCubit.get(context);

    final List<Map<String, String>> travelStyles = [
      {'value': 'Adventure', 'icon': '🧗', 'label': 'Adventure'},
      {'value': 'Cultural', 'icon': '🏛️', 'label': 'Cultural'},
      {'value': 'Beach', 'icon': '🏖️', 'label': 'Beach'},
      {'value': 'Gastronomy', 'icon': '🍽️', 'label': 'Gastronomy'},
      {'value': 'Nature', 'icon': '🌿', 'label': 'Nature'},
      {'value': 'Spiritual', 'icon': '🕌', 'label': 'Spiritual'},
      {'value': 'Nightlife', 'icon': '🌙', 'label': 'Nightlife'},
      {'value': 'Shopping', 'icon': '🛍️', 'label': 'Shopping'},
    ];

    final List<Map<String, String>> companions = [
      {'value': 'Solo', 'icon': '🧍', 'label': 'Solo'},
      {'value': 'Couple', 'icon': '👫', 'label': 'Couple'},
      {'value': 'Family', 'icon': '👨‍👩‍👧', 'label': 'Family'},
      {'value': 'Friends', 'icon': '👯', 'label': 'Friends'},
    ];

    return Step(
      title: _stepTitle('Travel Style & Company', _currentStep >= 1),
      subtitle: _stepSubtitle('What do you love? Who are you travelling with?'),
      isActive: _currentStep >= 1,
      state: state.step2Valid ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('✈️ TRAVEL STYLE  (multi-select)'),
          const SizedBox(height: 10),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: travelStyles.map((style) {
              final selected = state.travelStyle.contains(style['value']);
              return GestureDetector(
                onTap: () => cubit.toggleTravelStyle(style['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryDark : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.primaryDark : AppColors.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryDark.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(style['icon']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        style['label']!,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          _sectionLabel('COMPANIONS'),
          const SizedBox(height: 10),

          Row(
            children: companions.map((comp) {
              final selected = state.companions == comp['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => cubit.updateCompanions(comp['value']!),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.green700 : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.green700 : AppColors.borderColor,
                        width: 1.5,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.green700.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Text(comp['icon']!, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(
                          comp['label']!,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.onSurfaceLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── STEP 3 — Budget & Accommodation ─────────────────────────────────────
  Step _buildStep3(BuildContext context, PreferencesState state) {
    final cubit = PreferencesCubit.get(context);

    // ── Budget: matching the screenshot card layout ────────────────────────
    final List<Map<String, String>> budgetOptions = [
      {'value': 'Budget', 'icon': '💰', 'subtitle': 'Dars · Hostels'},
      {'value': 'Mid Range', 'icon': '💳', 'subtitle': 'Hotels · Gîtes'},
      {'value': 'Luxury', 'icon': '💎', 'subtitle': '5★ Resorts'},
    ];

    final List<Map<String, String>> accommodations = [
      {'value': 'Hotel', 'icon': '🏨'},
      {'value': 'Riad', 'icon': '🏡'},
      {'value': 'Hostel', 'icon': '🛏️'},
      {'value': 'Camping', 'icon': '⛺'},
      {'value': 'Airbnb', 'icon': '🏠'},
      {'value': 'Resort', 'icon': '🏝️'},
    ];

    return Step(
      title: _stepTitle('Budget & Accommodation', _currentStep >= 2),
      subtitle: _stepSubtitle('What is your spending comfort?'),
      isActive: _currentStep >= 2,
      state: state.step3Valid ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('BUDGET RANGE'),
          const SizedBox(height: 12),

          // ── 3 horizontal cards (matches screenshot) ────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(budgetOptions.length, (i) {
              final opt = budgetOptions[i];
              final selected = state.budget == opt['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => cubit.updateBudget(opt['value']!),
                  child: Container(
                    margin: EdgeInsets.only(right: i < budgetOptions.length - 1 ? 8 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      height: 138,
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [AppColors.primaryDark, AppColors.green700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: selected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? Colors.transparent : AppColors.borderColor,
                          width: 1.5,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.32),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Stack(
                        children: [
                          // ── Radio indicator (top-right) ─────────────
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? Colors.white
                                    : Colors.transparent,
                                border: Border.all(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.mutedText.withValues(alpha: 0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),

                          // ── Card body ───────────────────────────────
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(opt['icon']!,
                                    style: const TextStyle(fontSize: 34)),
                                const SizedBox(height: 8),
                                Text(
                                  opt['value']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? Colors.white
                                        : AppColors.onSurfaceLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opt['subtitle']!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(
                                    fontSize: 10,
                                    color: selected
                                        ? Colors.white70
                                        : AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          _sectionLabel('ACCOMMODATION  (multi-select)'),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: accommodations.map((acc) {
              final selected = state.accommodation.contains(acc['value']);
              return GestureDetector(
                onTap: () => cubit.toggleAccommodation(acc['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green800 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.green800 : AppColors.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.green800.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(acc['icon']!, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        acc['value']!,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ─── STEP 4 — Transport & Summary ────────────────────────────────────────
  Step _buildStep4(BuildContext context, PreferencesState state) {
    final cubit = PreferencesCubit.get(context);

    final List<Map<String, String>> transports = [
      {'value': 'Car', 'icon': '🚗'},
      {'value': 'Bus', 'icon': '🚌'},
      {'value': 'Train', 'icon': '🚆'},
      {'value': 'Taxi', 'icon': '🚕'},
      {'value': 'Bike', 'icon': '🚲'},
      {'value': 'Plane', 'icon': '✈️'},
    ];

    String fmt(List<String> list) => list.isEmpty ? '—' : list.join(', ');

    return Step(
      title: _stepTitle('Transport & Summary', _currentStep >= 3),
      subtitle: _stepSubtitle('How do you like to get around?'),
      isActive: _currentStep >= 3,
      state: state.step4Valid ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('TRANSPORT  (multi-select)'),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: transports.map((t) {
              final selected = state.transport.contains(t['value']);
              return GestureDetector(
                onTap: () => cubit.toggleTransport(t['value']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.green700 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.green700 : AppColors.borderColor,
                      width: 1.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.green700.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t['icon']!, style: const TextStyle(fontSize: 15)),
                      const SizedBox(width: 7),
                      Text(
                        t['value']!,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.onSurfaceLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),
          _sectionLabel('YOUR PROFILE SUMMARY'),
          const SizedBox(height: 10),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.green700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(label: '📍 Location', value: state.address ?? '—'),
                _SummaryRow(label: '🎂 Age Group', value: state.ageGroup ?? '—'),
                _SummaryRow(label: '✈️ Style', value: fmt(state.travelStyle)),
                _SummaryRow(label: '👥 Company', value: state.companions ?? '—'),
                _SummaryRow(label: '💰 Budget', value: state.budget ?? '—'),
                _SummaryRow(label: '🏨 Stay', value: fmt(state.accommodation)),
                _SummaryRow(
                    label: '🚗 Transport',
                    value: fmt(state.transport),
                    isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  HEADER
// ───────────────────────────────────────────────────────────────────────────
class _HeaderWidget extends StatelessWidget {
  final PreferencesState state;
  const _HeaderWidget({required this.state});

  @override
  Widget build(BuildContext context) {
    final double progress = state.completedSteps / 4.0;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Preferences',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${state.completedSteps} / 4',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Help us personalise your Tunisia trip ✨',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (i) {
              return Text(
                'Step ${i + 1}',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color:
                      state.completedSteps > i ? AppColors.accent : Colors.white38,
                  fontWeight: FontWeight.w600,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  BOTTOM CTA  — rounded top corners
// ───────────────────────────────────────────────────────────────────────────
class _BottomCTA extends StatelessWidget {
  final int currentStep;
  final PreferencesState state;
  final void Function(int) onSetStep;

  const _BottomCTA({
    required this.currentStep,
    required this.state,
    required this.onSetStep,
  });

  bool get _isValid {
    switch (currentStep) {
      case 0:  return state.step1Valid;
      case 1:  return state.step2Valid;
      case 2:  return state.step3Valid;
      case 3:  return state.step4Valid;
      default: return false;
    }
  }

  void _handleAction(BuildContext context) {
    if (!_isValid) {
      showToast(
        msg: 'Please complete all fields in this step.',
        state: ToastStates.warning,
      );
      return;
    }
    if (currentStep < 3) {
      onSetStep(currentStep + 1);
    } else {
      PreferencesCubit.get(context).savePreferences();
      navigateAndRemoveAll(context, HomeLayout());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = currentStep == 3;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      // ── Rounded top corners ──────────────────────────────────────────────
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button (hidden on step 0) — same height as CTA
          if (currentStep > 0) ...[
            GestureDetector(
              onTap: () => onSetStep(currentStep - 1),
              child: Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 1.5),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primary, size: 18),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Main CTA button
          Expanded(
            child: GestureDetector(
              onTap: () => _handleAction(context),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isValid
                        ? [AppColors.primaryDark, AppColors.green500]
                        : [
                            AppColors.mutedText.withValues(alpha: 0.4),
                            AppColors.mutedText.withValues(alpha: 0.3),
                          ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isValid
                      ? [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Save & Explore Tunisia' : 'Continue',
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (!isLast) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  SUMMARY ROW
// ───────────────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            children: [
              Text(label,
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white70,
                      letterSpacing: 0.5)),
              const Spacer(),
              Flexible(
                child: Text(value,
                    textAlign: TextAlign.end,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              color: Colors.white.withValues(alpha: 0.15),
              height: 1,
              thickness: 1),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  PRIVATE HELPERS
// ───────────────────────────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.mutedText,
        letterSpacing: 1.1,
      ),
    );

Widget _stepTitle(String text, bool isActive) => Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: isActive ? AppColors.onSurfaceLight : AppColors.mutedText,
      ),
    );

Widget _stepSubtitle(String text) => Text(
      text,
      style: GoogleFonts.nunito(fontSize: 12, color: AppColors.mutedText),
    );

ThemeData _stepperTheme(BuildContext context) {
  return Theme.of(context).copyWith(
    colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AppColors.primaryDark,
          onSurface: AppColors.mutedText,
        ),
  );
}

// ───────────────────────────────────────────────────────────────────────────
//  MAP PICKER SCREEN  (full-screen OSM map with centred pin)
// ───────────────────────────────────────────────────────────────────────────
class _MapPickerScreen extends StatefulWidget {
  const _MapPickerScreen();

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  // Default centre: Tunisia
  LatLng _centre = const LatLng(33.8869, 9.5375);
  bool _isGeocoding = false;

  Future<void> _confirm() async {
    setState(() => _isGeocoding = true);
    try {
      final marks =
          await placemarkFromCoordinates(_centre.latitude, _centre.longitude);
      if (marks.isNotEmpty && mounted) {
        final p = marks.first;
        final city = p.locality?.isNotEmpty == true
            ? p.locality!
            : p.subAdministrativeArea ?? p.administrativeArea ?? '';
        final country = p.country ?? '';
        final full = [city, country].where((s) => s.isNotEmpty).join(', ');
        Navigator.pop(context, full);
      } else {
        showToast(
            msg: 'No address found here. Try another spot.',
            state: ToastStates.warning);
      }
    } catch (_) {
      showToast(
          msg: 'Could not get address. Try again.',
          state: ToastStates.error);
    } finally {
      if (mounted) setState(() => _isGeocoding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── OSM Map ─────────────────────────────────────────────
          FlutterMap(
            options: MapOptions(
              initialCenter: _centre,
              initialZoom: 6.0,
              onPositionChanged: (position, _) {
                setState(() => _centre = position.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.tunisian_trip_planner',
              ),
            ],
          ),

          // ── Centred pin ─────────────────────────────────────────
          IgnorePointer(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.location_pin,
                        color: AppColors.primaryDark, size: 32),
                  ),
                  // pin tip shadow
                  Container(
                    width: 10,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  // offset so pin tip sits exactly on centre
                  const SizedBox(height: 44),
                ],
              ),
            ),
          ),

          // ── Gradient header ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                  top: top + 10, left: 16, right: 16, bottom: 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pick Your Location',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Drag the map · pin stays centred',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Coordinates badge ───────────────────────────────────
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${_centre.latitude.toStringAsFixed(4)}, ${_centre.longitude.toStringAsFixed(4)}',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ),

          // ── Confirm button ──────────────────────────────────────
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: GestureDetector(
              onTap: _isGeocoding ? null : _confirm,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isGeocoding
                        ? [
                            AppColors.mutedText.withValues(alpha: 0.5),
                            AppColors.mutedText.withValues(alpha: 0.4),
                          ]
                        : [AppColors.primaryDark, AppColors.green500],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isGeocoding
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primaryDark
                                .withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Center(
                  child: _isGeocoding
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Confirm This Location',
                              style: GoogleFonts.nunito(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
