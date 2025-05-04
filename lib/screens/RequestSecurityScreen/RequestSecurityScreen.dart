import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../Complaint Screen/api_service.dart';

class RequestSecurityScreen extends StatefulWidget {
  @override
  _RequestSecurityScreenState createState() => _RequestSecurityScreenState();
}

class _RequestSecurityScreenState extends State<RequestSecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _securityDate;

  bool _isLoading = false;
  List<dynamic> _pastRequests = []; // List to store past requests

  // Get CitizenID from FlutterSecureStorage
  Future<String?> _getCitizenID() async {
    const storage = FlutterSecureStorage();
    return await storage.read(key: 'citizenId');
  }

  // Method to format the date
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Fetch past requests
  Future<void> _fetchPastRequests() async {
    final citizenId = await _getCitizenID();

    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Citizen ID not found.')),
      );
      return;
    }

    // Debugging the API response
    try {
      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/SecurityRequest?citizenId=$citizenId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data); // Debug here
        setState(() {
          _pastRequests = data; // Ensure it's a list
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch past requests.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

  }



  // Submit the request
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || _securityDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final citizenId = await _getCitizenID();

    if (citizenId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Citizen ID not found.')),
      );
      return;
    }

    final requestBody = {
      "CitizenID": int.parse(citizenId),
      "RequestReason": _reasonController.text.trim(),
      "Location": _locationController.text.trim(),
      "SecurityDate": _securityDate!.toIso8601String(),
      "Description": _descriptionController.text.trim(),
    };

    try {
      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/SecurityRequest"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Security request submitted successfully!')),
        );
        _reasonController.clear();
        _locationController.clear();
        _descriptionController.clear();
        setState(() {
          _securityDate = null;
        });
        await _fetchPastRequests(); // Refresh past requests
      } else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Submission failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // UI for date picker
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _securityDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPastRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text('Request And Review Your Security Requests',
          style: TextStyle(
            fontSize: 18,


          ),),
        backgroundColor: Colors.lightGreen, // Example custom app bar
      ),
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(110, 193, 18, 1.0),
              Color.fromRGBO(225, 74, 27, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers horizontally
                  crossAxisAlignment: CrossAxisAlignment.center, // Aligns vertically (default)
                  children: [

                    Image.asset('assets/images/guard.png', width: 50, height: 50),
                    const SizedBox(width: 10),
                    const Text(
                      'Request For Security',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset('assets/images/policing.png', width: 50, height: 50),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              labelText: 'Reason for Security',
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Reason is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              labelText: 'Location',
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Location is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _securityDate == null
                                    ? 'Select Date'
                                    : formatDate(_securityDate!), // Format the picked date
                                style: TextStyle(
                                  color: _securityDate == null ? Colors.grey : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Description (Optional)',
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            style: const TextStyle(color: Colors.white),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          _isLoading
                              ? Center(child: CircularProgressIndicator())
                              : Center(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.green.shade800, Colors.lightGreenAccent.shade700], // Gradient colors
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2), // Shadow color
                                    blurRadius: 10, // Blur effect
                                    offset: Offset(0, 5), // Offset in x and y
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent, // Makes the Material widget transparent
                                child: InkWell(
                                  onTap: _submitRequest,
                                  borderRadius: BorderRadius.circular(20), // Match the border radius
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                                    child: Text(
                                      'Submit Request',
                                      style: TextStyle(
                                        color: Colors.white, // Text color
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers horizontally
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/police-station.png', width: 50, height: 50),
                    SizedBox(width: 10),
                    Text(
                      ' Review Your Security Requests',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 16),
                _pastRequests.isEmpty
                    ? Text(
                  'No past requests found.',
                  style: TextStyle(color: Colors.white),
                )
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent nested scrolling
                  itemCount: _pastRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pastRequests[index];
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          request['requestReason'] ?? 'No reason provided',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requested On: ${request['securityDate']?.split("T")[0] ?? "N/A"}',
                            ),
                            Text(
                              'Status: ${request['status'] ?? "Unknown"}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
