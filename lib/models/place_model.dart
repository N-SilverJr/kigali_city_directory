import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String id;
  final String name;
  final String description;
  final String category;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> tags;
  final bool isFeatured;
  final DateTime createdAt;
  final String createdBy;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.tags = const [],
    this.isFeatured = false,
    required this.createdAt,
    required this.createdBy,
  });

  factory Place.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Place(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      website: data['website'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      imageUrl: data['imageUrl'],
      tags: List<String>.from(data['tags'] ?? []),
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'tags': tags,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  Place copyWith({
    String? name,
    String? description,
    String? category,
    String? address,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? tags,
    bool? isFeatured,
  }) {
    return Place(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

class PlaceCategory {
  static const String hospital = 'Hospital';
  static const String policeStation = 'Police Station';
  static const String publicLibrary = 'Public Library';
  static const String restaurant = 'Restaurant';
  static const String cafe = 'Cafe';
  static const String park = 'Park';
  static const String touristAttraction = 'Tourist Attraction';
  static const String government = 'Government';
  static const String bank = 'Bank';
  static const String utility = 'Utility Office';
  static const String shopping = 'Shopping';
  static const String hotel = 'Hotel';
  static const String entertainment = 'Entertainment';
  static const String healthcare = 'Healthcare';
  static const String education = 'Education';
  static const String transport = 'Transport';
  static const String other = 'Other';

  static List<String> get all => [
        hospital,
        policeStation,
        publicLibrary,
        restaurant,
        cafe,
        park,
        touristAttraction,
        government,
        bank,
        utility,
        shopping,
        hotel,
        entertainment,
        healthcare,
        education,
        transport,
        other,
      ];
}
