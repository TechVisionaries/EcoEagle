import 'package:flutter/material.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/src/appointments_feature/appointment_model.dart';
import 'package:trashtrek/src/appointments_feature/appointment_service.dart';
import 'package:trashtrek/src/waste_map_feature/waste_map_resident_view.dart';

class MyAppointmentsView extends StatefulWidget {
  static const routeName = Constants.myAppointmentsRoute;

  final ApiService apiService;

  const MyAppointmentsView({super.key, required this.apiService});

  @override
  _MyAppointmentsViewState createState() => _MyAppointmentsViewState();
}

class _MyAppointmentsViewState extends State<MyAppointmentsView>
    with SingleTickerProviderStateMixin {
  late Future<List<Appointment>> _appointmentsFuture;
  late TabController _tabController;
  bool _isLoading = false;
  int? _loadingIndex;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _loadAppointments();
    _tabController = TabController(length: 3, vsync: this); // Updated length to 3 for the new tab
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
      case 'accepted':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _cancelAppointment(int index, String appointmentId) async {
    setState(() {
      _isLoading = true;
      _loadingIndex = index;
    });
    try {
      await widget.apiService.cancelAppointment(appointmentId);
      setState(() {
        // Reload appointments after cancellation
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

  List<Appointment> _filterAppointmentsByStatus(
      List<Appointment> appointments, String status) {
    return appointments
        .where((appointment) => appointment.status == status)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color.fromARGB(255, 94, 189, 149),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false, // Changed to false to distribute tabs evenly
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Completed'),
          ],
          labelPadding: const EdgeInsets.symmetric(horizontal: 24.0), // Adjust if needed
        ),
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Failed to load appointments: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
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
                ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No appointments found',
                    style: TextStyle(color: Colors.grey)));
          } else {
            final appointments = snapshot.data!;
            return TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(
                    _filterAppointmentsByStatus(appointments, 'pending')),
                _buildAppointmentList(
                    _filterAppointmentsByStatus(appointments, 'accepted')),
                _buildAppointmentList(
                    _filterAppointmentsByStatus(appointments, 'completed')),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildAppointmentList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(
          child: Text('No appointments in this category',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final currentDate = DateTime.now();
        final appointmentDate = DateTime.parse(appointment.date);
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
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 12),
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
                // Show "View Route" button if appointment is accepted and date matches current date
                if (appointment.status == 'accepted' &&
                    appointmentDate.year == currentDate.year &&
                    appointmentDate.month == currentDate.month &&
                    appointmentDate.day == currentDate.day)
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WasteMapResidentView(appointmentId: appointment.id ?? "", driverId: appointment.driver ?? '',),
                          ),
                        );
                      },
                      child: const Text(
                        'View Route',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                if (appointment.status == 'pending')
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _isLoading && _loadingIndex == index
                        ? const CircularProgressIndicator()
                        : TextButton(
                      onPressed: () {
                        _showCancelConfirmationDialog(
                            index, appointment.id ?? '');
                      },
                      child: const Text(
                        'Cancel Appointment',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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

  void _showCancelConfirmationDialog(int index, String appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text("Once you cancel the appointment, you cannot reschedule it for the same date. Are you sure you want to cancel the appointment?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.green,
              backgroundColor: Colors.white,
            ),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _cancelAppointment(index, appointmentId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
