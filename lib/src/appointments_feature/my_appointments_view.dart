import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/schedule_appointment_service.dart';

class MyAppointmentsView extends StatefulWidget {
  static const routeName = Constants.myAppointmentsRoute;

  final ApiService apiService;

  const MyAppointmentsView({Key? key, required this.apiService})
      : super(key: key);

  @override
  _MyAppointmentsViewState createState() => _MyAppointmentsViewState();
}

class _MyAppointmentsViewState extends State<MyAppointmentsView>
    with SingleTickerProviderStateMixin {
  late Future<List<Appointment>> _appointmentsFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<List<Appointment>> _loadAppointments() async {
    final userId = await widget.apiService.getUserId();
    if (userId != null) {
      return widget.apiService.fetchAppointments(userId);
    } else {
      return Future.error('User ID not found');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.greenAccent;
      case 'cancelled':
        return Colors.redAccent;
      case 'rejected':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  void _cancelAppointment(int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('No', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Yes', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final appointments = await _appointmentsFuture;
      final appointment = appointments[index];

      if (appointment.id != null) {
        try {
          await widget.apiService.cancelAppointment(appointment.id!);

          setState(() {
            appointments[index].status = 'cancelled';
            _appointmentsFuture = Future.value(appointments);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment cancelled successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel the appointment: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment ID is missing.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Pending'),
            Tab(text: 'Cancelled'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load appointments: ${snapshot.error}',
                    style: TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text('No appointments found',
                    style: TextStyle(color: Colors.grey)));
          } else {
            final appointments = snapshot.data!;
            final pendingAppointments =
                appointments.where((a) => a.status == 'pending').toList();
            final cancelledAppointments =
                appointments.where((a) => a.status == 'cancelled').toList();
            final rejectedAppointments =
                appointments.where((a) => a.status == 'rejected').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(pendingAppointments),
                _buildAppointmentList(cancelledAppointments),
                _buildAppointmentList(rejectedAppointments),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(child: Text('No appointments found'));
    } else {
      return ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];

          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appointment on ${appointment.date}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        if (appointment.address.isNotEmpty) ...[
                          Text(
                            'Address:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            appointment.address.entries
                                .map((entry) => '${entry.value}')
                                .join(', '),
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ] else
                          Text(
                            'Address: Not Available',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        SizedBox(height: 16),
                        if (appointment.status == 'pending')
                          TextButton(
                            onPressed: () => _cancelAppointment(index),
                            child: Text(
                              'Cancel Appointment',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.status.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
