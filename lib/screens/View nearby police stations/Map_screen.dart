import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lottie/lottie.dart';

class PoliceScreen extends StatefulWidget {
  const PoliceScreen({super.key});

  @override
  _PoliceScreenState createState() => _PoliceScreenState();
}

class _PoliceScreenState extends State<PoliceScreen> {
  bool _isLoading = false;

  /// Function to get the user's current location
  Future<void> _getLocationAndOpenMaps() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request permission and get location
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission is required.")),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Open Google Maps with current location
      _openGoogleMapsWithLocation(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Function to open Google Maps with current location
  void _openGoogleMapsWithLocation(double latitude, double longitude) async {
    final String googleMapsUrl = "https://www.google.com/maps/search/police+station/@$latitude,$longitude,15z";

    if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
      await launchUrl(Uri.parse(googleMapsUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Nearby Police Stations"),
        centerTitle: true,
        backgroundColor: Colors.yellow.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Move everything up
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // PNG Image at the top (Reduced size and moved up)
            Image.asset(
              'assets/images/police-station.png',
              height: 140, // Reduced height for better spacing
            ),

            const SizedBox(height: 15),

            // Description Text
            const Text(
              "Click the button below to find the nearest police stations around you.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 25),

            // Gradient Button
            _isLoading
                ? const CircularProgressIndicator()
                : InkWell(
              onTap: _getLocationAndOpenMaps,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "Find Nearest Police Station",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Information Box
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              color: Colors.blue.shade50,
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      "Tips:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "• Ensure your GPS is enabled.\n"
                          "• Make sure your device has an active internet connection.\n"
                          "• If Google Maps doesn’t open, try updating it.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Lottie Animation (Below Tips)
            Lottie.asset(
              'assets/lottie/police2.json', // Make sure you have this file
              height: 300, // Adjust height for balance
            ),
          ],
        ),
      ),
    );
  }
}
