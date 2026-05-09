import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_cubit.dart';
import 'package:tunisian_trip_planner/features/places/cubit/add_place_states.dart';
import 'package:tunisian_trip_planner/features/places/models/places_category.dart';
import 'package:tunisian_trip_planner/shared/widgets/place_image_widget.dart';

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
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _mainImageController = TextEditingController();
  final _galleryUrlController = TextEditingController();

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
    _latController.dispose();
    _lngController.dispose();
    _mainImageController.dispose();
    _galleryUrlController.dispose();
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
            SnackBar(
              content: const Text('Place added successfully! 🎉'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context);
        } else if (state is AddPlaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = AddPlaceCubit.get(context);
        final isLoading = state is AddPlaceLoading;

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

                  // ── Main Image URL ────────────────────────────────
                  _SectionTitle(title: 'Main Photo URL (Required)'),
                  const SizedBox(height: 12),
                  _CustomTextField(
                    controller: _mainImageController,
                    label: 'Main Image URL',
                    icon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onChanged: (val) => cubit.setMainImageUrl(val),
                  ),
                  const SizedBox(height: 12),

                  // Live preview of main image
                  if (cubit.mainImageUrl.isNotEmpty)
                    Container(
                      height: 180,
                      width: double.infinity,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                      ),
                      child: PlaceImageWidget(
                        imageUrl: cubit.mainImageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outline.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, size: 36, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('Enter a URL above to preview the image',
                              style: GoogleFonts.dmSans(color: cs.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13)),
                        ],
                      ),
                    ),

                  // ── Gallery Images ────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Gallery Photos (Optional)'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _galleryUrlController,
                          keyboardType: TextInputType.url,
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            labelText: 'Gallery Image URL',
                            prefixIcon: Icon(Icons.add_photo_alternate_rounded, color: cs.primary),
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
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          final url = _galleryUrlController.text.trim();
                          if (url.isNotEmpty) {
                            cubit.addGalleryImageUrl(url);
                            _galleryUrlController.clear();
                          }
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),

                  if (cubit.galleryImageUrls.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cubit.galleryImageUrls.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: cs.surfaceContainerHighest,
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: PlaceImageWidget(
                                  imageUrl: cubit.galleryImageUrls[index],
                                  fit: BoxFit.cover,
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
                  ],

                  // ── Basic Details ─────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Basic Details'),
                  const SizedBox(height: 12),
                  _CustomTextField(
                    controller: _nameController,
                    label: 'Place Name',
                    icon: Icons.place_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _descController,
                    label: 'Description',
                    icon: Icons.description_rounded,
                    maxLines: 4,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),

                  // ── Category ──────────────────────────────────────
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
                            child: Text(
                              cat.name.toUpperCase(),
                              style: TextStyle(color: cs.onSurface),
                            ),
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

                  // ── Location ──────────────────────────────────────
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
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CustomTextField(
                          controller: _stateController,
                          label: 'State / Governorate',
                          icon: Icons.map_rounded,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _CustomTextField(
                    controller: _addressController,
                    label: 'Full Address',
                    icon: Icons.home_rounded,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _latController,
                          label: 'Latitude',
                          icon: Icons.my_location_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CustomTextField(
                          controller: _lngController,
                          label: 'Longitude',
                          icon: Icons.my_location_rounded,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),

                  // ── Contact & Pricing ─────────────────────────────
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
                    label: 'Average Price (TND)',
                    icon: Icons.attach_money_rounded,
                    keyboardType: TextInputType.number,
                  ),

                  // ── Submit ────────────────────────────────────────
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
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                cubit.submitPlace(
                                  name: _nameController.text.trim(),
                                  description: _descController.text.trim(),
                                  cityName: _cityController.text.trim(),
                                  stateName: _stateController.text.trim(),
                                  address: _addressController.text.trim(),
                                  phoneNumber: _phoneController.text.trim(),
                                  email: _emailController.text.trim(),
                                  averagePrice: double.tryParse(_priceController.text) ?? 0.0,
                                  latitude: double.tryParse(_latController.text) ?? 0.0,
                                  longitude: double.tryParse(_lngController.text) ?? 0.0,
                                  category: _selectedCategory,
                                );
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
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

// ─────────────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
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
      onChanged: onChanged,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.primary),
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariantD : cs.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: cs.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }
}
