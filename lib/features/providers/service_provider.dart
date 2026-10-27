class ServiceProvider {
  const ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.description,
    required this.price,
    required this.rating,
    required this.available,
    this.photoUrl = '',
    required String email,
  });

  final String id;
  final String name;
  final String service;
  final String description;
  final int price;
  final double rating;
  final bool available;
  final String photoUrl;

  factory ServiceProvider.fromMap(String id, Map<String, dynamic> data) {
    return ServiceProvider(
      id: id,
      name: data['name'] as String? ?? 'Service Provider',
      service: data['service'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toInt() ?? 0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      available: data['available'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String? ?? '',
      email: '',
    );
  }
}
