import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trashtrek/common/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class UserReport extends StatefulWidget {
  const UserReport({super.key});

  static const routeName = Constants.userReportRoute;

  @override
  _UserReportState createState() => _UserReportState();
}

class _UserReportState extends State<UserReport> {
  List<dynamic> _users = [];
  List<dynamic> _filteredUsers = [];
  bool _isLoading = true;
  String? _selectedCity;
  String? _selectedUserType = "Both"; // Default user type to "Both"

  final List<String> _cities = [
    "Ampara",
    "Anuradhapura",
    "Badulla",
    "Batticaloa",
    "Colombo",
    "Galle",
    "Gampaha",
    "Hambantota",
    "Jaffna",
    "Kalutara",
    "Kandy",
    "Kegalle",
    "Kilinochchi",
    "Kurunegala",
    "Mannar",
    "Matale",
    "Matara",
    "Moneragala",
    "Mullativu",
    "Nuwara Eliya",
    "Polonnaruwa",
    "Puttalam",
    "Ratnapura",
    "Trincomalee",
    "Vavuniya"
  ];

  Future<void> _fetchUserReports() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = dotenv.env[Constants.baseURL]; // Get the base URL
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/all-users'),
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _users = jsonDecode(response.body);
        _filteredUsers = _users; // Initialize filtered list to show all users
        _isLoading = false;
      });
    } else {
      // Handle error
      setState(() {
        _isLoading = false;
      });
      print('Failed to load user reports');
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesCity = _selectedCity == null ||
            _selectedCity == 'All' ||
            user['address']['city'] == _selectedCity;
        final matchesUserType = _selectedUserType == 'Both' ||
            user['userType'] == _selectedUserType;
        return matchesCity && matchesUserType;
      }).toList();
    });
  }

  Future<void> _generatePdfReport() async {
    final pdf = pw.Document();

    // Load the company logo from assets
    final ByteData bytes = await rootBundle.load('assets/images/truck.png');
    final image = pw.MemoryImage(bytes.buffer.asUint8List());

    // Get the current date and time
    final DateTime now = DateTime.now();
    final formattedDate = "${now.year}-${now.month}-${now.day}";
    final formattedTime = "${now.hour}:${now.minute}:${now.second}";

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header Section
              pw.Container(
                color: PdfColor.fromHex('#bfff00'), // Light green color
                padding: const pw.EdgeInsets.all(16),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'TrashTrek\n Company',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    // Logo and "Users Report" in a centered column
                    pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(image, width: 60, height: 60), // Logo Image
                        pw.SizedBox(
                            height: 8), // Space between the logo and the text
                        pw.Text(
                          'Users Report',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            decoration: pw.TextDecoration
                                .underline, // Underline added here
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                    pw.Text(
                      'Date: $formattedDate\nTime: $formattedTime',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ],
                ),
              ),
              pw.Divider(
                  color: PdfColors.white,
                  thickness: 10), // Add some space after the header

              // Table Section
              pw.Container(
                color: PdfColor.fromHex('#ffffff'),
                child: pw.Table.fromTextArray(
                  context: context,
                  headers: ['Name', 'Email', 'Phone', 'User Type'],
                  data: _filteredUsers.map((user) {
                    return [
                      '${user['firstName']} ${user['lastName']}',
                      user['email'],
                      user['phoneNo'] ?? 'N/A',
                      user['userType'] ?? 'N/A'
                    ];
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save to Downloads directory
    final outputDir =
        await getExternalStorageDirectory(); // Get external directory (Downloads)
    final downloadsDir = Directory("${outputDir!.path}/Download");
    if (!await downloadsDir.exists()) {
      await downloadsDir.create();
    }
    final file = File('${downloadsDir.path}/user_report.pdf');
    await file.writeAsBytes(await pdf.save());
    print("PDF saved to: ${file.path}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF Report Generated: ${file.path}')),
    );
  }

  Future<void> _removeAccount(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final baseUrl =
        dotenv.env[Constants.baseURL]; // Get the base URL from the .env file

    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Account Removed'),
            content: const Text('The account has been removed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushReplacementNamed(
                      Constants.userReportRoute); // Navigate to login page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle error
      print('Failed to remove account');
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Account Removal Failed'),
            content:
                const Text('An error occurred while removing the account.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showRemoveAccountDialog(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Account Removal'),
          content:
              const Text('You are about to remove this account. Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _removeAccount(userId); // Pass userId to _removeAccount method
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Red color for the button
              ),
              child: const Text('Remove Account'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 65, 168, 125),
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 133, 224, 125),
                    Color.fromARGB(255, 187, 251, 201),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        _buildFilterOptions(),
                        Expanded(child: _buildUserTable()),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _generatePdfReport,
                          child: const Text('Generate PDF Report'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFilterOptions() {
    return Column(
      children: [
        // City Filter
        DropdownButton<String>(
          value: _selectedCity,
          hint: const Text('Select City'),
          items: ['All', ..._cities].map((city) {
            return DropdownMenuItem(
              value: city,
              child: Text(city),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedCity = newValue;
            });
            _filterUsers();
          },
        ),
        const SizedBox(height: 10),
        // User Type Filter
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
              value: 'Resident',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value.toString();
                });
                _filterUsers();
              },
            ),
            const Text('Resident'),
            const SizedBox(width: 20),
            Radio(
              value: 'Driver',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value.toString();
                });
                _filterUsers();
              },
            ),
            const Text('Driver'),
            const SizedBox(width: 20),
            Radio(
              value: 'Both',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value.toString();
                });
                _filterUsers();
              },
            ),
            const Text('Both'),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('User Type')),
          DataColumn(label: Text('Actions')), // Add "Actions" column
        ],
        rows: _filteredUsers.map((user) {
          return DataRow(
            cells: [
              DataCell(Text('${user['firstName']} ${user['lastName']}')),
              DataCell(Text(user['email'])),
              DataCell(Text(user['phoneNo'] ?? 'N/A')),
              DataCell(Text(user['userType'] ?? 'N/A')),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showRemoveAccountDialog(user['_id']); // Pass user ID
                  },
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
