import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:trashtrek/common/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

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
    "Athurugiriya",
    "Badulla",
    "Bentota",
    "Colombo",
    "Galle",
    "Gampaha",
    "Jaffna",
    "Kalmunai",
    "Kalutara",
    "Kandy",
    "Kesbewa",
    "Kolonnawa",
    "Kurunegala",
    "Maharagama",
    "Mannar",
    "Matara",
    "Moratuwa",
    "Mount Lavinia",
    "Negombo",
    "Puttalam",
    "Ratnapura",
    "Sri Jayewardenepura Kotte",
    "Trincomalee",
    "Weligama"
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
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Table.fromTextArray(
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF Report Generated: ${file.path}')),
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
                  _selectedUserType = value;
                });
                _filterUsers();
              },
            ),
            const Text('Resident'),
            Radio(
              value: 'Driver',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value;
                });
                _filterUsers();
              },
            ),
            const Text('Driver'),
            Radio(
              value: 'Both',
              groupValue: _selectedUserType,
              onChanged: (value) {
                setState(() {
                  _selectedUserType = value;
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
        ],
        rows: _filteredUsers.map((user) {
          return DataRow(cells: [
            DataCell(Text('${user['firstName']} ${user['lastName']}')),
            DataCell(Text(user['email'])),
            DataCell(Text(user['phoneNo'] ?? 'N/A')),
            DataCell(Text(user['userType'] ?? 'N/A')),
          ]);
        }).toList(),
      ),
    );
  }
}
