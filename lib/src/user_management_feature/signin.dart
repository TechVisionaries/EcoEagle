import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek_spm/src/user_management_feature/residentDashboard.dart';
import 'package:trashtrek_spm/src/user_management_feature/signup.dart';
import 'package:trashtrek_spm/src/user_management_feature/driverDashboard.dart';

class SignIn extends StatefulWidget {
  @override
  final Key? key; // Named key parameter

  const SignIn({this.key}) : super(key: key); // Named constructor parameter

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', data['accessToken']);
    prefs.setString('refreshtoken', data['refreshToken']);
    prefs.setString("userID", data['userId']);
    prefs.setString("userlogtype", data['userlogtype']);
  }

  Future<void> _loginUser() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/users/auth'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeUserData(data);
      // Ensure the widget is still mounted before navigating
      if (mounted) {
        if (data['userlogtype'] == "Resident") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Residentdashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DriverDashboard()),
          );
        }
      }
    } else {
      // Handle login error (e.g., show a snackbar or dialog)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  void _navigateToSignUp() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginUser,
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: _navigateToSignUp,
              child: const Text('Create New Account'),
            ),
          ],
        ),
      ),
    );
  }
}
