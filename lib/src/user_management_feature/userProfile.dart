import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:trashtrek/components/custom_app_bar.dart';
import 'package:trashtrek/src/settings/settings_view.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _username;
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _phoneNo;
  String? _userType;
  String? _address;
  bool _isLoading = false; // Add this variable to track loading state

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl =
        dotenv.env[Constants.baseURL]; // Get the base URL from the .env file
    _username = prefs.getString('userID');
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/$_username'),
      headers: {
        'authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['user'];
      setState(() {
        _email = data['email'];
        _firstName = data['firstName'];
        _lastName = data['lastName'];
        _phoneNo = data['phoneNo'];
        _userType = data['userType'];
        _address =
            "${data['address']['houseNo']}, ${data['address']['street']}, ${data['address']['city']}";
      });
    } else {
      // Handle error
      print('Failed to load user data');
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = _email;

    final baseUrl =
        dotenv.env[Constants.baseURL]; // Get the base URL from the .env file

    final response = await http.post(
      Uri.parse('$baseUrl/users/logout'),
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response.statusCode == 200) {
      prefs.remove('userID');
      prefs.remove('token');
      prefs.remove('userlogtype');
      prefs.remove('refreshtoken');
      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout Successful'),
            content: const Text('You have been logged out successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context)
                      .pushReplacementNamed('/'); // Navigate to login page
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle error
      print('Failed to logout');
      // Optionally show an error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout Failed'),
            content: const Text('An error occurred while logging out.'),
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.appBar('User Profile'),
      body: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile Icon (centered)
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  // Edit Button (under the profile icon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/editProfile');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(120, 30), // Smaller size
                        ),
                        child: const Text(
                          "Edit Profile",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          // Navigate to the settings page.
                          Navigator.restorablePushNamed(
                              context, SettingsView.routeName);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // White box for user details and Remove Account Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildUserInfo("Name", "$_firstName $_lastName"),
                        const SizedBox(height: 20),
                        _buildUserInfo("Email", _email),
                        const SizedBox(height: 20),
                        _buildUserInfo("Phone Number", _phoneNo),
                        const SizedBox(height: 20),
                        _buildUserInfo("Address", _address),
                        const SizedBox(height: 20),
                        _buildUserInfo("User Type", _userType),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Logout Button
                  _isLoading // Show progress indicator if loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF273F71),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            "LOGOUT",
                            style: TextStyle(color: Colors.white),
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

  Widget _buildUserInfo(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value ?? '',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
