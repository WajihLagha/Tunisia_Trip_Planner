import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_cubit.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';

class AddPlaceScreen extends StatelessWidget {
  const AddPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddPlaceCubit(),
      child: const _AddPlaceView(),
    );
  }
}

class _AddPlaceView extends StatefulWidget {
  const _AddPlaceView();

  @override
  State<_AddPlaceView> createState() => _AddPlaceViewState();
}

class _AddPlaceViewState extends State<_AddPlaceView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _priceController = TextEditingController();
  
  PlacesCategory _selectedCategory = PlacesCategory.history;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<AddPlaceCubit, AddPlaceStates>(
      listener: (context, state) {
        if (state is AddPlaceSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Place added successfully!')),
          );
          Navigator.pop(context);
        } else if (state is AddPlaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final cubit = AddPlaceCubit.get(context);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.green700,
            title: Text(
              'Add Place',
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
                    label: 'Place Name',
                    icon: Icons.place_rounded,
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
                  _SectionTitle(title: 'Category'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<PlacesCategory>(
                        value: _selectedCategory,
                        isExpanded: true,
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        items: PlacesCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Location Details'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city_rounded,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CustomTextField(
                          controller: _stateController,
                          label: 'State',
                          icon: Icons.map_rounded,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _addressController,
                    label: 'Full Address',
                    icon: Icons.home_rounded,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Contact & Pricing'),
                  const SizedBox(height: 12),
                  _CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number (Optional)',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _emailController,
                    label: 'Email (Optional)',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _priceController,
                    label: 'Average Price (\$)',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
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
                      onPressed: state is AddPlaceLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                cubit.submitPlace(
                                  name: _nameController.text,
                                  description: _descController.text,
                                  cityName: _cityController.text,
                                  stateName: _stateController.text,
                                  address: _addressController.text,
                                  phoneNumber: _phoneController.text,
                                  email: _emailController.text,
                                  averagePrice: double.tryParse(_priceController.text) ?? 0.0,
                                  category: _selectedCategory,
                                );
                              }
                            },
                      child: state is AddPlaceLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Add Place',
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
