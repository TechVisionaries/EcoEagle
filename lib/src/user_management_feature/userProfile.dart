import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_username != null)
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              const SizedBox(height: 20),
              if (_firstName != null && _lastName != null)
                Text(
                  'Name: $_firstName $_lastName',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 10),
              if (_email != null)
                Text(
                  'Email: $_email',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 10),
              if (_phoneNo != null)
                Text(
                  'Phone: $_phoneNo',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 10),
              if (_userType != null)
                Text(
                  'User Type: $_userType',
                  style: const TextStyle(fontSize: 18),
                ),
              const SizedBox(height: 10),
              if (_address != null)
                Text(
                  'Address: $_address',
                  style: const TextStyle(fontSize: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
