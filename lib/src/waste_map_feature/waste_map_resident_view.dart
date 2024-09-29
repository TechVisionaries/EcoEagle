
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/common/strings.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/reward_management/add_rating_view.dart';
import 'package:trashtrek/src/waste_map_feature/route_model.dart';
import 'package:http/http.dart' as http;

class WasteMapResidentView extends StatefulWidget {
  final String appointmentId;
  final String driverId;
  const WasteMapResidentView({
    super.key,
    required this.appointmentId,
    required this.driverId,
  });

  @override
  WasteMapDriverViewState createState() => WasteMapDriverViewState();
}

class WasteMapDriverViewState extends State<WasteMapResidentView> {
  List<LatLng> _routePoints = [];
  StreamSubscription<LatLng>? _driverLocationSubscription;
  GoogleMapController? _mapController;
  String? apiKey = dotenv.env[Constants.googleApiKey];
  Marker? _driverMarker;
  Marker? _appointmentMarker;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  MapRoute? _mapRoute;
  late LatLng _appointmentLocation;
  late LatLng _driverLocation;
  bool _isLoading = false;
  bool _isOpen = false;
  bool _isLoading2 = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startDriverLocationStream();
  }

  @override
  void dispose() {
    super.dispose();
    _driverLocationSubscription?.cancel();
    _mapController?.dispose();
  }

  // Function to update the marker when the driver's location changes
  void _updateDriverLocation(LatLng newPosition) {
    try {
    Marker tempDriver;
    Marker tempAppointment;
    MapAppointment tempApt;
    if (_driverMarker == null) {
      // Add the marker for the first time
      tempDriver = Marker(
        markerId: const MarkerId('driver_marker'),
        position: newPosition,
      );
    } else {
      // Update the marker position
      tempDriver = _driverMarker!.copyWith(positionParam: newPosition);
    }

    if(_mapRoute != null && _mapRoute!.appointments.isNotEmpty){
      tempApt = _mapRoute!.appointments.firstWhere((appt) => appt.id == widget.appointmentId);
      if(tempApt.status == "completed" && !_isOpen){
        _isOpen = true;
        _driverLocationSubscription?.cancel();
        _appointmentCompleteDialog(tempApt.driver);
      }
      if (_appointmentMarker == null) {
        // Add the marker for the first time
        tempAppointment = Marker(
          markerId: const MarkerId('appointment'),
          position: tempApt.location,
        );
      }else {
        // Update the marker position
        tempAppointment = _appointmentMarker!;
      }

      setState(() {
        _driverMarker = tempDriver;
        _appointmentMarker = tempAppointment;
        _appointmentLocation = tempApt.location;
        _driverLocation = newPosition;
        if(!_isLoading){
          _loadRoute();
        }
      });
    }

    // Move the map camera to the new driver location
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    } catch (e) {
      print(e);
    }
  }

  String getDirectionsUrl(LatLng origin, List<LatLng> waypoints, LatLng destination) {
    final waypointsString = waypoints.map((e) => '${e.latitude},${e.longitude}').join('|');
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&waypoints=optimize:true|$waypointsString&key=$apiKey';
    return url;
  }

  Future<List<LatLng>> fetchRoute(LatLng origin, List<LatLng> waypoints, LatLng destination) async {
    final url = getDirectionsUrl(origin, waypoints, destination);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // final route = data['routes'][0]['overview_polyline']['points'];

      final route = data['routes'][0];
      
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

  void _loadRoute() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<List<LatLng>> chunks = [];
      List<LatLng> totalSnapPoints = [];
      List<LatLng> locs = [];

      for(var loc in _mapRoute!.locations){
        if(loc == _appointmentLocation){
          break;
        }
        locs.add(loc);
      }

      final routePoints = await fetchRoute(
        _driverLocation,
        locs,
        _appointmentLocation
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
          _isLoading = false;
          _isLoading2 = false;
      });

      // _mapController?.animateCamera(
      //   CameraUpdate.newLatLngBounds(
      //     LatLngBounds(
      //       southwest: LatLng(
      //         _routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
      //         _routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
      //       ),
      //       northeast: LatLng(
      //         _routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
      //         _routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
      //       ),
      //     ),
      //     50.0,
      //   ),
      // );
    } catch (e) {
      // Handle errors
      print(e);
      if(mounted){
        setState(() {
          _isLoading = false;
          _isLoading2 = false;
        });
      }
    } 
  }
  
  void _startDriverLocationStream() {
    _driverLocationSubscription = _getDriverLocationStream().listen((driverLocation) {
      if (mounted) {
        _updateDriverLocation(driverLocation);
      }
    });
  }

  Stream<LatLng> _getDriverLocationStream() {
    return _firestore.collection('drivers').doc(widget.driverId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data != null && data['driverLocation'] != null) {

        List<LatLng> locs = [];
        List<MapAppointment> appts = [];
        List<Instruction> ins = [];
        for (var location in data['locations']) {
          locs.add(
            LatLng(location['latitude'], location['longitude'])
          );
        }
        for (var appt in data['appointments']){
          appts.add(MapAppointment.fromJson(appt));
        }
        for (var inst in data['instructions']){
          ins.add(Instruction.fromJson(inst));
        }

        if(_mapRoute != null && _mapRoute!.appointments.isNotEmpty){
          _mapRoute!.appointments.firstWhere((appt) => appt.id == widget.appointmentId);
        }
        
        MapRoute mapRoute = MapRoute(driver: data['driver'], locations: locs, appointments: appts, instructions: ins, status: data['status']);
        setState(() {
          _mapRoute = mapRoute;
        });
        GeoPoint location = data['driverLocation'];
        return LatLng(location.latitude, location.longitude);
      }
      return LatLng(0, 0); // Default location if no data is found
    });
  }

  void _appointmentCompleteDialog(String? driverId) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Your garbage has being collected!'),
        content: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(
            Icons.check_circle_outline_rounded,
            size: 150,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              if(!mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                Constants.residentDashboardRoute,
                (route) => false, // Removes all previous routes
              );
            },
            child: const Text('Continue'),
          ),
          ElevatedButton(
            onPressed: () async {
              if(!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => RateDriverScreen(driverId: driverId ?? ""),
                ),
                ModalRoute.withName(Constants.residentDashboardRoute), // This condition ensures that all previous routes are removed
              );
            },
            child: const Text('Rate Driver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('My Appointment'),
      body: StreamBuilder<LatLng>(
        stream: _getDriverLocationStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            LatLng driverLocation = snapshot.data!;

            // Update the map and marker with the new location
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateDriverLocation(driverLocation);
            });

            return Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: driverLocation, // Set the initial camera position
                    zoom: 14,
                  ),
                  markers: {
                    if (_driverMarker != null) _driverMarker!, // Add only if it's not null
                    if (_appointmentMarker != null) _appointmentMarker!, // Add only if it's not null
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
                ),
                _isLoading2 ? const Align(
                  child: Card(
                    elevation: 10,
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: CircularProgressIndicator(
                        backgroundColor: Color.fromARGB(255, 94, 189, 149),
                      ),
                    )
                  )
                ) : const SizedBox.shrink()
              ],
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('No Ongoing Appointments'));
          } else {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromARGB(255, 94, 189, 149),
              ),
            );
          }
        },
      )
    );
  }
}


