import 'package:flutter/material.dart';
import 'package:untitled2/screens/Report%20Cybercrime/cybercrime_screen.dart';
import 'package:untitled2/screens/dashboard/user_profile_screen.dart';
import 'package:untitled2/screens/dashboard/widgets/item_news_feed.dart';
import 'package:untitled2/screens/dashboard/widgets/item_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

import '../Complaint Screen/api_service.dart';
import '../Complaint Screen/complaint_screen.dart';
import '../Pay Fines/pay_fines_screen.dart';
import '../Report Accident/report_accident_screen.dart';
import '../Report Robbery/report_robbery_screen.dart';
import '../Report Traffic/report_traffic_screen.dart';
import '../RequestSecurityScreen/RequestSecurityScreen.dart';
import '../View nearby police stations/Map_screen.dart';
import '../feedback/feedback_screen.dart';
import '../View nearby police stations/map.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../police report/police_report_screen.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget{
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();

}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<RemoteMessage> _notifications = [];
  String citizenName = "User"; // Default name// To store Firebase notifications

  // Fetch news data
  Future<List<dynamic>> fetchNews() async {
    const url =
        'https://newsdata.io/api/1/latest?country=lk&category=top&apikey=pub_665804bf2f0246f12e6d6e27c47870390fd16';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes)); // Decode UTF-8.

      if (data != null && data['results'] != null) {
        final List<dynamic> results = data['results'];

        // Remove duplicate articles based on 'title'.
        final uniqueTitles = <String>{};
        return results.where((article) {
          final title = article['title'] ?? '';
          if (uniqueTitles.contains(title)) return false;
          uniqueTitles.add(title);

          // Ensure each article has a valid 'image_url'.
          if (article['image_url'] == null || article['image_url'].isEmpty) {
            article['image_url'] = ''; // Use an empty string for missing images.
          }
          return true;
        }).toList();
      }
    }
    return [];
  }



  // Function to make the call
  void _makeCall() async {
    const phoneNumber = 'tel:119'; // Format for a phone call
    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  //Function to send SMS
  void _sendSMS() async {
    const phoneNumber = 'sms:119?body=Hello, I need assistance';
    try {
      final uri = Uri.parse(phoneNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      // Show a Snackbar or dialog for better user feedback
      // Assuming you're calling this in a widget context
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error sending SMS: $e')),
      // );
    }
  }


  final storage = FlutterSecureStorage();

  Future<String?> getCitizenID() async {
    return await storage.read(key: 'citizenId'); // Get stored citizen ID
  }

  Future<String?> fetchCitizenName() async {
    final citizenId = await getCitizenID();
    if (citizenId == null) {
      return null; // If no citizen ID is found, return null
    }

    final response = await http.get(Uri.parse("${ApiService.getCitizen}/$citizenId"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['fullName']; // Adjust key name according to your API response
    } else {
      return null; // Return null if API call fails
    }
  }


  @override
  void initState() {
    super.initState();
    loadCitizenName();


    // Initialize Firebase Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      setState(() {
        _notifications.add(message);
      });
    });

    // Handling background messages (for notifications when app is in the background)
    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      // Handle foreground notification
      print("Received a message in the foreground: ${message.notification?.title}");
      // Handle the background message logic here
      debugPrint('Background Message: ${message.notification?.title}');
    });


  }

  Future<void> loadCitizenName() async {
    String? name = await fetchCitizenName();
    if (name != null) {
      setState(() {
        citizenName = name;
      });
    }
  }

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        endDrawer: UserProfileDrawer(),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 15, right: 10),
            child: Image.asset('assets/images/menu.png', color: Colors.white,),
          ),
          backgroundColor: Colors.transparent,
          elevation: 4,
          scrolledUnderElevation: 0,
          title: const Text(
            'Smart Citizen', style: TextStyle(color: Colors.white),),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          actions: [
            IconButton(
              onPressed: () {
                // Show notifications in a modal or dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Notifications'),
                      content: _notifications.isEmpty
                          ? const Text('No notifications available.')
                          : SizedBox(
                        height: 300,
                        width: 300,
                        child: ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            return ListTile(
                              title: Text(notification.notification?.title ?? 'No Title'),
                              subtitle: Text(notification.notification?.body ?? 'No Body'),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.notifications_none_sharp),
            )
          ],
        ),
        body: Column(
          children: [
            // Add gradient background here
            Container(
              padding: const EdgeInsets.only(top: 100, left: 15, right: 15, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                  Colors.purple.shade900, // Start color of the gradient
                  Colors.lightBlueAccent, // End color of the gradient
                ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                          text: TextSpan(
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                  letterSpacing: 1,
                                  color: Colors.white
                              ),
                              children: [
                                TextSpan(text: 'Hi,'),
                                TextSpan(
                                    text: citizenName, // Display fetched citizen name
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)
                                )
                              ]
                          )
                      ),
                      // In your dashboard file
                      Builder(
                        builder: (BuildContext context) => Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70, width: 2)
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openEndDrawer();
                            },
                            child: const CircleAvatar(
                              backgroundImage: AssetImage('assets/images/boy.png'),
                              radius: 30,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15,),
                  Text('Do you have an emergency?', style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                      color: Colors.white
                  ),),
                  const SizedBox(height: 5,),
                  const Text(
                    'Now you can contact us in case of any emergency. You can call or message just by pressing buttons below.',
                    style: TextStyle(color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        height: 1.5),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _makeCall,
                          label: const Text('Call Now'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(15)
                          ),
                          icon: const Icon(Icons.call),

                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendSMS,
                          label: const Text('Send SMS'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(15)
                          ),
                          icon: const Icon(Icons.message),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ListTile(
                    title: Text('Our Services', style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,),
                  ),
                  SizedBox(
                    height: 310, // Increased height to accommodate both sets
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 10, left: 5, right: 5),
                            scrollDirection: Axis.horizontal,
                            children: [
                              ItemService(title: 'Report\nRobbery', image: 'assets/images/thief.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReportRobberyScreen()),
                                );
                              },),
                              ItemService(title: 'Report\nTraffic', image: 'assets/images/traffic.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReportTrafficScreen()),
                                );
                              },),
                              ItemService(title: 'Pay\nFines', image: 'assets/images/challan.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PayFinesScreen()),
                                );
                              },),
                              ItemService(title: 'Request Police\nReport', image: 'assets/images/report.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReportPoliceIncidentScreen()),
                                );
                              },),
                              ItemService(title: 'View Nearby\nPolice Station', image: 'assets/images/route.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PoliceScreen()),
                                );
                              },),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10), // Add spacing between the two sets
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 10, left: 5, right: 5),
                            scrollDirection: Axis.horizontal,
                            children: [
                              ItemService(title: 'Make\nComplaint', image: 'assets/images/complain.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ComplaintsScreen()),
                                );
                              },),


                              ItemService(title: 'Report\nCybercrime', image: 'assets/images/hack.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CyberCrimeScreen()),
                                );
                              },),
                              ItemService(title: 'Request\nSecurity', image: 'assets/images/guard.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => RequestSecurityScreen()),
                                );
                              },),
                              ItemService(title: 'Report\nAccident', image: 'assets/images/accident.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ReportAccidentScreen()),
                                );
                              },),
                              ItemService(title: 'Give\nFeedback', image: 'assets/images/review.png', onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => FeedbackScreen()),
                                );
                              },),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  const SizedBox(height: 15),
                  ListTile(
                    title: Text(
                      'News Feed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  FutureBuilder<List<dynamic>>(
                    future: fetchNews(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No news available.'));
                      }

                      final news = snapshot.data!;
                      return Column(
                        children: news.map((article) {
                          return ItemNewsFeed(
                            title: article['title'] ?? 'No Title Available',
                            image: article['image_url'] ?? '',
                          );
                        }).toList(),
                      );
                    },
                  ),

                ],
              ),
            )
          ],
        ),
      );
    }
  }
