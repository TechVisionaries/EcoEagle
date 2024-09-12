import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/schedule_appointment_service.dart';
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
  LatLng _selectedLocation = LatLng(0, 0); // Default to a neutral location
  late GoogleMapController _mapController;
  List<DateTime> _availableDates = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateAvailableDates();
      _checkPermissions();
    });
  }

  void _generateAvailableDates() {
    final now = DateTime.now();
    final startDate = now.add(Duration(days: 1)); // Start from the day after the current date
    final endDate = startDate.add(Duration(days: 7)); // End one week from startDate

    setState(() {
      _availableDates = [];

      DateTime current = startDate;

      // Loop through the week and add dates only if they are Sunday or Wednesday
      while (current.isBefore(endDate)) {
        if (current.weekday == DateTime.sunday || current.weekday == DateTime.wednesday) {
          _availableDates.add(current);
        }
        current = current.add(Duration(days: 1)); // Move to the next day
      }

      // Ensure we have exactly 3 dates
      if (_availableDates.length > 3) {
        _availableDates = _availableDates.take(3).toList();
      }

      print('Generated Dates: $_availableDates'); // Debugging
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
      final appointment = Appointment(
        userId: userId,
        date: _dateController.text,
        status: 'pending',
        location: Location(
          latitude: _selectedLocation.latitude,
          longitude: _selectedLocation.longitude,
        ),
      );

      try {
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
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color.fromARGB(255, 94, 189, 149),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TableCalendar(
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                _selectDate(selectedDay);
              },
              firstDay: DateTime.now().subtract(Duration(days: 365)),
              lastDay: DateTime.now().add(Duration(days: 365)),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
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
