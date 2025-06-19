// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  final String requestId;
  const MapPage({super.key, required this.requestId});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  StreamSubscription<LocationData>? _locationSubscription;
  final Location _locationController = Location();
  final PolylinePoints polylinePoints = PolylinePoints();
  double? customerLat;
  double? customerLon;
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  static const LatLng workerLocation = LatLng(37.4223, -122.0848);
  LatLng? customerLocation;
  LatLng? _currentP;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    fetchLocations();
    getLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController.future.then((controller) {
      controller.dispose();
    });

    super.dispose();
  }

  Future<void> fetchLocations() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> requestSnapshot =
          await FirebaseFirestore.instance
              .collection("requests")
              .doc(widget.requestId)
              .get();

      String customerId = requestSnapshot.data()?['requesterUID'];
      DocumentSnapshot<Map<String, dynamic>> customerSnapshot =
          await FirebaseFirestore.instance
              .collection("customers")
              .doc(customerId)
              .get();

      setState(() {
        customerLat = customerSnapshot.data()?['latitude'];
        customerLon = customerSnapshot.data()?['longitude'];
        customerLocation = LatLng(customerLat!, customerLon!);
      });

      if (_currentP != null && customerLocation != null) {
        await getPolylinePoints(_currentP!.latitude, _currentP!.longitude,
            customerLat!, customerLon!);
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  Future<void> getPolylinePoints(
      double startLat, double startLng, double destLat, double destLng) async {
    const String apiKey = 'AIzaSyBPBQSC5EENq7OBNeZNRtOgl37mvZUEgtQ';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$destLat,$destLng&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final decodedPoints = data['routes'][0]['overview_polyline']['points'];
      final List<LatLng> points = polylinePoints
          .decodePolyline(decodedPoints)
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      generatePolyLineFromPoints(points);
    } else {
      throw Exception('Failed to load polyline data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Image(
            image: AssetImage('assets/images/logo.jpeg'),
            height: 100,
          ),
        ],
      ),
      body: _currentP == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                // Complete _mapController and add polylines
                _mapController.complete(controller);
                addPolylinesToMap();
              },
              initialCameraPosition: const CameraPosition(
                target: workerLocation,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  position: _currentP!,
                ),
                const Marker(
                    markerId: MarkerId("_sourceLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: workerLocation),
                if (customerLocation != null)
                  Marker(
                      markerId: const MarkerId("_destinationLocation"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: customerLocation!)
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> addPolylinesToMap() async {
    if (_currentP != null && customerLocation != null) {
      await getPolylinePoints(_currentP!.latitude, _currentP!.longitude,
          customerLat!, customerLon!);
    }
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Subscribe to location updates
    _locationSubscription = _locationController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _cameraToPosition(_currentP!);
        });
      }
    });
  }

  Future<void> generatePolyLineFromPoints(
      List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }
}
