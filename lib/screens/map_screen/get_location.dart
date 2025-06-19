import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeas/screens/map_screen/cubit/location_info_cubit.dart';
import 'package:jeas/screens/map_screen/cubit/location_state.dart';

class GetLocation extends StatelessWidget {
  final String person;
  const GetLocation(this.person, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => LocationCubit()..getInitialLocation(person),
        child: const LocationMap(),
      ),
    );
  }
}

class LocationMap extends StatelessWidget {
  const LocationMap({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is LocationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LocationLoaded) {
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(state.lat, state.lon),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('currentLocation'),
                position: LatLng(state.lat, state.lon),
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            },
          );
        } else {
          return const Center(child: Text('Failed to load location'));
        }
      },
    );
  }
}
