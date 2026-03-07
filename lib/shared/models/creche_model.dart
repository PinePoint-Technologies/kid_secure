import 'package:cloud_firestore/cloud_firestore.dart';

class CrecheModel {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? province;
  final String? postalCode;
  final String? country;
  final String? phoneNumber;
  final String? email;
  final String? logoUrl;
  final String? bannerUrl;
  final String? registrationNumber;
  final List<String> teacherIds;
  final int capacity;
  final bool isActive;
  final Map<String, dynamic>? branding; // white-label support
  final DateTime createdAt;
  final DateTime? updatedAt;
  // GPS geofence center
  final double? latitude;
  final double? longitude;
  final double geofenceRadiusMeters;

  const CrecheModel({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.province,
    this.postalCode,
    this.country = 'South Africa',
    this.phoneNumber,
    this.email,
    this.logoUrl,
    this.bannerUrl,
    this.registrationNumber,
    this.teacherIds = const [],
    this.capacity = 30,
    this.isActive = true,
    this.branding,
    required this.createdAt,
    this.updatedAt,
    this.latitude,
    this.longitude,
    this.geofenceRadiusMeters = 200,
  });

  factory CrecheModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CrecheModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String?,
      province: data['province'] as String?,
      postalCode: data['postalCode'] as String?,
      country: data['country'] as String? ?? 'South Africa',
      phoneNumber: data['phoneNumber'] as String?,
      email: data['email'] as String?,
      logoUrl: data['logoUrl'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      registrationNumber: data['registrationNumber'] as String?,
      teacherIds: List<String>.from(data['teacherIds'] as List? ?? []),
      capacity: data['capacity'] as int? ?? 30,
      isActive: data['isActive'] as bool? ?? true,
      branding: data['branding'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      geofenceRadiusMeters:
          (data['geofenceRadiusMeters'] as num?)?.toDouble() ?? 200,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'address': address,
        'city': city,
        'province': province,
        'postalCode': postalCode,
        'country': country,
        'phoneNumber': phoneNumber,
        'email': email,
        'logoUrl': logoUrl,
        'bannerUrl': bannerUrl,
        'registrationNumber': registrationNumber,
        'teacherIds': teacherIds,
        'capacity': capacity,
        'isActive': isActive,
        'branding': branding,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
        'latitude': latitude,
        'longitude': longitude,
        'geofenceRadiusMeters': geofenceRadiusMeters,
      };

  CrecheModel copyWith({
    String? name,
    String? address,
    String? city,
    String? province,
    String? postalCode,
    String? phoneNumber,
    String? email,
    String? logoUrl,
    String? bannerUrl,
    String? registrationNumber,
    List<String>? teacherIds,
    int? capacity,
    bool? isActive,
    Map<String, dynamic>? branding,
    double? latitude,
    double? longitude,
    double? geofenceRadiusMeters,
  }) =>
      CrecheModel(
        id: id,
        name: name ?? this.name,
        address: address ?? this.address,
        city: city ?? this.city,
        province: province ?? this.province,
        postalCode: postalCode ?? this.postalCode,
        country: country,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        logoUrl: logoUrl ?? this.logoUrl,
        bannerUrl: bannerUrl ?? this.bannerUrl,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        teacherIds: teacherIds ?? this.teacherIds,
        capacity: capacity ?? this.capacity,
        isActive: isActive ?? this.isActive,
        branding: branding ?? this.branding,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        geofenceRadiusMeters: geofenceRadiusMeters ?? this.geofenceRadiusMeters,
      );

  String get fullAddress =>
      [address, city, province, postalCode, country]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
}
