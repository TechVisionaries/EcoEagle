import 'package:flutter/material.dart';

class Appointment {
  final String date;
  final String houseNo;
  final String street;
  final String city;
  String status; // Mutable to update the status

  Appointment({
    required this.date,
    required this.houseNo,
    required this.street,
    required this.city,
    required this.status,
  });
}

class MyAppointmentsView extends StatefulWidget {
  static const routeName = '/my_appointments';

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<MyAppointmentsView> {
  final List<Appointment> appointments = [
    Appointment(
        date: "2024-09-01",
        houseNo: "123",
        street: "Main St",
        city: "Colombo",
        status: "Pending"),
    Appointment(
        date: "2024-09-02",
        houseNo: "456",
        street: "Second St",
        city: "Kandy",
        status: "Completed"),
    Appointment(
        date: "2024-09-03",
        houseNo: "789",
        street: "Third St",
        city: "Galle",
        status: "Cancelled"),
    Appointment(
        date: "2024-09-04",
        houseNo: "101",
        street: "Fourth St",
        city: "Matara",
        status: "Rejected"), // New Rejected status
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Rejected':
        return Colors.purple; // Different color for Rejected status
      default:
        return Colors.grey;
    }
  }

  void _cancelAppointment(int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Appointment'),
          content: Text('Are you sure you want to cancel this appointment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        appointments[index].status = 'Cancelled';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment cancelled successfully.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
      ),
      body: ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text('Appointment on ${appointment.date}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Address: ${appointment.houseNo}, ${appointment.street}, ${appointment.city}'),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      appointment.status,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (appointment.status == 'Pending')
                    TextButton(
                      onPressed: () => _cancelAppointment(index),
                      child: Text(
                        'Cancel Appointment',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to detailed view if needed
              },
            ),
          );
        },
      ),
    );
  }
}
