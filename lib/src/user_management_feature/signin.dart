import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trashtrek/common/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignIn extends StatefulWidget {
  @override
  final Key? key;

  const SignIn({this.key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Add a form key
  bool _isPasswordVisible = false;

  // Variable to hold email validation error

  @override
  void initState() {
    super.initState();

    // Add listener to the email controller for real-time validation
    _emailController.addListener(() {
      _validateEmail();
    });
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', data['accessToken']);
    prefs.setString('refreshtoken', data['refreshToken']);
    prefs.setString("userID", data['userId']);
    prefs.setString("userlogtype", data['userlogtype']);
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate())
      return; // Ensure form validation before login

    final baseUrl = dotenv.env[Constants.baseURL];
    final response = await http.post(
      Uri.parse('$baseUrl/users/auth'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storeUserData(data);
      if (mounted) {
        if (data['userlogtype'] == "Resident") {
          Navigator.restorablePushNamed(
            context,
            Constants.residentDashboardRoute,
          );
        } else {
          Navigator.restorablePushNamed(
            context,
            Constants.driverDashboardRoute,
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  // Email validation logic
  String? _validateEmail() {
    final email = _emailController.text;
    if (email.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
            .hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  void _navigateToSignUp() {
    if (mounted) {
      Navigator.restorablePushNamed(
        context,
        Constants.signUpRoute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginbackground.webp',
              fit: BoxFit.cover,
            ),
          ),
          // White box with headline
          Column(
            children: [
              const Spacer(flex: 15), // Pushes the content lower
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  height: 400, // Set height explicitly here
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Form(
                    // Add Form widget to group input fields
                    key: _formKey,
                    autovalidateMode: AutovalidateMode
                        .onUserInteraction, // Real-time validation
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        // Headline with green background inside white box
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: Text(
                            '-SIGN IN-',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Email TextFormField with real-time validation
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorText:
                                _validateEmail(), // Show validation message in real-time
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => _validateEmail(),
                        ),
                        const SizedBox(height: 20),
                        // Password TextFormField
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loginUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                Colors.blue[700], // Blue color for button
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: _navigateToSignUp,
                          child: const Text(
                            'Create New Account',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2), // Adjusts the bottom space
            ],
          ),
        ],
      ),
    );
  }
}
