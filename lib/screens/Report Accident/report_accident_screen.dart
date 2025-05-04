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

class ReportAccidentScreen extends StatefulWidget {
  const ReportAccidentScreen({super.key});

  @override
  _ReportAccidentScreenState createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _accidentTypeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  DateTime? _accidentDate;
  bool _isLoading = false;
  List<dynamic> _reportedAccidents = [];

  @override
  void dispose() {
    _accidentTypeController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAccidentReports();
  }

  Future<void> _fetchAccidentReports() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final citizenId = await getCitizenID();
    print("Citizen ID: $citizenId");
    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Citizen ID not found. Please log in again.")),
      );
      setState(() {
        _isLoading = false; // Stop loading if Citizen ID is missing
      });
      return;
    }

    try {
      // Perform the HTTP GET request
      final response = await http.get(Uri.parse("${ApiService.getAccidentReports}/$citizenId"));

      if (response.statusCode == 200) {
        // Parse and update accident reports if successful
        setState(() {
          _reportedAccidents = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch accident reports. Please try again.")),
        );
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print("Error fetching accident reports: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while fetching accident reports.")),
      );
    } finally {
      // Ensure loading state is updated regardless of success or failure
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final citizenId = await getCitizenID();
      if (citizenId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Citizen ID not found. Please log in.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final requestBody = {
        'CitizenID': int.tryParse(citizenId) ?? 0, // Fallback to 0
        'AccidentType': _accidentTypeController.text.isNotEmpty
            ? _accidentTypeController.text
            : "Unknown",
        'Description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : "No description provided",
        'Location': _locationController.text.isNotEmpty
            ? _locationController.text
            : "Unknown location",
        'DateReported': _accidentDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      };

      print('Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(ApiService.createAccidentReport),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 201) {
        _accidentTypeController.clear();
        _descriptionController.clear();
        _locationController.clear();
        setState(() {
          _accidentDate = null;
        });
        _fetchAccidentReports();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accident reported successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report accident: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred.')));
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
        _accidentDate = selectedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report and Review Accidents',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.red[300],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(220, 14, 14, 1.0),
              Color.fromRGBO(255, 123, 123, 1.0),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers horizontally
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/accident.png', width: 70, height: 70),
                    const SizedBox(width: 10),
                    const Text(
                      'Report Accident',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                            controller: _accidentTypeController,
                            decoration: InputDecoration(
                              labelText: 'Accident Type',
                              labelStyle: const TextStyle(color: Colors.white),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the accident type';
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
                                return 'Please enter a description';
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _accidentDate == null
                                      ? 'No date selected'
                                      : 'Date: ${formatDate(_accidentDate!)}',
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
                                    Colors.red,
                                    Colors.pinkAccent,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centers horizontally
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/accident1.png', width: 50, height: 50),
                    const SizedBox(width: 10),
                    const Text(
                      'Past Accident Reports:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reportedAccidents.length,
                  itemBuilder: (context, index) {
                    final report = _reportedAccidents[index];
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          report['accidentType'] ?? 'Unknown',
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
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red,
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
      ),
    );
  }

}
