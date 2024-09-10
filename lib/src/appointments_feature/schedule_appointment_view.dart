import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/schedule_appointment_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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
  final _houseNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  String _status = 'pending';
  bool _isLoading = false;
  LatLng _selectedLocation = LatLng(0, 0);

  late GoogleMapController _mapController;

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
    _houseNoController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushNamed(context, '/options');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied. Please enable them in settings.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushNamed(context, '/options');
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location services are disabled. Please enable them in settings.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      Navigator.pushNamed(context, '/options');
      return;
    }

    await _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Notify user and prompt them to enable location services
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Location services are disabled. Please enable them in settings.'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.animateCamera(CameraUpdate.newLatLng(_selectedLocation));
      });
    } catch (e) {
      // Handle other exceptions such as permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      setState(() {
        _dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
      });
    }
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
        status: _status,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      try {
        final hasAppointment =
            await widget.apiService.hasAppointment(appointment.date);

        if (hasAppointment) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You have already scheduled an appointment for this date'),
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
            Image.asset(
              'assets/images/appointments.webp',
              height: 200,
              fit: BoxFit.cover,
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
                        onPressed: _selectDate,
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
                    child: GoogleMap(
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
                          markerId: MarkerId('userLocation'),
                          position: _selectedLocation,
                        ),
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitAppointment,
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
