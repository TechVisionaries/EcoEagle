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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _emailFieldTapped = false; // Track if email field is tapped
  bool _isLoading = false; // Track if login is loading
  String? _emailError; // Track email validation errors

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmailInRealTime);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmailInRealTime);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _storeUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', data['accessToken']);
    prefs.setString('refreshtoken', data['refreshToken']);
    prefs.setString("userID", data['userId']);
    prefs.setString("userlogtype", data['userlogtype']);
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // Show loading indicator
    });

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
          Navigator.pushReplacementNamed(
            context,
            Constants.homeRoute,
          );
        } else {
          Navigator.pushReplacementNamed(
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

    setState(() {
      _isLoading = false; // Hide loading indicator
    });
  }

  void _validateEmailInRealTime() {
    final email = _emailController.text;
    setState(() {
      if (email.isNotEmpty &&
          !RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
              .hasMatch(email)) {
        _emailError = 'Please enter a valid email address';
      } else {
        _emailError = null; // Clear the error if valid
      }
    });
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
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginbackground.webp',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              const Spacer(flex: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Container(
                  height: 400,
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
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _emailFieldTapped
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
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
                          Focus(
                            onFocusChange: (hasFocus) {
                              if (hasFocus && !_emailFieldTapped) {
                                setState(() {
                                  _emailFieldTapped = true; // Track interaction
                                });
                              }
                            },
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorText:
                                    _emailError, // Show error dynamically
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
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
                          // Sign-in button with loading indicator
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _loginUser, // Disable button when loading
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue[700],
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
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
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
