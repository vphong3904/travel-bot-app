// lib/admin/shared/models/system_config.dart

class SystemConfig {
  final String key;
  final dynamic value;
  final String? description;
  final String? updatedAt;

  const SystemConfig({
    required this.key,
    required this.value,
    this.description,
    this.updatedAt,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> j) =>
      SystemConfig(
        key: j['key'] as String,
        value: j['value'],
        description: j['description'] as String?,
        updatedAt: j['updated_at'] as String?,
      );

  bool get boolValue {
    if (value is bool) return value as bool;
    if (value is String) return value == 'true';
    return false;
  }

  double get doubleValue {
    if (value is num) return (value as num).toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  int get intValue {
    if (value is int) return value as int;
    return int.tryParse(value.toString()) ?? 0;
  }
}
