import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatelessWidget {
  final String identifier;

  DetailsPage({required this.identifier});

  Future<Map> _fetchDetails() async {
    final response = await http.get(Uri.parse('https://archive.org/metadata/$identifier'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: FutureBuilder<Map>(
        future: _fetchDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final details = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details['metadata']['title'] ?? 'No title',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(details['metadata']['description'] ?? 'No description'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final url = 'https://archive.org/download/${details['metadata']['identifier']}';
                      launch(url);
                    },
                    child: Text('Download/Watch'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
