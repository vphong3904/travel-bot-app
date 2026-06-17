class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class Destination {
  final String id;
  final String name;
  final String region;
  final String imageUrl;
  final String description;
  final List<String> tags;
  final List<Category> categories;
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
    required this.categories,
    required this.budgetLow,
    required this.budgetHigh,
    required this.weather,
    required this.bestSeason,
    required this.cuisine,
    required this.highlights,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    final categories = <Category>[];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map<String, dynamic>) {
          categories.add(Category.fromJson(item));
        } else if (item is Map) {
          categories.add(Category.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final rawTags = json['tags'];
    final tags = <String>[];
    if (rawTags is String && rawTags.isNotEmpty) {
      tags.addAll(rawTags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty));
    } else if (rawTags is List) {
      tags.addAll(rawTags.map((tag) => tag.toString()));
    }
    if (tags.isEmpty) {
      tags.addAll(categories.map((category) => category.name));
    }

    return Destination(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      region: json['region']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      tags: tags,
      categories: categories,
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
      'categories': categories.map((c) => {
            'id': c.id,
            'name': c.name,
            'slug': c.slug,
            'icon': c.icon,
            'description': c.description,
          }).toList(),
      'budget_low': budgetLow,
      'budget_high': budgetHigh,
      'weather': weather,
      'best_season': bestSeason,
      'cuisine': cuisine,
      'highlights': highlights,
    };
  }
}
