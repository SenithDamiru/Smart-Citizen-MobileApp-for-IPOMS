import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Complaint Screen/api_service.dart';

// Secure storage instance
final storage = FlutterSecureStorage();

// Function to retrieve Citizen ID
Future<String?> getCitizenID() async {
  return await storage.read(key: 'citizenId');
}

class ReportTrafficScreen extends StatefulWidget {
  const ReportTrafficScreen({super.key});

  @override
  _ReportTrafficScreenState createState() => _ReportTrafficScreenState();
}

class _ReportTrafficScreenState extends State<ReportTrafficScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _trafficTypeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  int _severityLevel = 1;
  bool _isLoading = false;
  List<dynamic> _reportedTrafficIssues = [];

  @override
  void initState() {
    super.initState();
    _fetchTrafficReports();
  }

  @override
  void dispose() {
    _trafficTypeController.dispose();
    _locationController.dispose();
    super.dispose();
  }
  String formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}"; // Example: 05-02-2025
  }


  Future<void> _fetchTrafficReports() async {
    setState(() {
      _isLoading = true;
    });

    final citizenId = await getCitizenID();
    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Citizen ID not found. Please log in again.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse("${ApiService.getTrafficReports}/citizen/$citizenId"));

      if (response.statusCode == 200) {
        setState(() {
          _reportedTrafficIssues = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch traffic reports.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching reports.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields.')),
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
          const SnackBar(content: Text('Citizen ID not found. Please log in.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final requestBody = {
        'citizenID': int.tryParse(citizenId) ?? 0,
        'trafficType': _trafficTypeController.text.trim(),
        'location': _locationController.text.trim(),
        'severityLevel': _severityLevel,
      };

      final response = await http.post(
        Uri.parse(ApiService.createTrafficReport),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        _trafficTypeController.clear();
        _locationController.clear();
        _fetchTrafficReports();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Traffic issue reported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to report traffic issue: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Report and Review Traffic Issues',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Color.fromRGBO(116, 180, 237, 1.0),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(202, 58, 162, 1.0),
              Color.fromRGBO(239, 206, 255, 1.0),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/traffic.png', width: 70, height: 70),
                  const SizedBox(width: 10),
                  const Text(
                    'Report Traffic Issue',
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
                          controller: _trafficTypeController,
                          decoration: InputDecoration(
                            labelText: 'Traffic Issue Type',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the traffic issue type';
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
                        DropdownButtonFormField<int>(
                          value: _severityLevel,
                          decoration: InputDecoration(
                            labelText: 'Severity Level',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          dropdownColor: Colors.black.withOpacity(0.7),
                          style: const TextStyle(color: Colors.white),
                          items: List.generate(5, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text('${index + 1} - ${["Low", "Mild", "Moderate", "High", "Severe"][index]}'),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _severityLevel = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator()
                            :ElevatedButton(
                          onPressed: _isLoading ? null : _submitReport,
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

// Past Traffic Reports Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/warning.png', width: 70, height: 70),
                  const SizedBox(width: 10),
                  const Text(
                    'Past Reported Traffic Issues:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

// Past Traffic Reports List
              _reportedTrafficIssues.isEmpty
                  ? const Text(
                "No traffic reports found.",
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              )
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reportedTrafficIssues.length,
                itemBuilder: (context, index) {
                  final report = _reportedTrafficIssues[index];
                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        report['trafficType'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(report['location'] ?? 'Location not specified'),
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
