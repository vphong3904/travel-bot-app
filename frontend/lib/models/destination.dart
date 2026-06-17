class Destination {
  final int id;
  final String name;
  final String region;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final int budgetLow;
  final int budgetHigh;
  final String weather;
  final String bestSeason;
  final String cuisine;
  final String highlights;

  Destination({
    required this.id,
    required this.name,
    required this.region,
    required this.imageUrl,
    required this.description,
    required this.tags,
    required this.budgetLow,
    required this.budgetHigh,
    required this.weather,
    required this.bestSeason,
    required this.cuisine,
    required this.highlights,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final tags = <String>[];

    if (rawTags is String && rawTags.isNotEmpty) {
      tags.addAll(rawTags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty));
    } else if (rawTags is List) {
      tags.addAll(rawTags.map((tag) => tag.toString()));
    }

    return Destination(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tags: tags,
      budgetLow: json['budget_low'] is int ? json['budget_low'] as int : int.tryParse('${json['budget_low']}') ?? 0,
      budgetHigh: json['budget_high'] is int ? json['budget_high'] as int : int.tryParse('${json['budget_high']}') ?? 0,
      weather: json['weather']?.toString() ?? '',
      bestSeason: json['best_season']?.toString() ?? '',
      cuisine: json['cuisine']?.toString() ?? '',
      highlights: json['highlights']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'image_url': imageUrl,
      'description': description,
      'tags': tags,
      'budget_low': budgetLow,
      'budget_high': budgetHigh,
      'weather': weather,
      'best_season': bestSeason,
      'cuisine': cuisine,
      'highlights': highlights,
    };
  }
}
