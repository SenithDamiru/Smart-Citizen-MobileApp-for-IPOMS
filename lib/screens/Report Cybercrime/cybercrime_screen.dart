import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Reusable API service
import '../Complaint Screen/api_service.dart';
import '../secure_storage_service.dart'; // Secure storage for CitizenID

class CyberCrimeScreen extends StatefulWidget {
  const CyberCrimeScreen({super.key});

  @override
  _CyberCrimeScreenState createState() => _CyberCrimeScreenState();
}

class _CyberCrimeScreenState extends State<CyberCrimeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _reportTypeController = TextEditingController();
  final TextEditingController _evidenceURLController = TextEditingController();
  List<dynamic> _cyberCrimes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCyberCrimes();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reportTypeController.dispose();
    _evidenceURLController.dispose();
    super.dispose();
  }


  Future<void> _fetchCyberCrimes() async {
    setState(() {
      _isLoading = true;
    });

    final citizenId = await getCitizenID();
    print("Citizen ID: $citizenId");
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
      final response = await http.get(Uri.parse("${ApiService.getCyberCrimes}?citizenId=$citizenId"));
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          _cyberCrimes = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch cybercrime reports. Please try again.")),
        );
      }
    } catch (e) {
      print("Error fetching cybercrime reports: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching reports.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Submit Cyber Crime Report
  Future<void> _submitCyberCrime() async {
    final citizenId = await getCitizenID();
    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Citizen ID not found. Please log in again.")),
      );
      return;
    }

    final description = _descriptionController.text.trim();
    final reportType = _reportTypeController.text.trim();
    final evidenceURL = _evidenceURLController.text.trim();

    if (description.isEmpty || reportType.isEmpty || evidenceURL.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiService.createCyberCrime),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "citizenID": int.parse(citizenId),
          "reportType": reportType,
          "description": description,
          "evidenceURL": evidenceURL,
          "assignedOfficer": null, // Temporary placeholder
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cybercrime reported successfully")),
        );
        _descriptionController.clear();
        _reportTypeController.clear();
        _evidenceURLController.clear();
        _fetchCyberCrimes();
      } else {
        final errorResponse = jsonDecode(response.body);
        print("Error Response: $errorResponse");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorResponse["message"] ?? "Failed to report cybercrime.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while reporting the cybercrime.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report and Review Cybercrime"),
        backgroundColor: Colors.blue[300],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(44, 62, 80, 1.0),
              Color.fromRGBO(52, 152, 219, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  Image.asset('assets/images/hack.png', width: 50, height: 50),
                  const SizedBox(width: 10),
                  const Text(
                    'Report Cybercrime',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Input form
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _reportTypeController,
                        decoration: InputDecoration(
                          labelText: "Report Type",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _evidenceURLController,
                        decoration: InputDecoration(
                          labelText: "Evidence URL",
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitCyberCrime,
                        style: ElevatedButton.styleFrom(
                          elevation: 9, // Drop shadow intensity
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 60), // Padding inside the button
                          backgroundColor: Colors.transparent, // To allow gradient
                          shadowColor: Colors.black.withOpacity(0.3), // Shadow color
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurpleAccent,
                                Colors.lightBlueAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            constraints: BoxConstraints(minWidth: 150, minHeight: 50), // Minimum button size
                            child: Text(
                              "Submit Complaint",
                              style: TextStyle(
                                color: Colors.white, // White text
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

              const SizedBox(height: 20),
              Row(
                children: [
                  Image.asset('assets/images/cyber-crime.png', width: 50, height: 50),
                  SizedBox(width: 10),
                  Text(
                    ' Review Your Cybercrimes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Display existing reports
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: _cyberCrimes.length,
                  itemBuilder: (context, index) {
                    final crime = _cyberCrimes[index];
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(crime["reportType"] ?? "No Title",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(crime["description"] ?? "No Description"),
                            const SizedBox(height: 5),
                            Text("Reported on: ${DateTime.parse(crime["dateReported"]).toLocal().toString().split(' ')[0] ?? "N/A"}",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        trailing: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: crime["reportStatus"] == "Resolved"
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            crime["reportStatus"],
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
