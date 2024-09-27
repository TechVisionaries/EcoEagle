import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/common/strings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/appointment_service.dart';
import 'package:trashtrek/src/waste_map_feature/route_model.dart';

class WasteMapDriverView extends StatefulWidget {
  const WasteMapDriverView({
    super.key,
  });

  @override
  WasteMapDriverViewState createState() => WasteMapDriverViewState();
}

class WasteMapDriverViewState extends State<WasteMapDriverView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<CompassEvent>? _headingStreamSubscription;
  GoogleMapController? mapController;
  final ApiService apiService = ApiService();
  late String _userID;
  late double currentZoomLevel;
  late MapRoute mapRoute = MapRoute(driver: '', locations: [], appointments: [], instructions: [], status: '');
  int _currentInstructionIndex = 0;
  int _currentAddressIndex = 0;
  double? _currentHeading;
  String? apiKey = dotenv.env[Constants.googleApiKey];
  bool routeReady = false;
  bool journeyStarted = false;
  bool ignoreMove = false;
  bool isCentered = false;
  bool isLoading = true;
  bool isOpen = false;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(37.4219983, -122.084);
  List<LatLng> _routePoints = [];
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCompassHeading();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    // Cancel the position stream subscription when the widget is disposed
    _positionStreamSubscription?.cancel();
    _headingStreamSubscription?.cancel();
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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if(!mounted) return;
    setState(() {
      _userID = prefs.getString('userID') ?? 'User';
    });
  }

  // Get the current location and start listening for location changes
  void _getUserLocation() async {
    var currentLocation = await Geolocator.getCurrentPosition(locationSettings: AndroidSettings(accuracy: LocationAccuracy.bestForNavigation));
    // final icondescriptor = await BitmapDescriptor.asset(ImageConfiguration.empty, 'assets/truck.png');
    if (mounted) {
    setState(() {
      _initialPosition = LatLng(currentLocation.latitude, currentLocation.longitude); 
      _loadRoute();
      // icon = icondescriptor;
    });
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      )
    ).listen((Position position) async {
      _updateLocationInFirestore(position);
      if (mounted) {
        double? zoomLevel = await mapController?.getZoomLevel();
        if (mapRoute.appointments.isNotEmpty && _currentAddressIndex < mapRoute.appointments.length && journeyStarted) {
          double distanceToNextStop = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            mapRoute.appointments[_currentAddressIndex].location.latitude,
            mapRoute.appointments[_currentAddressIndex].location.longitude,
          );

          if (distanceToNextStop < 10 && !isOpen) { // Within 10 meters of the next turn
            setState(() {
              isOpen = true;
              _stopCompleteDialog(mapRoute.appointments[_currentAddressIndex]);
              _currentAddressIndex++;
            });
          }
        } else {
          print('No addresses available or invalid index');
        }

        if (mapRoute.instructions.isNotEmpty && _currentInstructionIndex < mapRoute.instructions.length && journeyStarted) {
          double distanceToNextTurn = Geolocator.distanceBetween(
            currentLocation.latitude,
            currentLocation.longitude,
            mapRoute.instructions[_currentInstructionIndex].location.latitude,
            mapRoute.instructions[_currentInstructionIndex].location.longitude,
          );

          if (distanceToNextTurn < 30) { // Within 30 meters of the next turn
            setState(() {
              mapRoute.instructions[_currentInstructionIndex] = Instruction.fromJson({
                ...mapRoute.instructions[_currentInstructionIndex].toJson(),
                'isCompleted': true,
              });
              _speakTurnInstruction(mapRoute.instructions[_currentInstructionIndex].instruction.replaceAll(RegExp(r'<[^>]*>'), ''));
              _currentInstructionIndex++; // Move to the next turn instruction
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
    if(!mounted) return;
    _headingStreamSubscription = FlutterCompass.events!.listen((CompassEvent event) {
      setState(() {
        _currentHeading = event.heading; 
      });
    });
  }

  void _displayAppointments() async {
    for (var i = 0; i < mapRoute.locations.length; i++) {
      _addMarker(mapRoute.appointments[i].location, mapRoute.appointments[i].address);
    }
  }

  String getDirectionsUrl(LatLng origin, List<LatLng> waypoints, LatLng destination) {
    final waypointsString = waypoints.map((e) => '${e.latitude},${e.longitude}').join('|');
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=optimize:true|$waypointsString&key=$apiKey';
    return url;
  }

  Future<List<LatLng>> fetchRoute(LatLng origin, List<LatLng> waypoints, LatLng destination, List<Appointment> appts) async {
    final url = getDirectionsUrl(origin, waypoints, destination);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // final route = data['routes'][0]['overview_polyline']['points'];

      final route = data['routes'][0];
      final legs = route['legs'];

      // Parse the steps for turn-by-turn instructions
      List<MapAppointment> tempMapAppts = [];
      List<Instruction> tempInstructions = [];
      int i = 0;
      for(var leg in legs){
        final steps = leg['steps'];
        try {
          if(appts.isNotEmpty && i < appts.length){
          MapAppointment tmpMapApt = MapAppointment.fromJson({
            ...appts[i].toJson(),
            'address': leg['end_address'],
            'location': {'latitude': leg['end_location']['lat'], 'longitude':leg['end_location']['lng']},
            'duration': leg['duration']['text'],
            'distance': leg['distance']['text'],
            'durationValue': leg['duration']['value'],
            'distanceValue': leg['distance']['value'],
          });
          tempMapAppts.add(tmpMapApt);
          }
        } catch (e) {
          print(e);
        }
        
        // _appointmentList.add({
        //   'address': leg['end_address'],
        //   'location': LatLng(leg['end_location']['lat'], leg['end_location']['lng']),
        //   'duration': leg['duration']['text'],
        //   'distance': leg['distance']['text'],
        // });
        for (var step in steps) {
          final instruction = step['html_instructions']; // Contains turn instructions in HTML format
          final distance = step['distance']['text'];
          final duration = step['duration']['text'];
          final distanceValue = step['distance']['value'];
          final durationValue = step['duration']['value'];
          final location = LatLng(step['end_location']['lat'], step['end_location']['lng']);
          
          tempInstructions.add(Instruction.fromJson({
            'instruction': instruction,
            'location': {'latitude': location.latitude, 'longitude':location.longitude},
            'distance': distance,
            'duration': duration,
            'distanceValue': distanceValue,
            'durationValue': durationValue,
            'isCompleted': false
          }));
        }
        i++;
      }
      
      setState(() {
        mapRoute = MapRoute.fromJson({
          'driver': _userID,
          'instructions': tempInstructions,
          'appointments': tempMapAppts,
          'status': 'ready'
        });
      });

      _displayAppointments();
      return decodePoly(route['overview_polyline']['points']);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  String getSnapToRoadsUrl(List<LatLng> waypoints) {
    final pathString = waypoints.map((e) => '${e.latitude},${e.longitude}').join('|');
    
    final url = 'https://roads.googleapis.com/v1/snapToRoads?path=$pathString&interpolate=true&key=$apiKey';
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

  Future<List<Appointment>> _fetchAppointments() async {
    try {
      return await apiService.fetchDriverAppointments(_userID);
    } catch (e) {
      _showErrorMessage("Error: $e");
      return Future.error('Appontments not found');
    }
    
  }

  void _loadRoute() async {
    if(!mounted) return;
    try {
      List<List<LatLng>> chunks = [];
      List<LatLng> totalSnapPoints = [];
      List<LatLng> locs = [];
      late List<Appointment> tempAppts;
      try {
        tempAppts = await _fetchAppointments();
        for (var appointment in tempAppts) {
          locs.add(
            appointment.location
          );
        }
      } catch (e) {
        _showErrorMessage("Error: $e");
      }

      final routePoints = await fetchRoute(
        _initialPosition,
        locs,
        _initialPosition, // Assuming the last stop is the final destination,
        tempAppts
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
        isLoading = false;
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
  void _addMarker(LatLng position, String label, {double color = BitmapDescriptor.hueCyan}) {
    final marker = Marker(
      markerId: MarkerId(label),
      position: position,
      infoWindow: InfoWindow(title: label),
      icon: BitmapDescriptor.defaultMarkerWithHue(color),
    );

    setState(() {
      _markers.add(marker);
    });
  }

  // Map creation callback
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _startJourney({bool speak = true}) async {
    setState(() {
      isCentered = true;
      journeyStarted = true;
      ignoreMove = true;
      mapRoute = MapRoute(
        driver: mapRoute.driver,
        locations: mapRoute.locations,
        appointments: mapRoute.appointments,
        instructions: mapRoute.instructions,
        status: 'started', // Update status
      );
    });
    
    try {
      // Find the marker with MarkerId 'selected'
      Marker marker = _markers.firstWhere(
        (element) => element.markerId == const MarkerId("selected"),
      );

      // Remove the marker if found
      _markers.remove(marker);
    } catch (e) {
      // Handle the case where no marker is found
      print("Marker with ID 'selected' not found");
    }
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
    
    if(speak){
      _speakTurnInstruction(mapRoute.instructions[_currentInstructionIndex].instruction.replaceAll(RegExp(r'<[^>]*>'), ''));
    }
  }

  Future<void> _updateLocationInFirestore(Position position) async {
    _firestore.collection('drivers').doc(_userID).set({
      'driverLocation': GeoPoint(position.latitude, position.longitude),
      'journeyStarted': journeyStarted,
      ...mapRoute.toJson()
    });
  }

  Future<void> _speakTurnInstruction(String instruction) async {
    await flutterTts.speak(instruction);
  }

  void _showLocationOnMap(MapAppointment appointment, ScrollController scrollController){
    if(!journeyStarted){
      _addMarker(appointment.location, 'selected', color:BitmapDescriptor.hueRed);
      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(appointment.location.latitude - 0.0105, appointment.location.longitude),
            zoom: 15,
            bearing: 0,
          )
        )
      );
    }
  }

  void _stopCompleteDialog(MapAppointment currentAppointment) {
    final commentController = TextEditingController(text: currentAppointment.comment);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Arrived at stop!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Address: ${currentAppointment.address}"),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(!mounted) return;
              final comment = commentController.text;
              
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? '';

                if (token.isEmpty) {
                  throw Exception('Token is empty');
                }

                await apiService.completeAppointment(currentAppointment.id ?? "");
                setState(() {
                  _loadRoute(); // Refresh reviews after update
                });

                // Show success message
                _showSuccessMessage('Stop completed successfully!');
              } catch (e) {
                print('Error updating review: $e');
                _showErrorMessage('Failed to update stop: $e');
              } finally{
                setState(() {
                  isOpen = false;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  // Function to show a success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 0, 89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getTotalDistanceUpToIndex(int index) {
    // Summing all distance values from 0 to the current index and converting to kilometers
    double totalDistanceInMeters = mapRoute.appointments
        .take(index + 1)  // Only take elements up to the current index (inclusive)
        .map((appointment) => appointment.distanceValue)  // Extract the distanceValue from each appointment
        .fold(0.0, (prev, element) => prev + element);  // Sum up the distances

    double totalDistanceInKilometers = totalDistanceInMeters / 1000;  // Convert meters to kilometers

    return totalDistanceInKilometers.toStringAsFixed(2) + " km";  // Format the result to 2 decimal places
  }

  String _getTotalDurationUpToIndex(int index) {
    // Summing all duration values from 0 to the current index in seconds
    int totalDurationInSeconds = mapRoute.appointments
        .take(index + 1)  // Only take elements up to the current index (inclusive)
        .map((appointment) => appointment.durationValue)  // Extract the durationValue from each appointment
        .fold(0, (prev, element) => prev + element);  // Sum up the durations

    // Convert seconds into hours and minutes
    int hours = totalDurationInSeconds ~/ 3600;  // Get the number of full hours
    int minutes = (totalDurationInSeconds % 3600) ~/ 60;  // Get the remaining minutes after hours

    // Return formatted time (e.g., "1h 15m" or "45m")
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Route',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Bold text
            color: Colors.white, // White text color
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 94, 189, 149),
        elevation: 0,
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
            onTap: (argument) {
              try {
                // Find the marker with MarkerId 'selected'
                Marker marker = _markers.firstWhere(
                  (element) => element.markerId == const MarkerId("selected"),
                );

                // Remove the marker if found
                _markers.remove(marker);
              } catch (e) {
                // Handle the case where no marker is found
                print("Marker with ID 'selected' not found");
              }
            },
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
          (mapRoute.instructions.isEmpty || !journeyStarted) ? 
          const SizedBox.shrink() :
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Card(
              margin: const EdgeInsets.all(0),
              shape: Border.all(width: 0),
              color: const Color.fromARGB(255, 246, 253, 250),
              child: 
                    (mapRoute.instructions.isNotEmpty && _currentInstructionIndex < mapRoute.instructions.length && journeyStarted) ?
              Column(
                children: [
                  Text(
                      mapRoute.instructions[_currentInstructionIndex].instruction.replaceAll(RegExp(r'<[^>]*>'), '')
                    ,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text('Next turn in ${mapRoute.instructions[_currentInstructionIndex].distance}'),
                ],
              ) : const SizedBox.shrink(),
            ),
          ),
          !journeyStarted ? 
          DraggableScrollableSheet(
            maxChildSize: 0.8, 
            minChildSize: 0.3, 
            initialChildSize: 0.5, 
            expand: true,  // Expands to fill available space
            builder: (BuildContext context, ScrollController scrollController) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return Container(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            "Appointments",
                            style: TextStyle(fontSize: 25, ),
                          ),
                        ),
                        Expanded(  // Ensure ListView takes available space within the column
                          child: mapRoute.appointments.isNotEmpty ? ListView.builder(
                            controller: scrollController,  // Use the provided scrollController
                            itemCount: mapRoute.appointments.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.location_pin),
                                            Expanded(
                                              child: Text(
                                                mapRoute.appointments[index].address,
                                                style: const TextStyle(
                                                  overflow: TextOverflow.ellipsis
                                                ),
                                              )
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text("Distance: ${_getTotalDistanceUpToIndex(index)}"), // add all distance values up to index
                                            ),
                                            Expanded(
                                              child: Text("ETA: ${_getTotalDurationUpToIndex(index)}"), // add all distance values up to index
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ),
                                onTap: () => _showLocationOnMap(mapRoute.appointments[index], scrollController),
                              );
                            },
                          )
                            :
                          const Center(child: Text("No Appointments for today!"),)
                        ),
                        if (!journeyStarted && mapRoute.appointments.isNotEmpty) 
                          Padding(
                            padding: const EdgeInsets.all(10),  // Add some spacing around the button
                            child: TextButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll( 
                                  Color.fromARGB(255, 94, 189, 149),
                                ),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                                minimumSize: WidgetStatePropertyAll(Size(800, 50))
                              ),
                              onPressed: () {
                                _startJourney();  // Start journey when camera is centered
                              },
                              child: const Text(
                                'Start Journey',
                                style: TextStyle(
                                  color: Colors.white
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
          )
          :const SizedBox.shrink(),
          isLoading ? const Align(
            child: Card(
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: CircularProgressIndicator(
                  backgroundColor: Color.fromARGB(255, 94, 189, 149),
                ),
              )
            )
          ) : const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: routeReady ? 
          (isCentered ? 
          null
          : 
            ElevatedButton(
              onPressed: () {
                _startJourney(speak: false);
              },
              child: const Text('Recenter'),
            )
          )
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}

class BottomBounceScrollPhysics extends BouncingScrollPhysics {
  BottomBounceScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  BottomBounceScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return BottomBounceScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Only allow the bounce when scrolling downwards (towards the bottom)
    if (value > position.pixels && position.pixels >= position.maxScrollExtent) {
      return value - position.pixels; // Bounce at the bottom
    }
    return 0.0; // Prevent bouncing at the top
  }
}


