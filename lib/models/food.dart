class Food {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final int reviewCount;
  final String description;
  final String categoryId;

  const Food({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.categoryId,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      reviewCount: json['review_count'] ?? 0,
      description: json['description'] ?? '',
      categoryId: json['category_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'rating': rating,
      'review_count': reviewCount,
      'description': description,
      'category_id': categoryId,
    };
  }
}
