import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/service.dart';
import 'api_service.dart';

class ServiceRepository {
  static Future<List<Service>> searchServices({
    String q = '',
    String? type,
    String? destination,
  }) async {
    final params = <String, String>{'q': q};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (destination != null && destination.isNotEmpty) params['destination'] = destination;

    // Backend route is /search, not /services/search
    final uri = Uri.parse('${ApiConfig.baseUrl}/search').replace(queryParameters: params);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      final services = <Service>[];

      // Parse hotels from search results
      if (decoded['hotels'] is List) {
        services.addAll((decoded['hotels'] as List).map((item) {
          if (item is Map<String, dynamic>) return Service.fromJson({...item, 'type': 'hotel'});
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'hotel'});
        }));
      }

      // Parse tours from search results
      if (decoded['tours'] is List) {
        services.addAll((decoded['tours'] as List).map((item) {
          if (item is Map<String, dynamic>) return Service.fromJson({...item, 'type': 'tour'});
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'tour'});
        }));
      }

      // Parse destinations as services
      if (decoded['destinations'] is List) {
        services.addAll((decoded['destinations'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return Service.fromJson({
              'id': item['id'],
              'name': item['name'],
              'type': 'destination',
              'description': item['region'] ?? '',
              'location': item['province'] ?? '',
              'rating': 4.5,
              'reviews': 0,
              'price': 0,
            });
          }
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'destination'});
        }));
      }

      return services;
    } catch (e) {
      return [];
    }
  }
}
