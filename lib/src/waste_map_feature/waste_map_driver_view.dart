import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashtrek/common/strings.dart';

class WasteMapDriverView extends StatefulWidget {
  const WasteMapDriverView({super.key});

  @override
  WasteMapDriverViewState createState() => WasteMapDriverViewState();
}

class WasteMapDriverViewState extends State<WasteMapDriverView> {
  late GoogleMapController mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(37.4219983, -122.084);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Request location permission and get the user's location
  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();

    if (!mounted) return;

    if (status.isGranted) {
      _getUserLocation();
    } else if (status.isDenied) {
      _showPermissionDeniedDialog();
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedDialog();
    }
  }

  // Show a dialog for denied permission
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(strings.permissionDenied),
        content: const Text(strings.pDeniedMessage1),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(strings.ok),
          ),
        ],
      ),
    );
  }

  // Show a dialog for permanently denied permission with a settings option
  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(strings.permissionDenied),
        content: const Text(strings.pDeniedMessage2),
        actions: [
        TextButton(
          onPressed: () {
            openAppSettings(); // Open app settings
            Navigator.pop(context); // Just close the dialog
            Navigator.pop(context); // Just close the dialog
          },
          child: const Text(strings.openSettings),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Just close the dialog
            Navigator.pop(context); // Just close the dialog
          },
          child: const Text('Cancel'),
        ),
      ],
      ),
    );
  }

  // Get the current location and start listening for location changes
  void _getUserLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = currentLocation;
    LatLng currentLatLng =
        LatLng(currentLocation.latitude, currentLocation.longitude);

    _addMarker(currentLatLng, "Driver");

    // Update map position
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: currentLatLng,
          zoom: 15.0,
        ),
      ),
    );

    // Listen to location changes and update map
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        LatLng newLatLng = LatLng(position.latitude, position.longitude);
        _addMarker(newLatLng, "Driver");
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLatLng,
              zoom: 15.0,
            ),
          ),
        );
      });
    });
  }

  // Add a marker on the map
  void _addMarker(LatLng position, String label) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // Map creation callback
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Driver'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
      ),
    );
  }
}
