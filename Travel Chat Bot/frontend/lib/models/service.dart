class Service {
  final int id;
  final String name;
  final String type; // 'hotel', 'tour', 'ticket'
  final String description;
  final double rating;
  final int reviews;
  final String location;
  final double price;
  final String? imageUrl;
  final String? contact;
  final String? website;

  Service({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.rating,
    required this.reviews,
    required this.location,
    required this.price,
    this.imageUrl,
    this.contact,
    this.website,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'service',
      description: json['description']?.toString() ?? '',
      rating: json['rating'] is num ? (json['rating'] as num).toDouble() : 0.0,
      reviews: json['reviews'] is int ? json['reviews'] : int.tryParse('${json['reviews']}') ?? 0,
      location: json['location']?.toString() ?? '',
      price: json['price'] is num ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: json['image_url']?.toString(),
      contact: json['contact']?.toString(),
      website: json['website']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'rating': rating,
      'reviews': reviews,
      'location': location,
      'price': price,
      'image_url': imageUrl,
      'contact': contact,
      'website': website,
    };
  }
}
