import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final TextEditingController _houseNoController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _userType = "Resident"; // Default userType

  Future<void> _registerUser() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/users/'),
      body: {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNo': _phoneNoController.text,
        'houseNo': _houseNoController.text,
        'city': _cityController.text,
        'street': _streetController.text,
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'userType': _userType, // Send selected userType
      },
    );

    if (response.statusCode == 201) {
      // Handle success
      // ignore: use_build_context_synchronously
      Navigator.pop(context); // Return to the sign-in page
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneNoController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: _houseNoController,
              decoration: const InputDecoration(labelText: 'House No'),
            ),
            TextField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(labelText: 'Street'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Resident'),
                  leading: Radio<String>(
                    value: "Resident",
                    groupValue: _userType,
                    onChanged: (String? value) {
                      setState(() {
                        _userType = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Driver'),
                  leading: Radio<String>(
                    value: "Driver",
                    groupValue: _userType,
                    onChanged: (String? value) {
                      setState(() {
                        _userType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
