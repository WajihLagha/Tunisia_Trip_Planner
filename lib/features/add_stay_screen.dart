import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/add_stay_cubit.dart';
import 'package:tunisian_trip_planner/features/accommodation/cubit/add_stay_states.dart';

class AddStayScreen extends StatelessWidget {
  const AddStayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddStayCubit(),
      child: const _AddStayView(),
    );
  }
}

class _AddStayView extends StatefulWidget {
  const _AddStayView();

  @override
  State<_AddStayView> createState() => _AddStayViewState();
}

class _AddStayViewState extends State<_AddStayView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  
  String _selectedPropertyType = 'Hotel';
  final _propertyTypes = ['Hotel', 'Resort', 'Villa', 'Apartment', 'Guesthouse', 'Hostel'];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AddStayCubit, AddStayStates>(
      listener: (context, state) {
        if (state is AddStaySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stay added successfully!')),
          );
          Navigator.pop(context);
        } else if (state is AddStayError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final cubit = AddStayCubit.get(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.green700,
            title: Text(
              'Add Stay',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Main Photo (Required)'),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => cubit.pickMainImage(),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: cubit.mainImage == null
                            ? Border.all(color: cs.outline.withValues(alpha: 0.3), style: BorderStyle.solid)
                            : null,
                      ),
                      child: cubit.mainImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(cubit.mainImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, size: 40, color: cs.primary),
                                const SizedBox(height: 8),
                                Text('Tap to upload main photo', style: TextStyle(color: cs.onSurfaceVariant)),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Gallery Photos (Optional)'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: cubit.galleryImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == cubit.galleryImages.length) {
                          return GestureDetector(
                            onTap: () => cubit.pickGalleryImages(),
                            child: Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(Icons.add_rounded, color: cs.primary, size: 32),
                              ),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(cubit.galleryImages[index], fit: BoxFit.cover),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => cubit.removeGalleryImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Basic Details'),
                  const SizedBox(height: 12),
                  _CustomTextField(
                    controller: _nameController,
                    label: 'Property Name',
                    icon: Icons.hotel_rounded,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _descController,
                    label: 'Description',
                    icon: Icons.description_rounded,
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Property Type'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPropertyType,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        items: _propertyTypes.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedPropertyType = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Location & Pricing'),
                  const SizedBox(height: 12),
                  _CustomTextField(
                    controller: _locationController,
                    label: 'Location (City, Area)',
                    icon: Icons.location_on_rounded,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _priceController,
                    label: 'Price per Night (\$)',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: state is AddStayLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                cubit.submitStay(
                                  name: _nameController.text,
                                  description: _descController.text,
                                  location: _locationController.text,
                                  pricePerNight: double.tryParse(_priceController.text) ?? 0.0,
                                  propertyType: _selectedPropertyType,
                                );
                              }
                            },
                      child: state is AddStayLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Stay',
                              style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary),
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }
}
