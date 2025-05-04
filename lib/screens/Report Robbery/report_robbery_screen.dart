import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Complaint Screen/api_service.dart';

// Create an instance of FlutterSecureStorage
final storage = FlutterSecureStorage();

// Function to Get CitizenID
Future<String?> getCitizenID() async {
  return await storage.read(key: 'citizenId');
}

class ReportRobberyScreen extends StatefulWidget {
  const ReportRobberyScreen({super.key});

  @override
  _ReportRobberyScreenState createState() => _ReportRobberyScreenState();
}

class _ReportRobberyScreenState extends State<ReportRobberyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _robberyTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _stolenItemsController = TextEditingController();

  DateTime? _robberyDate;
  bool _isLoading = false;
  List<dynamic> _reportedRobberies = [];

  @override
  void dispose() {
    _robberyTypeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _stolenItemsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchRobberyReports();
  }

  Future<void> _fetchRobberyReports() async {
    setState(() {
      _isLoading = true;
    });

    final citizenId = await getCitizenID();
    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Citizen ID not found. Please log in again.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse("${ApiService.getRobberyReports}/$citizenId"));

      if (response.statusCode == 200) {
        setState(() {
          _reportedRobberies = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch robbery reports.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching reports.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed!"); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    print("Form validation passed!"); // Debugging

    setState(() {
      _isLoading = true;
    });

    try {
      // Get citizen ID
      final citizenId = await getCitizenID();
      print("Citizen ID: $citizenId"); // Debugging

      if (citizenId == null) {
        print("Error: Citizen ID is null"); // Debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Citizen ID not found. Please log in.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Create request body
      final requestBody = {
        'citizenID': int.tryParse(citizenId) ?? 0,
        'robberyType': _robberyTypeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'robberyDate': _robberyDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'stolenItems': _stolenItemsController.text.trim(),
      };

      print("Request Body: ${json.encode(requestBody)}"); // Debugging

      // Make API request
      final response = await http.post(
        Uri.parse(ApiService.createRobberyReport),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      // Print API response
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        print("Robbery report submitted successfully!"); // Debugging
        _robberyTypeController.clear();
        _descriptionController.clear();
        _locationController.clear();
        _stolenItemsController.clear();
        setState(() {
          _robberyDate = null;
        });
        _fetchRobberyReports();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Robbery reported successfully!')),
        );
      } else {
        print("Failed to report robbery: ${response.body}"); // Debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report robbery: ${response.body}')),
        );
      }
    } catch (e) {
      print("Error: $e"); // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        _robberyDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report and Review Robberies',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Color.fromRGBO(116, 180, 237, 1.0),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(116, 180, 237, 1.0),
              Color.fromRGBO(43, 92, 175, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading with Image
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/thief.png', width: 70, height: 70),
                  const SizedBox(width: 10),
                  const Text(
                    'Report Robbery',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Form Container
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
                      children: [
                        TextFormField(
                          controller: _robberyTypeController,
                          decoration: InputDecoration(
                            labelText: 'Robbery Type',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the Robbery Type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
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
                            if (value == null || value.isEmpty) {
                              return 'Please enter the location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _stolenItemsController,
                          decoration: InputDecoration(
                            labelText: 'Stolen Items (Optional)',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _robberyDate == null
                                    ? 'No date selected'
                                    : 'Date: ${formatDate(_robberyDate!)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _pickDate,
                              child: const Text('Pick Date'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _submitReport,
                          style: ElevatedButton.styleFrom(
                            elevation: 9,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 60),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(19, 103, 181, 1.0),
                                  Color.fromRGBO(116, 180, 237, 1.0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                  minWidth: 150, minHeight: 50),
                              child: const Text(
                                'Submit Report',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
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

              const SizedBox(height: 20),

              // Past Reports Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/people.png', width: 70, height: 70),
                  const SizedBox(width: 10),
                  const Text(
                    'Past Robbery Reports:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Past Reports List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reportedRobberies.length,
                itemBuilder: (context, index) {
                  final report = _reportedRobberies[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        report['robberyType'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report['description'] ?? 'No description'),
                          const SizedBox(height: 5),
                          Text(
                            report['dateReported'] != null
                                ? 'Reported on: ${formatDate(DateTime.parse(report['dateReported']))}'
                                : 'Unknown Date',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: report['isResolved'] == true ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          report['isResolved'] == true ? 'Resolved' : 'Unresolved',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

}
