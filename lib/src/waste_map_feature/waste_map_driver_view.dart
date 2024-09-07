import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashtrek/common/strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class WasteMapDriverView extends StatefulWidget {
  final List<LatLng> appointments;
  const WasteMapDriverView({
    super.key,
    this.appointments = const [LatLng(6.920840, 79.965214),LatLng(6.919864, 79.975036),LatLng(6.924735, 79.968814),LatLng(6.915975, 79.970694),LatLng(6.924028, 79.964268),LatLng(6.922649, 79.973089),LatLng(6.919114, 79.974789),LatLng(6.916233, 79.974156),]
  });

  @override
  WasteMapDriverViewState createState() => WasteMapDriverViewState();
}

class WasteMapDriverViewState extends State<WasteMapDriverView> {
  late StreamSubscription<Position> _positionStreamSubscription;
  late StreamSubscription<CompassEvent> _headingStreamSubscription;
  GoogleMapController? mapController;
  late double currentZoomLevel;
  final List _instructions = [];
  int _currentInstructionIndex = 0;
  double? _currentHeading;
  bool routeReady = false;
  bool journeyStarted = false;
  bool ignoreMove = false;
  bool isCentered = false;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(37.4219983, -122.084);
  List<LatLng> _routePoints = [];
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _getCompassHeading();
    _requestLocationPermission();
    _displayAppointments();
  }

  @override
  void dispose() {
    // Cancel the position stream subscription when the widget is disposed
    _positionStreamSubscription.cancel();
    _headingStreamSubscription.cancel();
    super.dispose();
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
    // final icondescriptor = await BitmapDescriptor.asset(ImageConfiguration.empty, 'assets/truck.png');
    setState(() {
      _initialPosition = LatLng(currentLocation.latitude, currentLocation.longitude); 
      _loadRoute();
      // icon = icondescriptor;
    });

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        // distanceFilter: 10
      )
    ).listen((Position position) async {
      if (mounted) {
        double? zoomLevel = await mapController?.getZoomLevel();

        if (_instructions.isNotEmpty && _currentInstructionIndex < _instructions.length) {
          double distanceToNextTurn = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            _instructions[_currentInstructionIndex]['location']?.latitude,
            _instructions[_currentInstructionIndex]['location']?.longitude,
          );

          if (distanceToNextTurn < 30) { // Within 30 meters of the next turn
            setState(() {
              _currentInstructionIndex++; // Move to the next turn instruction
              _speakTurnInstruction(_instructions[_currentInstructionIndex]['instruction'].replaceAll(RegExp(r'<[^>]*>'), ''));
            });
          }
        } else {
          print('No instructions available or invalid index');
        }

        if(isCentered && journeyStarted){
          mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: zoomLevel ?? 15.0,
                bearing: _currentHeading ?? 0,
                tilt: 45
              ),
            ),
          );
        }

        setState(() {
          _initialPosition = LatLng(position.latitude, position.longitude);
          currentZoomLevel = zoomLevel ?? 15.0;

          // _markers.removeWhere((marker) => marker.markerId.value == 'current_location'); // Remove old marker
          // _markers.add(
          //   Marker(
          //     markerId: const MarkerId('current_location'),
          //     position: _initialPosition,
          //   ),
          // );
        });
      }
    });
  }

  void _getCompassHeading() {
    _headingStreamSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        _currentHeading = event.heading; 
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
      // final route = data['routes'][0]['overview_polyline']['points'];

      final route = data['routes'][0];
      final legs = route['legs'];

      // Parse the steps for turn-by-turn instructions
      for(var leg in legs){
        final steps = leg['steps'];
        for (var step in steps) {
          final instruction = step['html_instructions']; // Contains turn instructions in HTML format
          final distance = step['distance']['text'];
          final duration = step['duration']['text'];
          final location = LatLng(step['end_location']['lat'], step['end_location']['lng']);
          
          print('Turn Instruction: $instruction, Distance: $distance, Duration: $duration');
          _instructions.add({
            'instruction': instruction,
            'location': location,
            'distance': distance,
            'duration': duration
          });
        }
      }
      

      return decodePoly(route['overview_polyline']['points']);
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
      List<List<LatLng>> chunks = [];
      List<LatLng> totalSnapPoints = [];
      final routePoints = await fetchRoute(
        _initialPosition,
        widget.appointments,
        _initialPosition, // Assuming the last stop is the final destination
      );

      for (var i = 0; i < routePoints.length; i += 100) {
        chunks.add(routePoints.sublist(i, i + 100 > routePoints.length ? routePoints.length : i + 100));
      }

      for (var chunk in chunks) {
        final snapPoints = await fetchSnappedRoute(chunk);
        totalSnapPoints.addAll(snapPoints);
      }

      setState(() {
        _routePoints = totalSnapPoints;
        routeReady = true;
        isCentered = true;
        ignoreMove = true;
      });

      mapController?.animateCamera(
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

  void _startJourney() async {
    setState(() {
      isCentered = true;
      journeyStarted = true;
      ignoreMove = true;
    });
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _initialPosition,
          zoom: 20,
          bearing: _currentHeading ?? 0,
          tilt: 45,
        )
      )
    );
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      ignoreMove = false;
    });
    
    _speakTurnInstruction(_instructions[_currentInstructionIndex]['instruction'].replaceAll(RegExp(r'<[^>]*>'), ''));
  }


  Future<void> _speakTurnInstruction(String instruction) async {
    await flutterTts.speak(instruction);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Route'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraMove: (position) {
              const double tolerance = 0.00001;
              if (!ignoreMove && !((position.target.latitude - _initialPosition.latitude).abs() < tolerance && (position.target.longitude - _initialPosition.longitude).abs() < tolerance)){
                setState(() {
                  isCentered = false;
                });
              }
            },
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
            mapToolbarEnabled: true,
            compassEnabled: true,
          ),
          (_instructions.isEmpty || !journeyStarted) ? 
          const SizedBox.shrink() :
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      _instructions[_currentInstructionIndex]['instruction'].replaceAll(RegExp(r'<[^>]*>'), ''),
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text('Next turn in ${_instructions[_currentInstructionIndex]['distance']}'),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: routeReady ? 
          (isCentered ? 
            (!journeyStarted ? 
              ElevatedButton(
                onPressed: () {
                  _startJourney();  // Start journey when camera is centered
                },
                child: const Text('Start Journey'),
              ) 
            : null)
          : 
            ElevatedButton(
              onPressed: () {
                _startJourney();
              },
              child: const Text('Recenter'),
            )
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}
