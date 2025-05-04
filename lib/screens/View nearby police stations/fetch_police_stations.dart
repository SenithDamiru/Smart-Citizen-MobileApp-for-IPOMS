import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Map<String, dynamic>>> getNearbyPoliceStations(double lat, double lng) async {
  String apiKey = "AIzaSyANaXgFagIdBlF3gnix4fGk8RPnab5k9kw";
  String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
      "?location=$lat,$lng"
      "&radius=5000"
      "&type=police"
      "&key=$apiKey";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List places = jsonDecode(response.body)['results'];
    return places.map((place) => {
      "name": place['name'],
      "lat": place['geometry']['location']['lat'],
      "lng": place['geometry']['location']['lng'],
    }).toList();
  } else {
    throw Exception("Failed to load police stations");
  }
}
