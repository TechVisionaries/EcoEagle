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

  final ApiService apiService;

  const AppointmentReportPage({Key? key, required this.apiService}) : super(key: key);

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

  Future<void> _deleteAppointment(String id) async {
    try {
      await apiService.deleteAppointment(id);
      setState(() {
        appointments.removeWhere((appointment) => appointment.id == id);
        filteredAppointments = appointments;
      });
    } catch (e) {
      print('Error deleting appointment: $e');
    }
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
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around the entire body
          child: Card(
            elevation: 4, // Adds shadow to the card for depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: Color(0xFF41A87D)), // Icon for the filter
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        'Filter by Status',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 12), // Space between title and radio buttons
                  Center(
                    child: SingleChildScrollView( // Added SingleChildScrollView to make the row scrollable
                      scrollDirection: Axis.horizontal, // Scroll horizontally
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Align buttons at the start
                        children: ['All', 'Pending', 'Accepted', 'Completed'].map((status) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStatus = status;
                                _filterAppointments(selectedStatus);
                              });
                            },
                            child: Row(
                              children: [
                                Radio<String>(
                                  value: status,
                                  groupValue: selectedStatus,
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedStatus = newValue ?? 'All';
                                      _filterAppointments(selectedStatus);
                                    });
                                  },
                                  activeColor: Color(0xFF41A87D),
                                ),
                                Text(status),
                                SizedBox(width: 16), // Add spacing between radio buttons
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),


                  SizedBox(height: 16), // Space before data table

                  // Use Flexible with a scrollable DataTable for responsiveness
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Location', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: filteredAppointments
                            .map(
                              (appointment) => DataRow(cells: [
                            DataCell(Text(appointment.date)),
                            DataCell(Text(appointment.status.capitalize())),
                            DataCell(FutureBuilder<String?>(
                              future: apiService.getTownFromCoordinates(
                                appointment.location.latitude,
                                appointment.location.longitude,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Text('Loading...'); // While loading
                                } else if (snapshot.hasError || !snapshot.hasData) {
                                  return Text('N/A'); // Error case
                                } else {
                                  return Text(snapshot.data ?? 'Unknown');
                                }
                              },
                            )),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red), // Delete icon
                                onPressed: () {
                                  _deleteAppointment(appointment.id!);
                                },
                              ),
                            ),
                          ]),
                        )
                            .toList(),
                      ),
                    ),
                  ),


                  // Generate PDF button
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: const Color(0xFF41A87D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: isButtonLoading ? null : _generatePDF, // Disable button if loading
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Make the button fit its content
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
                            style: TextStyle(fontSize: 16), // Adjust font size if needed
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      townNames.add(town ?? 'Unknown');
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
