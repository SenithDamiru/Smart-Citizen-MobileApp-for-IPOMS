import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Complaint Screen/api_service.dart';

class PayFinesScreen extends StatefulWidget {
  const PayFinesScreen({super.key});

  @override
  _PayFinesScreenState createState() => _PayFinesScreenState();
}

class _PayFinesScreenState extends State<PayFinesScreen> {
  final TextEditingController _amountController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  Future<void> makePayment() async {
    try {
      print("🔹 Step 1: Creating Payment Intent...");
      paymentIntent = await createPaymentIntent(_amountController.text, 'usd');
      print("✅ Payment Intent Created: $paymentIntent");

      if (paymentIntent == null || !paymentIntent!.containsKey('clientSecret')) {
        throw Exception("❌ Payment Intent creation failed. No client secret received.");
      }

      print("🔹 Step 2: Initializing Payment Sheet...");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['clientSecret'],
          merchantDisplayName: 'Smart Citizen',
          allowsDelayedPaymentMethods: true, // Allow payment methods like Klarna
        ),
      );
      print("✅ Payment Sheet Initialized");

      print("🔹 Step 3: Presenting Payment Sheet...");
      await Stripe.instance.presentPaymentSheet();
      print("✅ Payment Successful");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful!")),
      );

      setState(() {
        paymentIntent = null;
      });
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
      appBar: AppBar(title: Text("Pay Fines")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Fine Amount (LKR)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("🔹 Pay Now button clicked");
                makePayment();
              },
              child: Text("Pay Now"),
            ),

          ],
        ),
      ),
    );
  }
}
