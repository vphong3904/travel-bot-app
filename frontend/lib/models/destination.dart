// lib/models/destination.dart

class Category {
  final String id;
  final String name;
  final String slug;
  final String? icon;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        slug: j['slug']?.toString() ?? '',
        icon: j['icon']?.toString(),
        description: j['description']?.toString(),
      );
}

class Destination {
  final String id;
  final String name;
  final String? province;
  final String region;
  final String imageUrl;
  final String description;
  final List<Category> categories;
  final int budgetLow;
  final int budgetHigh;
  final String weather;
  final String bestSeason;
  final List<int> bestMonths;
  final String cuisine;
  final String special;    // từ backend — điểm đặc sắc
  final double ratingAvg;
  final int reviewCount;
  final int favoriteCount;
  final int viewCount;

  const Destination({
    required this.id,
    required this.name,
    this.province,
    required this.region,
    required this.imageUrl,
    required this.description,
    required this.categories,
    required this.budgetLow,
    required this.budgetHigh,
    required this.weather,
    required this.bestSeason,
    required this.bestMonths,
    required this.cuisine,
    required this.special,
    required this.ratingAvg,
    required this.reviewCount,
    required this.favoriteCount,
    required this.viewCount,
  });

  // Alias cho backward-compat với code cũ dùng .highlights / .tags
  String get highlights => special;
  List<String> get tags => categories.map((c) => c.name).toList();

  factory Destination.fromJson(Map<String, dynamic> j) {
    final rawCats = j['categories'];
    final cats = <Category>[];
    if (rawCats is List) {
      for (final item in rawCats) {
        if (item is Map) cats.add(Category.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    final rawMonths = j['best_months'];
    final months = <int>[];
    if (rawMonths is List) {
      for (final m in rawMonths) {
        if (m is int) months.add(m);
        else if (m != null) months.add(int.tryParse('$m') ?? 0);
      }
    }

    int parseInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;
    double parseDbl(dynamic v) => v == null ? 0.0 : double.tryParse('$v') ?? 0.0;

    return Destination(
      id: j['id']?.toString() ?? '',
      name: j['name']?.toString() ?? '',
      province: j['province']?.toString(),
      region: j['region']?.toString() ?? '',
      imageUrl: j['image_url']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      categories: cats,
      budgetLow: parseInt(j['budget_low']),
      budgetHigh: parseInt(j['budget_high']),
      weather: j['weather']?.toString() ?? '',
      bestSeason: j['best_season']?.toString() ?? '',
      bestMonths: months,
      cuisine: j['cuisine']?.toString() ?? '',
      special: j['special']?.toString() ?? j['highlights']?.toString() ?? '',
      ratingAvg: parseDbl(j['rating_avg']),
      reviewCount: parseInt(j['review_count']),
      favoriteCount: parseInt(j['favorite_count']),
      viewCount: parseInt(j['view_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'province': province,
        'region': region,
        'image_url': imageUrl,
        'description': description,
        'categories': categories.map((c) => {'id': c.id, 'name': c.name, 'slug': c.slug}).toList(),
        'budget_low': budgetLow,
        'budget_high': budgetHigh,
        'weather': weather,
        'best_season': bestSeason,
        'best_months': bestMonths,
        'cuisine': cuisine,
        'special': special,
        'rating_avg': ratingAvg,
        'review_count': reviewCount,
        'favorite_count': favoriteCount,
        'view_count': viewCount,
      };

  Destination copyWith({int? viewCount, int? favoriteCount, int? reviewCount, double? ratingAvg}) =>
      Destination(
        id: id, name: name, province: province, region: region,
        imageUrl: imageUrl, description: description, categories: categories,
        budgetLow: budgetLow, budgetHigh: budgetHigh, weather: weather,
        bestSeason: bestSeason, bestMonths: bestMonths, cuisine: cuisine, special: special,
        ratingAvg: ratingAvg ?? this.ratingAvg,
        reviewCount: reviewCount ?? this.reviewCount,
        favoriteCount: favoriteCount ?? this.favoriteCount,
        viewCount: viewCount ?? this.viewCount,
      );
}
