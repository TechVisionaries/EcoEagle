import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/schedule_appointment_service.dart';

class ScheduleAppointmentView extends StatefulWidget {
  final ApiService apiService;
  const ScheduleAppointmentView({Key? key, required this.apiService})
      : super(key: key);

  static const routeName = Constants.appointmentsRoute;

  @override
  _ScheduleAppointmentViewState createState() =>
      _ScheduleAppointmentViewState();
}

class _ScheduleAppointmentViewState extends State<ScheduleAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _houseNoController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  String _status = 'pending';

  @override
  void dispose() {
    _dateController.dispose();
    _houseNoController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
      final appointment = Appointment(
        date: _dateController.text,
        address: {
          'houseNo': _houseNoController.text,
          'street': _streetController.text,
          'city': _cityController.text,
        },
        status: _status,
      );

      try {
        await widget.apiService.createAppointment(appointment);
        // Show success message only if the API call is successful
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment Scheduled Successfully'),
          ),
        );
        // Optionally, navigate to another screen or reset form fields
        _formKey.currentState?.reset();
        _dateController.clear();
        _houseNoController.clear();
        _streetController.clear();
        _cityController.clear();
      } catch (e) {
        // Show error message if the API call fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to Schedule Appointment: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Appointment'),
        backgroundColor: Color.fromARGB(255, 94, 189, 149),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image at the top
            Image.asset(
              'assets/images/appointments.webp',
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),
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
                        icon: Icon(Icons.calendar_today),
                        onPressed: _selectDate,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _houseNoController,
                    decoration: InputDecoration(
                      labelText: 'House No',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the house number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _streetController,
                    decoration: InputDecoration(
                      labelText: 'Street',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the street';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the city';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitAppointment,
                    child: Text('Schedule Appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 94, 189, 149),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
