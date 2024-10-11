import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/components/custom_bottom_navigation.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/appointment_service.dart';
import 'package:trashtrek/src/notification_feature/notification_service.dart';

import '../notification_feature/notification_model.dart';

class DriverMyAppointmentsView extends StatefulWidget {
  static const routeName = Constants.driverAppointmentRoute;

  final ApiService apiService;
  final NotificationService notificationService;

  const DriverMyAppointmentsView({super.key, required this.apiService, required this.notificationService});

  @override
  _DriverMyAppointmentsViewState createState() => _DriverMyAppointmentsViewState();
}

class _DriverMyAppointmentsViewState extends State<DriverMyAppointmentsView> {
  late Future<List<Appointment>> _appointmentsFuture;
  bool _isLoading = false;
  int? _loadingIndex;
  DateTime? _selectedDate; // To store the selected date
  

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Appointment>> _loadAppointments() async {
    final driverId = await widget.apiService.getUserId();
    if (driverId != null) {
      return widget.apiService.fetchMyDriverAppointments(driverId);
    } else {
      return Future.error('User ID not found');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelAppointment(int index, String appointmentId,String userId) async {
    setState(() {
      _isLoading = true;
      _loadingIndex = index;
    });
    try {
      await widget.apiService.cancelAppointment(appointmentId);
      // Notify user about cancellation
      await widget.notificationService.notify(
        PushNotification(
          targetUserId: userId,
          notificationTitle: 'Appointment Cancelled',
          notificationBody: 'Your appointment has been cancelled.',
        ),
      );
      setState(() {
        _appointmentsFuture = _loadAppointments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _loadingIndex = null;
      });
    }
  }

  Future<void> _acceptAppointment(int index, String appointmentId,String userId) async {
    setState(() {
      _isLoading = true;
      _loadingIndex = index;
    });
    try {
      await widget.apiService.acceptAppointment(appointmentId);
      // Notify user about acceptance
      await widget.notificationService.notify(
        PushNotification(
          targetUserId: userId,
          notificationTitle: 'Appointment Accepted',
          notificationBody: 'Your appointment has been accepted.',
        ),
      );
      setState(() {
        _appointmentsFuture = _loadAppointments();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _loadingIndex = null;
      });
    }
  }

  List<Appointment> _filterAppointmentsByStatusAndDate(List<Appointment> appointments, String status, DateTime? date) {
    return appointments.where((appointment) {
      bool matchesStatus = appointment.status == status;
      bool matchesDate = date == null || DateTime.parse(appointment.date).isAtSameMomentAs(date);
      return matchesStatus && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar(
        'My Appointments',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                Constants.driverAppointmentRoute,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Date picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? 'Selected Date: ${_selectedDate!.toLocal()}'.split(' ')[0]
                      : 'Select a date',
                  style: const TextStyle(fontSize: 16),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
          ),
          // Appointments list
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load appointments: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _appointmentsFuture = _loadAppointments();
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No appointments found', style: TextStyle(color: Colors.grey)),
                  );
                } else {
                  final appointments = snapshot.data!;
                  return _buildAppointmentList(
                    _filterAppointmentsByStatusAndDate(appointments, 'pending', _selectedDate),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation.dynamicNav(context, 3, 'Driver'),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(
        child: Text('No pending appointments', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Appointment on',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            appointment.date,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        appointment.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Display the garbage types
                const Text(
                  'Garbage Types:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8.0,
                  children: appointment.garbageTypes.map((type) {
                    return Chip(
                      label: Text(type),
                      backgroundColor: Colors.lightGreen[100],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),
                if (appointment.status == 'pending')
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel, color: Colors.white),
                          label: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red background for cancel button
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                            ),
                          ),
                          onPressed: () {
                            _showCancelConfirmationDialog(index, appointment.id ?? '',appointment.userId??'');
                          },
                        ),
                      ),
                      const SizedBox(width: 10), // Add some spacing between buttons

                      // Accept button
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle, color: Colors.white),
                          label: const Text(
                            'Accept',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Green background for accept button
                            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // Rounded corners
                            ),
                          ),
                          onPressed: () {
                            _acceptAppointment(index, appointment.id ?? '',appointment.userId??'');
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmationDialog(int index, String appointmentId, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                _cancelAppointment(index, appointmentId, userId);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
