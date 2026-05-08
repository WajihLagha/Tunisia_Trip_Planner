import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/ai/cubit/ai_trip_cubit.dart';
import 'package:tunisian_trip_planner/features/ai/cubit/ai_trip_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/features/ai/screens/ai_itinerary_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class AiTripScreen extends StatelessWidget {
  const AiTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiTripCubit(),
      child: const _AiTripBody(),
    );
  }
}

class _AiTripBody extends StatefulWidget {
  const _AiTripBody();

  @override
  State<_AiTripBody> createState() => _AiTripBodyState();
}

class _AiTripBodyState extends State<_AiTripBody> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiTripCubit, AiTripStates>(
      listener: (context, state) {
        if (state is AiTripSuccess) {
          navigateAndReplace(
              context, AiItineraryScreen(itinerary: state.itinerary));
        } else if (state is AiTripError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final cubit = AiTripCubit.get(context);

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final textColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight;
        
        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            title: Text(
              'AI Trip Planner',
              style: GoogleFonts.playfairDisplay(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? AppColors.green300 : AppColors.primary),
          ),
          body: state is AiTripLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: isDark ? AppColors.green300 : AppColors.primary),
                      const SizedBox(height: 16),
                      Text("Crafting your perfect itinerary...", style: TextStyle(color: textColor)),
                    ],
                  ),
                )
              : Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: isDark 
                        ? const ColorScheme.dark(primary: AppColors.green300, surface: AppColors.surfaceDark)
                        : const ColorScheme.light(primary: AppColors.primary, surface: AppColors.surfaceLight),
                  ),
                  child: Stepper(
                    currentStep: cubit.currentStep,
                    type: StepperType.vertical,
                    onStepTapped: (step) => cubit.setStep(step),
                    onStepContinue: () {
                      if (cubit.currentStep < 2) {
                        cubit.setStep(cubit.currentStep + 1);
                      } else {
                        cubit.generateTripPlan();
                      }
                    },
                    onStepCancel: () {
                      if (cubit.currentStep > 0) {
                        cubit.setStep(cubit.currentStep - 1);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? AppColors.green300 : AppColors.primary,
                                  foregroundColor: isDark ? AppColors.green950 : Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: Text(
                                  cubit.currentStep == 2
                                      ? 'Generate Plan'
                                      : 'Continue',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            if (cubit.currentStep > 0) const SizedBox(width: 12),
                            if (cubit.currentStep > 0)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark ? AppColors.green300 : AppColors.primary,
                                    side: BorderSide(
                                        color: isDark ? AppColors.green300 : AppColors.primary, width: 1.5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                  ),
                                  child: Text('Back',
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                    steps: [
                      _buildStep1(cubit, isDark, textColor),
                      _buildStep2(cubit, isDark, textColor),
                      _buildStep3(cubit, isDark, textColor),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Step _buildStep1(AiTripCubit cubit, bool isDark, Color textColor) {
    final activeColor = isDark ? AppColors.green300 : AppColors.primary;
    return Step(
      title: Text('Logistics', style: TextStyle(color: textColor)),
      subtitle: Text('Transport and Accommodation', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
      isActive: cubit.currentStep >= 0,
      state: cubit.currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        children: [
          SwitchListTile(
            activeThumbColor: activeColor,
            title: Text('Rent a Car?', style: TextStyle(color: textColor)),
            subtitle: Text('Will you have your own transport?', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
            value: cubit.rentCar,
            onChanged: cubit.toggleRentCar,
            secondary: Icon(Icons.directions_car, color: activeColor),
          ),
          SwitchListTile(
            activeThumbColor: activeColor,
            title: Text('Book Accommodation?', style: TextStyle(color: textColor)),
            subtitle: Text('Do you need us to suggest stays?', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
            value: cubit.bookAccommodation,
            onChanged: cubit.toggleAccommodation,
            secondary: Icon(Icons.hotel, color: activeColor),
          ),
        ],
      ),
    );
  }

  Step _buildStep2(AiTripCubit cubit, bool isDark, Color textColor) {
    return Step(
      title: Text('Select Categories', style: TextStyle(color: textColor)),
      subtitle: Text('What types of places do you prefer?', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
      isActive: cubit.currentStep >= 1,
      state: cubit.currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: PlacesCategory.values.map((cat) {
            final isSelected = cubit.selectedCategories.contains(cat);
            final label = cat.name[0].toUpperCase() + cat.name.substring(1);
            return FilterChip(
              label: Text(label, style: TextStyle(color: isSelected && !isDark ? AppColors.green950 : textColor)),
              selected: isSelected,
              selectedColor: isDark ? AppColors.green700 : AppColors.accent,
              backgroundColor: isDark ? AppColors.surfaceVariantD : AppColors.surfaceVariantL,
              onSelected: (val) => cubit.toggleCategorySelection(cat),
            );
          }).toList(),
        ),
      ),
    );
  }

  Step _buildStep3(AiTripCubit cubit, bool isDark, Color textColor) {
    final inputStyle = TextStyle(color: textColor);
    final labelStyle = TextStyle(color: textColor.withValues(alpha: 0.7));
    return Step(
      title: Text('Trip Details', style: TextStyle(color: textColor)),
      subtitle: Text('Budget, Age, Trip length', style: TextStyle(color: textColor.withValues(alpha: 0.7))),
      isActive: cubit.currentStep >= 2,
      state: cubit.currentStep == 2 ? StepState.editing : StepState.indexed,
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: cubit.budget.toString(),
                  style: inputStyle,
                  decoration: InputDecoration(labelText: 'Budget (TND)', labelStyle: labelStyle),
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      cubit.updateBudget(double.tryParse(val) ?? 500.0),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: cubit.tripLength.toString(),
                  style: inputStyle,
                  decoration: InputDecoration(labelText: 'Trip Length (Days)', labelStyle: labelStyle),
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      cubit.updateTripLength(int.tryParse(val) ?? 3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: cubit.age.toString(),
                  style: inputStyle,
                  decoration: InputDecoration(labelText: 'Age', labelStyle: labelStyle),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => cubit.updateAge(int.tryParse(val) ?? 25),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: cubit.groupNumber.toString(),
                  style: inputStyle,
                  decoration: InputDecoration(labelText: 'Group Number', labelStyle: labelStyle),
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      cubit.updateGroupNumber(int.tryParse(val) ?? 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: ['Family Friendly', 'Budget Friendly', 'Luxury', 'Relaxing', 'Adventure', 'Romantic', 'Vegan Options', 'Accessible']
                .map((pref) {
              final isSelected = cubit.selectedPreferences.contains(pref);
              return FilterChip(
                label: Text(pref, style: TextStyle(color: isSelected && !isDark ? AppColors.green950 : textColor)),
                selected: isSelected,
                selectedColor: isDark ? AppColors.green700 : AppColors.accent,
                backgroundColor: isDark ? AppColors.surfaceVariantD : AppColors.surfaceVariantL,
                onSelected: (val) => cubit.togglePreference(pref),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
