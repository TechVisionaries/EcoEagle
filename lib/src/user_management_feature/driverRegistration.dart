import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trashtrek/common/constants.dart';

class DriverRegistraion extends StatefulWidget {
  const DriverRegistraion({super.key});

  static const routeName = Constants.driverRegistraionRoute;
  @override
  _DriverRegistrationState createState() => _DriverRegistrationState();
}

class _DriverRegistrationState extends State<DriverRegistraion> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _cityError;
  String? _streetError;
  String? _passwordError;
  String? _confirmPasswordError;

  String? _selectedCity;
  String? _selectedStreet;
  List<String> _streets = [];

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

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(() {
      _validateFirstName();
    });
    _lastNameController.addListener(() {
      _validateLastName();
    });
    _emailController.addListener(() {
      _validateEmail();
    });
    _phoneNoController.addListener(() {
      _validatePhoneNo();
    });
    _passwordController.addListener(() {
      _validatePassword();
    });
    _confirmPasswordController.addListener(() {
      _validateConfirmPassword();
    });
  }

  void _validateFirstName() {
    setState(() {
      if (_firstNameController.text.isEmpty ||
          !_firstNameController.text.contains(RegExp(r'^[a-zA-Z]+$'))) {
        _firstNameError = 'Invalid First Name';
      } else {
        _firstNameError = null;
      }
    });
  }

  void _validateLastName() {
    setState(() {
      if (_lastNameController.text.isEmpty ||
          !_lastNameController.text.contains(RegExp(r'^[a-zA-Z]+$'))) {
        _lastNameError = 'Invalid Last Name';
      } else {
        _lastNameError = null;
      }
    });
  }

  void _validateEmail() {
    setState(() {
      if (_emailController.text.isEmpty ||
          !_emailController.text.contains(
              RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"))) {
        _emailError = 'Invalid Email';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhoneNo() {
    setState(() {
      if (_phoneNoController.text.isEmpty ||
          !_phoneNoController.text.contains(RegExp(r'^\d{10}$'))) {
        _phoneError = 'Invalid Phone Number';
      } else {
        _phoneError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      if (_passwordController.text.isEmpty) {
        _passwordError = 'Password is required';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Confirm Password is required';
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = 'Password mismatch';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _validateCity() {
    setState(() {
      if (_selectedCity == null || _selectedCity!.isEmpty) {
        _cityError = 'City is required';
      } else {
        _cityError = null;
      }
    });
  }

  void _validateStreet() {
    setState(() {
      if (_selectedStreet == null || _selectedStreet!.isEmpty) {
        _streetError = 'Street is required';
      } else {
        _streetError = null;
      }
    });
  }

  Future<void> _fetchStreets(String cityName) async {
    final baseUrl = dotenv.env[Constants.baseURL];
    final response =
        await http.get(Uri.parse('$baseUrl/cities/citylist/$cityName'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final fetchedStreets =
          List<String>.from(data['cities'].map((city) => city['city_name']));

      setState(() {
        _streets = fetchedStreets..sort(); // Sort streets alphabetically
        _selectedStreet = null; // Reset selected street when city changes
      });
    } else {
      // Handle error or show a message
      setState(() {
        _streets = [];
      });
    }
  }

  Future<void> _registerUser() async {
    print("heho");
    if (!_validateForm()) return;
    print("huhu");
    setState(() {
      _isLoading = true;
    });

    final baseUrl = dotenv.env[Constants.baseURL];
    print('$baseUrl/users/');
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      body: {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'houseNo': "Driver",
        'city': _selectedCity,
        'street': _selectedStreet,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'userType': 'Driver',
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      // Handle error
    }
  }

  bool _validateForm() {
    bool isValid = true;

    setState(() {
      _validateFirstName();
      _validateLastName();
      _validateEmail();
      _validatePhoneNo();
      _validateCity();
      _validateStreet();
      _validatePassword();
      _validateConfirmPassword();
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver Registration',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        errorText: _firstNameError,
                      ),
                    ),
                    TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        errorText: _lastNameError,
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: _emailError,
                      ),
                    ),
                    TextField(
                      controller: _phoneNoController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        errorText: _phoneError,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: InputDecoration(
                        labelText: 'District / City',
                        errorText: _cityError,
                      ),
                      items:
                          _cities.map<DropdownMenuItem<String>>((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                        _fetchStreets(newValue!);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedStreet,
                      decoration: InputDecoration(
                        labelText: 'Town',
                        errorText: _streetError,
                      ),
                      items: _streets
                          .map<DropdownMenuItem<String>>((String street) {
                        return DropdownMenuItem<String>(
                          value: street,
                          child: Text(street),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStreet = newValue;
                        });
                      },
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        errorText: _passwordError,
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
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        errorText: _confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isConfirmPasswordVisible,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 65, 168, 125),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Register Driver'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
