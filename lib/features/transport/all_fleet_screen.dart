import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/transport/car_detail_screen.dart';
import 'package:tunisian_trip_planner/features/transport/enums/fuel_type.dart';
import 'package:tunisian_trip_planner/features/transport/models/transport_model.dart';
import 'package:tunisian_trip_planner/features/transport/models/vehicle_model.dart';
import 'package:tunisian_trip_planner/features/transport/widgets/vehicle_card.dart';
import 'package:tunisian_trip_planner/shared/network/remote/dio_helper.dart';
import 'package:tunisian_trip_planner/shared/network/remote/end_points.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class AllFleetScreen extends StatefulWidget {
  final TransportModel transport;

  const AllFleetScreen({super.key, required this.transport});

  @override
  State<AllFleetScreen> createState() => _AllFleetScreenState();
}

class _AllFleetScreenState extends State<AllFleetScreen> {
  bool _isLoading = true;
  String? _error;
  List<VehicleModel> _allVehicles = [];
  List<VehicleModel> _filteredVehicles = [];

  // Filters & Search
  String _searchQuery = '';
  FuelType? _selectedFuelType;
  String? _selectedVehicleType;

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchVehicles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchVehicles() async {
    try {
      if (widget.transport.id == null) {
        throw Exception('Transport ID is null');
      }
      final response = await DioHelper.getData(
        url: EndPoints.vehiclesByTransport(widget.transport.id!),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        _allVehicles = data.map((json) => VehicleModel.fromJson(json)).toList();
      } else {
        _error = 'Failed to fetch vehicles: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('[AllFleetScreen] API Error: $e');
      // Fallback to locally loaded vehicles if API fails
      _allVehicles = widget.transport.vehicles;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _applyFilters();
        });
      }
    }
  }

  void _applyFilters() {
    _filteredVehicles = _allVehicles.where((v) {
      // Search by model or type
      final matchesSearch = _searchQuery.isEmpty ||
          v.vehicleModel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.vehicleType.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesFuel =
          _selectedFuelType == null || v.fuelType == _selectedFuelType;
      final matchesType = _selectedVehicleType == null ||
          _selectedVehicleType == 'All' ||
          v.vehicleType == _selectedVehicleType;

      return matchesSearch && matchesFuel && matchesType;
    }).toList();
  }

  Set<String> get _availableVehicleTypes {
    final types = _allVehicles.map((v) => v.vehicleType).toSet();
    return {'All', ...types};
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final cs = theme.colorScheme;
            
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Fleet',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Fuel Type
                  Text(
                    'Fuel Type',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: _selectedFuelType == null,
                        onSelected: (selected) {
                          setModalState(() => _selectedFuelType = null);
                        },
                        cs: cs,
                        isDark: isDark,
                      ),
                      ...FuelType.values.map((fuel) {
                        return _buildFilterChip(
                          label: fuel.name.toUpperCase(),
                          isSelected: _selectedFuelType == fuel,
                          onSelected: (selected) {
                            setModalState(() => _selectedFuelType = fuel);
                          },
                          cs: cs,
                          isDark: isDark,
                        );
                      }),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Vehicle Type
                  Text(
                    'Vehicle Type',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableVehicleTypes.map((type) {
                      final isSelected = _selectedVehicleType == type || (_selectedVehicleType == null && type == 'All');
                      return _buildFilterChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (type == 'All') {
                              _selectedVehicleType = null;
                            } else {
                              _selectedVehicleType = type;
                            }
                          });
                        },
                        cs: cs,
                        isDark: isDark,
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _applyFilters();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return FilterChip(
      selected: isSelected,
      onSelected: onSelected,
      label: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? cs.onPrimary : cs.onSurface,
        ),
      ),
      backgroundColor: isDark ? AppColors.surfaceVariantD : AppColors.surfaceVariantL,
      selectedColor: cs.primary,
      checkmarkColor: cs.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? cs.primary : Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Our Fleet',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: cs.onSurface),
      ),
      body: Column(
        children: [
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _applyFilters();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search vehicles...',
                      hintStyle: GoogleFonts.dmSans(color: AppColors.mutedText),
                      prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
                      filled: true,
                      fillColor: isDark ? AppColors.surfaceVariantD : AppColors.surfaceVariantL,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: cs.primary))
                : _error != null && _allVehicles.isEmpty
                    ? Center(child: Text(_error!))
                    : _filteredVehicles.isEmpty
                        ? Center(
                            child: Text(
                              'No vehicles found.',
                              style: GoogleFonts.dmSans(
                                color: AppColors.mutedText,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = _filteredVehicles[index];
                              return VehicleCard(
                                vehicle: vehicle,
                                onTap: () {
                                  navigateTo(context, CarDetailScreen(vehicle: vehicle));
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
