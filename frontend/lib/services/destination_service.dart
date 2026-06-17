import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/destination.dart';
import 'api_service.dart';

class DestinationRepository {
  static Future<List<Destination>> fetchDestinations({String? search, String? tag}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (tag != null && tag.isNotEmpty) params['tag'] = tag;

    final uri = Uri.parse('${ApiConfig.baseUrl}/destinations').replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) return [];

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.map((item) {
        if (item is Map<String, dynamic>) return Destination.fromJson(item);
        return Destination.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    }

    return [];
  }

  static Future<Destination?> fetchDestination(int id) async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/destinations/$id'));
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return Destination.fromJson(decoded);
    return null;
  }
}
