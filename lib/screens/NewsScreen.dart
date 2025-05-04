import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);

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
          return true;
        }).toList();
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Adjust for Sinhala if needed.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sri Lankan News'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<dynamic>>(
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
            return ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index) {
                final article = news[index];
                return ItemNewsFeed(
                  title: article['title'] ?? 'No Title Available',
                  image: article['image_url'] ?? '',
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ItemNewsFeed extends StatelessWidget {
  final String title, image;

  const ItemNewsFeed({
    Key? key,
    required this.title,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                image,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image)),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Iskoola Pota', // Set your Sinhala font family here.
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
