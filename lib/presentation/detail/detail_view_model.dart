import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../utils/constants.dart';

class DetailViewModel extends ChangeNotifier {

  Future<List<Map<String, String>>> fetchGoogleImages(String query) async {
    const String apiKey = Constants.cseApiKey;
    const String cx = Constants.cseId;
    const int numOfImgs = Constants.numOfImgsPlus;

    final Uri url = Uri.parse(
      'https://www.googleapis.com/customsearch/v1?q=$query&cx=$cx&searchType=image&num=$numOfImgs&key=$apiKey',
    );

    try {
      final response = await http.get(url);
      print("Google API Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];

        final List<Map<String, String>> results = [];

        for (var item in data['items']) {
          results.add({
            'imageUrl': item['link'] ?? '',
            'productUrl': item['image']['contextLink'] ?? '',
          });
        }

        return results;
      } else {
        print('Google Search API Error: ${response.body}');
        return []; // ← Don't throw, just return an empty list
      }
    } catch (e) {
      print('Exception in fetchGoogleImages: $e');
      return []; // ← Same here
    }
  }
}
