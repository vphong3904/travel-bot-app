// lib/admin/shared/providers/city_mapping_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/city_mapping_repository.dart';
import '../models/city_mapping_models.dart';

final cityMappingsProvider =
    FutureProvider.autoDispose<List<CityMapping>>((ref) async {
  return ref.watch(cityMappingRepositoryProvider).fetchValidate();
});

final validSlugsProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  return ref
      .watch(cityMappingRepositoryProvider)
      .fetchValidSlugs();
});
