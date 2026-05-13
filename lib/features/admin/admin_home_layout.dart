import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tunisian_trip_planner/features/admin/cubit/admin_cubit.dart';
import 'package:tunisian_trip_planner/features/admin/cubit/admin_states.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/auth/widgets/login_screen.dart';
import 'package:tunisian_trip_planner/shared/widgets/components.dart';
import 'package:tunisian_trip_planner/shared/widgets/navigation.dart';

class AdminHomeLayout extends StatelessWidget {
  const AdminHomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminCubit()
        ..getInactivePlaces()
        ..getInactiveAccommodations()
        ..getInactiveTransports(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: HexColor('#14746f'),
            title: Text(
              'Admin Dashboard',
              style: GoogleFonts.playfairDisplay(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Places'),
                Tab(text: 'Accommodations'),
                Tab(text: 'Transports'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () async {
                  await AuthCubit.get(context).logout();
                  if (context.mounted) {
                    navigateAndRemoveAll(context, const LoginScreen());
                  }
                },
              )
            ],
          ),
          body: BlocListener<AdminCubit, AdminStates>(
            listener: (context, state) {
              if (state is AdminActionSuccessState) {
                showToast(msg: state.message, state: ToastStates.success);
              } else if (state is AdminActionErrorState) {
                showToast(msg: state.message, state: ToastStates.error);
              }
            },
            child: const TabBarView(
              children: [
                _InactivePlacesList(),
                _InactiveAccommodationsList(),
                _InactiveTransportsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InactivePlacesList extends StatelessWidget {
  const _InactivePlacesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      buildWhen: (previous, current) =>
          current is AdminLoadingPlacesState ||
          current is AdminLoadedPlacesState ||
          current is AdminErrorPlacesState,
      builder: (context, state) {
        final cubit = AdminCubit.get(context);

        if (state is AdminLoadingPlacesState && cubit.inactivePlaces.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminErrorPlacesState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.message}\nCheck console for details.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (cubit.inactivePlaces.isEmpty) {
          return const Center(child: Text('No inactive places found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cubit.inactivePlaces.length,
          itemBuilder: (context, index) {
            final place = cubit.inactivePlaces[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(place.name ?? 'Unknown Place',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${place.cityName} • ${place.category?.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => cubit.activatePlace(place.id!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        title: 'Delete Place',
                        onConfirm: () => cubit.deletePlace(place.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InactiveAccommodationsList extends StatelessWidget {
  const _InactiveAccommodationsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      buildWhen: (previous, current) =>
          current is AdminLoadingAccommodationsState ||
          current is AdminLoadedAccommodationsState ||
          current is AdminErrorAccommodationsState,
      builder: (context, state) {
        final cubit = AdminCubit.get(context);

        if (state is AdminLoadingAccommodationsState &&
            cubit.inactiveAccommodations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminErrorAccommodationsState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.message}\nCheck console for details.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (cubit.inactiveAccommodations.isEmpty) {
          return const Center(
              child: Text('No inactive accommodations found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cubit.inactiveAccommodations.length,
          itemBuilder: (context, index) {
            final acc = cubit.inactiveAccommodations[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(acc.name ?? 'Unknown Accommodation',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${acc.city} • ${acc.accommodationType?.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => cubit.activateAccommodation(acc.id!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        title: 'Delete Accommodation',
                        onConfirm: () => cubit.deleteAccommodation(acc.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InactiveTransportsList extends StatelessWidget {
  const _InactiveTransportsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminStates>(
      buildWhen: (previous, current) =>
          current is AdminLoadingTransportsState ||
          current is AdminLoadedTransportsState ||
          current is AdminErrorTransportsState,
      builder: (context, state) {
        final cubit = AdminCubit.get(context);

        if (state is AdminLoadingTransportsState &&
            cubit.inactiveTransports.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminErrorTransportsState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${state.message}\nCheck console for details.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (cubit.inactiveTransports.isEmpty) {
          return const Center(child: Text('No inactive transports found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cubit.inactiveTransports.length,
          itemBuilder: (context, index) {
            final trans = cubit.inactiveTransports[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(trans.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${trans.cityId} • ${trans.type.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => cubit.activateTransport(trans.id!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        context,
                        title: 'Delete Transport',
                        onConfirm: () => cubit.deleteTransport(trans.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── Helper dialog for deletion confirmation ────────────────────────────────
void _confirmDelete(BuildContext context,
    {required String title, required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: const Text('Are you sure you want to delete this item? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
