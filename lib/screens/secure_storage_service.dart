import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create an instance of FlutterSecureStorage
final storage = FlutterSecureStorage();

// Function to Get CitizenID
Future<String?> getCitizenID() async {
  return await storage.read(key: 'citizenId');
}
