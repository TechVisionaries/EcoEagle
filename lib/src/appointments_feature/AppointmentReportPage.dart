import 'package:flutter/material.dart';
import '../../common/constants.dart';
import 'appointment_model.dart';
import 'appointment_service.dart';

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

extension StringCasingExtension on String {
  String capitalize() {
    if (this.isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${this.substring(1).toLowerCase()}';
  }
}

class AppointmentReportPage extends StatefulWidget {
  const AppointmentReportPage({Key? key}) : super(key: key);

  static const routeName = Constants.appointmentReportRoute;

  @override
  _AppointmentReportPageState createState() => _AppointmentReportPageState();
}

class _AppointmentReportPageState extends State<AppointmentReportPage> {
  ApiService apiService = ApiService();
  List<Appointment> appointments = [];
  List<Appointment> filteredAppointments = [];
  String selectedStatus = 'All'; // Default is to show all appointments
  bool isLoading = false; // Loading state for the overall UI
  bool isButtonLoading = false; // Loading state for the button

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      isLoading = true; // Start loading
    });
    List<Appointment> fetchedAppointments = await apiService.fetchAllAppointments();
    setState(() {
      appointments = fetchedAppointments;
      filteredAppointments = appointments; // Initially show all
      isLoading = false; // Stop loading
    });
  }

  void _filterAppointments(String status) {
    setState(() {
      if (status == 'All') {
        filteredAppointments = appointments;
      } else {
        filteredAppointments = appointments
            .where((appointment) => appointment.status == status.toLowerCase())
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment Report'),
        backgroundColor: const Color(0xFF41A87D),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Container(
        color: const Color(0xFFEFF5E5), // Light background color
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: ['All', 'Pending', 'Accepted', 'Confirmed']
                    .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedStatus = newValue ?? 'All';
                    _filterAppointments(selectedStatus);
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = filteredAppointments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        title: Text(
                          'Appointment on ${appointment.date}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Text(
                          'Status: ${appointment.status.capitalize()}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF41A87D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isButtonLoading ? null : _generatePDF, // Disable button if loading
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isButtonLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text(
                      'Generate PDF',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _generatePDF() async {
    setState(() {
      isButtonLoading = true; // Start loading while generating PDF
    });

    final pdf = pw.Document();
    List<String> townNames = [];

    // Fetch town names asynchronously for each appointment
    for (var appointment in filteredAppointments) {
      String? town = await apiService.getTownFromCoordinates(
        appointment.location.latitude,
        appointment.location.longitude,
      );
      townNames.add(town!);
    }

    // Add PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Appointment Report', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Date', 'Status', 'Location'],
                  ...filteredAppointments.map(
                        (appointment) => [
                      appointment.date,
                      appointment.status.capitalize(),
                      townNames[filteredAppointments.indexOf(appointment)],
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/appointment_report.pdf");
    await file.writeAsBytes(await pdf.save());

    // Optionally, open the PDF in a viewer
    await Printing.sharePdf(bytes: await pdf.save(), filename: 'appointment_report.pdf');

    setState(() {
      isButtonLoading = false; // Stop loading after PDF generation
    });
  }
}
