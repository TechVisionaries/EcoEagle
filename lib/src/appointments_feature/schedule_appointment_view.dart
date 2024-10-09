
import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/appointment_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleAppointmentView extends StatefulWidget {
  final ApiService apiService;
  const ScheduleAppointmentView({super.key, required this.apiService});

  static const routeName = Constants.appointmentsRoute;

  @override
  _ScheduleAppointmentViewState createState() =>
      _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  bool _isLoading = false;
  bool _isMapLoading = true; // Flag for map loading state
  LatLng _selectedLocation = const LatLng(0, 0); // Default to a neutral location
  late GoogleMapController _mapController;
  DateTime _selectedDate = DateTime.now();
  // List to hold selected garbage types but this cannot be  null
  final List<String> _selectedGarbageTypes = [];
  // List of available garbage types
  final List<String> _garbageTypes = ['Plastic', 'Paper', 'Organic', 'Metal', 'Glass'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissions();
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showPermissionError('Location permissions are denied.');
        return;
      }
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showPermissionError('Location services are disabled.');
      return;
    }

    await _getUserLocation();
  }

  void _showPermissionError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    Navigator.pushNamed(context, '/options');
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
        _isMapLoading = false; // Stop map loading spinner
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isMapLoading = false; // Stop map loading spinner even if error
      });
    }
  }

  Future<void> _selectDate(DateTime selectedDate) async {
    setState(() {
      _selectedDate = selectedDate;
      _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    });
  }

  Future<void> _submitAppointment() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final userId = await widget.apiService.getUserId();
      String? town;

      try {
        // Fetch the town name from coordinates
        town = await widget.apiService.getTownFromCoordinates(_selectedLocation.latitude, _selectedLocation.longitude);
        // Print the fetched town name in the terminal
        print('Fetched City/Town: $town');
        if (town == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to determine town from coordinates'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Fetch the user ID based on the town name
        final driverID = await widget.apiService.fetchDriverIDByCity(town);
        print('Fetched Driver ID: $driverID');





        final appointment = Appointment(
          userId: userId,
          date: _dateController.text,
          status: 'pending',
          location: _selectedLocation,
          driver: driverID,
          garbageTypes: _selectedGarbageTypes,

        );



        final hasAppointment =
        await widget.apiService.hasAppointment(appointment.date);

        if (hasAppointment) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already scheduled an appointment for this date'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        await widget.apiService.createAppointment(appointment);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment Scheduled Successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to appointment list or confirmation screen after success
        Navigator.pushNamed(context, '/my_appointments');

        _formKey.currentState?.reset();
        _dateController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to Schedule Appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('Schedule Appointment'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TableCalendar(
              focusedDay: _selectedDate.isAfter(DateTime.now())
                  ? _selectedDate
                  : DateTime.now().add(const Duration(days: 1)), // Ensure focusedDay is a future date
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                _selectDate(selectedDay);
              },
              firstDay: DateTime.now().add(const Duration(days: 1)), // Start from tomorrow
              lastDay: DateTime.now().add(const Duration(days: 365)), // Allows selection up to one year in the future
              enabledDayPredicate: (day) {
                // Only allow future dates
                return day.isAfter(DateTime.now());
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
              ),
            ),

            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Schedule Date',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () {
                        // You can trigger the calendar view here if needed
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the date';
                    }
                    return null;
                  },
                ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Garbage Types',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0), // Spacing
                  ..._garbageTypes.map((type) {
                    return CheckboxListTile(
                      title: Text(
                        type,
                        style: const TextStyle(fontSize: 16.0, color: Colors.black),
                      ),
                      value: _selectedGarbageTypes.contains(type), // Check if the type is selected
                      onChanged: (bool? isChecked) {
                        setState(() {
                          if (isChecked == true) {
                            _selectedGarbageTypes.add(type); // Add to selected if checked
                          } else {
                            _selectedGarbageTypes.remove(type); // Remove from selected if unchecked
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading, // Position the checkbox to the left
                    );
                  }).toList(),


                const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation,
                            zoom: 14.0,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                            _getUserLocation();
                          },
                          markers: {
                            Marker(
                              markerId: const MarkerId('userLocation'),
                              position: _selectedLocation,
                            ),
                          },
                        ),
                        if (_isMapLoading)
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: (_isLoading || _isMapLoading) ? null : _submitAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 94, 189, 149),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Submit Appointment'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
