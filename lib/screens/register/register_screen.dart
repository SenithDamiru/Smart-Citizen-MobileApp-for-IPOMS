import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../After_registration/after_register_screen.dart';
import '../Complaint Screen/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalIDController = TextEditingController();
  DateTime? selectedDate;

  // Backend API URL
  final String apiUrl = '${ApiService.baseUrl}/Citizen';



  Future<void> registerCitizen() async {
    final Uri apiUrl = Uri.parse("${ApiService.baseUrl}/Citizen");

    final body = {
      "CitizenID": 0,
      "FullName": _fullNameController.text,
      "Email": _emailController.text,
      "PasswordHash": _passwordController.text,
      "PhoneNumber": _phoneNumberController.text,
      "Address": _addressController.text,
      "DateOfBirth": selectedDate?.toIso8601String(),
      "NationalID": _nationalIDController.text,
    };

    try {
      print("Sending request to $apiUrl with body: ${json.encode(body)}");
      final client = http.Client();
      final request = http.Request("POST", apiUrl)
        ..headers.addAll({"Content-Type": "application/json"})
        ..body = json.encode(body);

      final response = await client.send(request);
      final responseBody = await response.stream.bytesToString();

      print("Response status code: ${response.statusCode}");
      print("Response body: $responseBody");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Citizen registered successfully.")),
        );

        // Navigate to RegisterSuccess screen
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegisterSuccess(),
            ),
        );

      } else if (response.statusCode == 307) {
        print("Redirecting to: ${response.headers['location']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Redirected to another endpoint: ${response.headers['location']}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register citizen: $responseBody")),
        );
      }
    } catch (e) {
      print("Error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/img6.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Image.asset(
                  'assets/images/img5.png',
                  height: 200,
                ),
                Text(
                  "Let's get to know you better",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              validator: (value) =>
                              value!.isEmpty ? 'Please enter your name' : null,
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              obscureText: true,
                              validator: (value) => value!.length < 6
                                  ? 'Password must be at least 6 characters'
                                  : null,
                            ),
                            SizedBox(height: 16),
                            IntlPhoneField(
                              controller: _phoneNumberController,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              decoration: InputDecoration(
                                labelText: 'Address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                              maxLines: 2,
                            ),
                            SizedBox(height: 16),
                            InkWell(
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.3),
                                ),
                                child: Text(
                                  selectedDate == null
                                      ? 'Date Of Birth'
                                      : DateFormat('dd/MM/yyyy')
                                      .format(selectedDate!),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            TextFormField(
                              controller: _nationalIDController,
                              decoration: InputDecoration(
                                labelText: 'National ID No',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: registerCitizen,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Register Now',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
