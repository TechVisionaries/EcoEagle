import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';

class EditUserProfile extends StatefulWidget {
  const EditUserProfile({super.key});

  @override
  _EditUserProfileState createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phoneNo;
  String? _houseNo;
  String? _street;
  String? _city;
  bool _isLoading = false; // Add this variable to track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = dotenv.env[Constants.baseURL];
    final username = prefs.getString('userID');
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/profile/$username'),
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
        _houseNo = data['address']['houseNo'];
        _street = data['address']['street'];
        _city = data['address']['city'];

        _firstNameController.text = _firstName ?? '';
        _lastNameController.text = _lastName ?? '';
        _emailController.text = _email ?? '';
        _phoneNoController.text = _phoneNo ?? '';
        _houseNoController.text = _houseNo ?? '';
        _streetController.text = _street ?? '';
        _cityController.text = _city ?? '';
      });
    } else {
      print('Failed to load user data');
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final prefs = await SharedPreferences.getInstance();
    final baseUrl = dotenv.env[Constants.baseURL];
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': _emailController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNo': _phoneNoController.text,
        'address': {
          'houseNo': _houseNoController.text,
          'street': _streetController.text,
          'city': _cityController.text,
        },
      }),
    );

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (response.statusCode == 200) {
      // Successfully updated
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushReplacementNamed(
        context,
        Constants.userProfileRoute,
      ); // Go back to the previous screen
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 65, 168, 125),
        foregroundColor: Colors.black,
      ),
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // User profile icon at the top center
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 10),
                // White box to wrap the input fields
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          hintText: _firstName ?? 'Enter your first name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          hintText: _lastName ?? 'Enter your last name',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: _email ?? 'Enter your email',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _phoneNoController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: _phoneNo ?? 'Enter your phone number',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _houseNoController,
                        decoration: InputDecoration(
                          labelText: 'House No',
                          hintText: _houseNo ?? 'Enter your house number',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _streetController,
                        decoration: InputDecoration(
                          labelText: 'Street',
                          hintText: _street ?? 'Enter your street',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          hintText: _city ?? 'Enter your city',
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading // Show progress indicator if loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _saveUserData,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 65, 168, 125),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
