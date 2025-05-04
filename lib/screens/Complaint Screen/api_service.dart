class ApiService {
  static const String baseUrl = "http://192.168.1.178:5000/api"; // Change localhost to your IP if needed.

  // Endpoints
  static String getComplaints = "$baseUrl/Complaints";
  static String createComplaint = "$baseUrl/Complaints";
  static String updateComplaint(int id) => "$baseUrl/Complaints/$id";
  static String deleteComplaint(int id) => "$baseUrl/Complaints/$id";


  static String getCyberCrimes = "$baseUrl/CyberCrimeReports";
  static String createCyberCrime = "$baseUrl/CyberCrimeReports";

  static String getAccidentReports = "$baseUrl/AccidentReports";
  static String createAccidentReport = "$baseUrl/AccidentReports";

  static String createRobberyReport = "$baseUrl/RobberyReports";
  static String getRobberyReports = "$baseUrl/RobberyReports/citizen";

  static String getTrafficReports = "$baseUrl/TrafficReports";
  static String createTrafficReport = "$baseUrl/TrafficReports";

  static const String createPoliceReport = '$baseUrl/PoliceReports';
  static const String getPoliceReports = '$baseUrl/PoliceReports/Citizen';

  static const String createPaymentIntent = '$baseUrl/payments/create-payment-intent';
  static const String getFines = "$baseUrl/Fines";
  static const String deleteFine = "$baseUrl/Fines";

  static const String getCitizen = "$baseUrl/Citizen";




}
