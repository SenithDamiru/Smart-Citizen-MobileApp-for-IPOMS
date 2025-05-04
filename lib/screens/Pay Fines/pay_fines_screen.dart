import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'hide Card;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Complaint Screen/api_service.dart';

final storage = FlutterSecureStorage();

Future<String?> getCitizenID() async {
  return await storage.read(key: 'citizenId');
}

class PayFinesScreen extends StatefulWidget {
  const PayFinesScreen({super.key});

  @override
  _PayFinesScreenState createState() => _PayFinesScreenState();
}

class _PayFinesScreenState extends State<PayFinesScreen> {
  List<dynamic> finesList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchFines();
  }

  Future<void> _fetchFines() async {
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
      final response = await http.get(Uri.parse("${ApiService.getFines}/citizen/$citizenId"));

      if (response.statusCode == 200) {
        setState(() {
          finesList = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to fetch fines. Please try again.")),
        );
      }
    } catch (e) {
      print("❌ Error fetching fines: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while fetching fines.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  Future<void> deleteFine(String fineId) async {
    try {
      print("🗑️ Deleting Fine ID: $fineId...");

      final response = await http.delete(
        Uri.parse("${ApiService.deleteFine}/$fineId"),
      );

      if (response.statusCode == 200) {
        print("✅ Fine successfully deleted.");
      } else {
        print("❌ Error deleting fine: ${response.body}");
        throw Exception("Failed to delete fine.");
      }
    } catch (e) {
      print("❌ Exception in deleteFine: $e");
    }
  }


  Future<void> makePayment(String fineId, String amount) async {
    try {
      print("🔹 Step 1: Creating Payment Intent...");

      // Convert to a valid number format
      final formattedAmount = double.parse(amount).toInt(); // Ensure amount is an integer

      final paymentIntent = await createPaymentIntent(formattedAmount.toString(), 'usd');
      print("✅ Payment Intent Created: $paymentIntent");

      if (paymentIntent == null || !paymentIntent.containsKey('clientSecret')) {
        throw Exception("❌ Payment Intent creation failed. No client secret received.");
      }

      print("🔹 Step 2: Initializing Payment Sheet...");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['clientSecret'],
          merchantDisplayName: 'Smart Citizen',
          allowsDelayedPaymentMethods: true,
        ),
      );
      print("✅ Payment Sheet Initialized");

      print("🔹 Step 3: Presenting Payment Sheet...");
      await Stripe.instance.presentPaymentSheet();
      print("✅ Payment Successful");

      // **🔹 Step 4: Delete the fine from the database**
      await deleteFine(fineId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful! Fine deleted.")),
      );

      // Refresh the list after deleting
      _fetchFines();

    } catch (e) {
      print("❌ Error during payment: $e");

      if (e is StripeException) {
        print("❌ Stripe Exception: ${e.error.localizedMessage}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Cancelled: ${e.error.localizedMessage}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed: $e")),
        );
      }
    }
  }



  Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
    try {
      print("🔹 Sending request to create Payment Intent...");

      var response = await http.post(
        Uri.parse(ApiService.createPaymentIntent),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Amount': int.parse(amount)}),
      );

      print("✅ Raw Response: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("❌ Error: ${response.body}");
      }

      var decodedResponse = jsonDecode(response.body);

      if (!decodedResponse.containsKey('clientSecret')) {
        throw Exception("❌ Response does not contain client_secret");
      }

      return decodedResponse;
    } catch (err) {
      print("❌ Error in createPaymentIntent: $err");
      throw Exception(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pay Fines Online',
          style: TextStyle(fontSize: 24),
        ),
        backgroundColor: Colors.yellow[700],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(182, 244, 0, 1.0),
              Color.fromRGBO(109, 112, 35, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // ✅ Police Image and Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/police.png', // Make sure the image is in your assets folder
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Pay Your Fines Here Online Before Due Dates",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : finesList.isEmpty
                  ? const Center(
                child: Text(
                  "No pending fines.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: finesList.length,
                itemBuilder: (context, index) {
                  final fine = finesList[index];

                  return Card(
                    color: Colors.white.withOpacity(0.8),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      // ✅ Fine icon on the left
                      leading: Image.asset(
                        'assets/images/fine.png', // Make sure the image is in your assets folder
                        height: 40,
                        width: 40,
                      ),
                      title: Text(
                        "Fine Amount: USD ${fine['fineAmount']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Reason: ${fine['fineReason'] ?? 'Not specified'}"),
                          Text("Due Date: ${fine['dueDate'] ?? 'N/A'}"),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.deepOrange],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: () {
                            if (fine['fineAmount'] != null) {
                              makePayment(fine['fineID'].toString(), fine['fineAmount'].toString());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Fine amount is missing")),
                              );
                            }
                          },
                          child: const Text(
                            "Pay Now",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
  }

}
