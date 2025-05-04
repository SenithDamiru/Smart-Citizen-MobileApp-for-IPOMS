import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api_service.dart'; // Reusable API service
import '../secure_storage_service.dart'; // Secure storage for CitizenID

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  _ComplaintsScreenState createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<dynamic> _complaints = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
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
      final response = await http.get(Uri.parse("${ApiService.getComplaints}?citizenId=$citizenId"));
      if (response.statusCode == 200) {
        setState(() {
          _complaints = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch complaints. Please try again.")),
        );
      }
    } catch (e) {
      print("Error fetching complaints: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while fetching complaints.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> _submitComplaint() async {
    final citizenId = await getCitizenID();
    if (citizenId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Citizen ID not found. Please log in again.")),
      );
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiService.createComplaint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "citizenID": int.parse(citizenId),
          "complaintTitle": title,
          "complaintDescription": description,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Complaint submitted successfully")),
        );
        _titleController.clear();
        _descriptionController.clear();
        _fetchComplaints();
      } else {
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorResponse["message"] ?? "Failed to submit complaint.")),
        );
      }
    } catch (e) {
      print("Error submitting complaint: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while submitting the complaint.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Make and Review Complaints"),
        backgroundColor: Colors.blue[300],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
              Color.fromRGBO(92, 44, 166, 1.0), // Custom color 1
              Color.fromRGBO(128, 159, 230, 1.0),
          ],// Custom color 2
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and Title
              Row(
                children: [
                  Image.asset('assets/images/complain.png', width: 50, height: 50),
                  SizedBox(width: 10),
                  Text(
                    ' Make a Complaint',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Complaint creation container with blur effect
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: "Complaint Title",
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: "Complaint Description",
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                        ),
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitComplaint,
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
              SizedBox(height: 20),

              Row(
                children: [
                  Image.asset('assets/images/dissatisfaction.png', width: 50, height: 50),
                  SizedBox(width: 10),
                  Text(
                    ' Review Your Complaints',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Displaying the complaints
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Expanded(
                child: ListView.builder(
                  itemCount: _complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = _complaints[index];
                    return Card(
                      color: Colors.white.withOpacity(0.7),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          complaint["complaintTitle"],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(complaint["complaintDescription"]),
                        trailing: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: complaint["complaintStatus"] == "Resolved"
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            complaint["complaintStatus"],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
