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

    final uri = Uri.parse('${ApiConfig.baseUrl}/services/search').replace(queryParameters: params);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final decoded = jsonDecode(response.body);
      final services = <Service>[];

      // Parse hotels
      if (decoded['hotels'] is List) {
        services.addAll((decoded['hotels'] as List).map((item) {
          if (item is Map<String, dynamic>) return Service.fromJson({...item, 'type': 'hotel'});
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'hotel'});
        }));
      }

      // Parse tours
      if (decoded['tours'] is List) {
        services.addAll((decoded['tours'] as List).map((item) {
          if (item is Map<String, dynamic>) return Service.fromJson({...item, 'type': 'tour'});
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'tour'});
        }));
      }

      // Parse tickets
      if (decoded['tickets'] is List) {
        services.addAll((decoded['tickets'] as List).map((item) {
          if (item is Map<String, dynamic>) return Service.fromJson({...item, 'type': 'ticket'});
          return Service.fromJson({...Map<String, dynamic>.from(item), 'type': 'ticket'});
        }));
      }

      return services;
    } catch (e) {
      return [];
    }
  }
}
