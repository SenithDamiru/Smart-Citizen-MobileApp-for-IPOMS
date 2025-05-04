import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../After feedback/thank_you_screen.dart';
import '../Complaint Screen/api_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  String? _selectedFeedbackType;
  int _rating = 0;

  final String _apiUrl = "${ApiService.baseUrl}/Feedback"; // Add the '/Feedback' part here
  // Replace with your API URL

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final feedback = {
        "FeedbackType": _selectedFeedbackType,
        "Rating": _rating,
        "Comments": _commentController.text,
      };
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ThankYouScreen())
      );
      try {
        final response = await http.post(
          Uri.parse(_apiUrl),
          headers: {
            "Content-Type": "application/json",
          },
          body: jsonEncode(feedback),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Feedback submitted successfully!")),


          );
          _formKey.currentState!.reset();
          setState(() {
            _rating = 0;
            _selectedFeedbackType = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to submit feedback. (${response.statusCode})")),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset(
                'assets/images/img9.jpg', // Replace with your image path
                height: 350,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20),
              Text(
                "We Value Your Feedback",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Your feedback helps us improve and serve you better.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[700],
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Feedback Type",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Complaint",
                          child: Text("Complaint"),
                        ),
                        DropdownMenuItem(
                          value: "Suggestion",
                          child: Text("Suggestion"),
                        ),
                        DropdownMenuItem(
                          value: "Praise",
                          child: Text("Praise"),
                        ),
                        DropdownMenuItem(
                          value: "Query",
                          child: Text("Query"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFeedbackType = value;
                        });
                      },
                      validator: (value) =>
                      value == null ? "Please select feedback type" : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Rate Us:",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            _rating > index ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Comments",
                        hintText: "Write your feedback here...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? "Comment is required"
                          : null,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        "Submit Feedback",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
