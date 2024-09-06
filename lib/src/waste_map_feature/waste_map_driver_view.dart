import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashtrek/common/strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WasteMapDriverView extends StatefulWidget {
  final List<LatLng> appointments;
  const WasteMapDriverView({
    super.key,
    this.appointments = const [LatLng(6.9264944, 79.9727031),LatLng(6.5358627, 80.264653),LatLng(7.4252148, 79.8310073),LatLng(5.9532294, 80.5476227),LatLng(6.9151983, 79.9730228),]
  });

  @override
  WasteMapDriverViewState createState() => WasteMapDriverViewState();
}

class WasteMapDriverViewState extends State<WasteMapDriverView> {
  late GoogleMapController mapController;
  late double currentZoomLevel;
  bool moveCamera = true;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(37.4219983, -122.084);
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _displayAppointments();
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
    var currentLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(currentLocation.latitude, currentLocation.longitude);      
      _loadRoute();
    });

    Geolocator.getPositionStream().listen((Position position) async {
      double zoomLevel = await mapController.getZoomLevel();
      if(moveCamera){
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: zoomLevel,
            ),
          ),
        );
      }

      setState(() {
        currentZoomLevel = zoomLevel;
        moveCamera = false;
      });
    });
  }

  void _displayAppointments() async {
    for (LatLng appointment in widget.appointments) {
      _addMarker(appointment, '');
    }
  }

  String getDirectionsUrl(LatLng origin, List<LatLng> waypoints, LatLng destination) {
    final waypointsString = waypoints.map((e) => '${e.latitude},${e.longitude}').join('|');
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=optimize:true|$waypointsString&key=AIzaSyAF7z74_GI2uDrs1tJaar3fxmkwHAqI4SA';
    return url;
  }

  Future<List<LatLng>> fetchRoute(LatLng origin, List<LatLng> waypoints, LatLng destination) async {
    final url = getDirectionsUrl(origin, waypoints, destination);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final route = data['routes'][0]['overview_polyline']['points'];
      return decodePoly(route);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  String getSnapToRoadsUrl(List<LatLng> waypoints) {
    final pathString = waypoints.map((e) => '${e.latitude},${e.longitude}').join('|');
    
    final url = 'https://roads.googleapis.com/v1/snapToRoads?path=$pathString&interpolate=true&key=AIzaSyAF7z74_GI2uDrs1tJaar3fxmkwHAqI4SA';
    return url;
  }


  Future<List<LatLng>> fetchSnappedRoute(List<LatLng> waypoints) async {
    final url = getSnapToRoadsUrl(waypoints);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final snappedPoints = data['snappedPoints'] as List;

      // Convert the snapped points to LatLng list
      return snappedPoints.map<LatLng>((point) {
        final location = point['location'];
        return LatLng(location['latitude'], location['longitude']);
      }).toList();
    } else {
      throw Exception('Failed to snap to roads');
    }
  }



  List<LatLng> decodePoly(String encoded) {
    var poly = <LatLng>[];
    var index = 0;
    var len = encoded.length;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int b;
      var shift = 0;
      var result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      var dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      var dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      var p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  void _loadRoute() async {
    try {
      final routePoints = await fetchRoute(
        _initialPosition,
        widget.appointments,
        _initialPosition, // Assuming the last stop is the final destination
      );
      final snapPoints = await fetchSnappedRoute(
        routePoints, // Assuming the last stop is the final destination
      );
      setState(() {
        _routePoints = snapPoints;
      });
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
              _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
            ),
            northeast: LatLng(
              _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
              _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
            ),
          ),
          50.0,
        ),
      );
    } catch (e) {
      // Handle errors
      print(e);
    }
  }
  // Add a marker on the map
  void _addMarker(LatLng position, String label) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
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
        polylines: _routePoints.isNotEmpty
            ? {
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: _routePoints,
                ),
              }
            : {},
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        trafficEnabled: true,
      ),
    );
  }
}
