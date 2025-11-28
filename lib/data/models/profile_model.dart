class ProfileModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String? username;
  final String? bio;
  final String? avatarUrl;
  final DateTime birthDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? instagram;
  final String? twitter;
  final String? youtube;
  final String? tiktok;
  final String? website;
  final String? linkedin;

  ProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.username,
    this.bio,
    this.avatarUrl,
    required this.birthDate,
    this.createdAt,
    this.updatedAt,
    this.instagram,
    this.twitter,
    this.youtube,
    this.tiktok,
    this.website,
    this.linkedin,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['user_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      birthDate: DateTime.parse(json['birth_date'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      instagram: json['instagram'] as String?,
      twitter: json['twitter'] as String?,
      youtube: json['youtube'] as String?,
      tiktok: json['tiktok'] as String?,
      website: json['website'] as String?,
      linkedin: json['linkedin'] as String?,
    );
  }

  /// ProfileModel'i JSON'a çevirme (veritabanına kaydetmek için)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'bio': bio,
      'avatar_url': avatarUrl,
      'birth_date': birthDate.toIso8601String(),
      'instagram': instagram,
      'twitter': twitter,
      'youtube': youtube,
      'tiktok': tiktok,
      'website': website,
      'linkedin': linkedin,
    };
  }

  /// Tam isim (UI'da göstermek için)
  String get fullName => '$firstName $lastName';

  /// Yaş hesaplama
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  ProfileModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    DateTime? birthDate,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? instagram,
    String? twitter,
    String? youtube,
    String? tiktok,
    String? website,
    String? linkedin,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      instagram: instagram ?? this.instagram,
      twitter: twitter ?? this.twitter,
      youtube: youtube ?? this.youtube,
      tiktok: tiktok ?? this.tiktok,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
    );
  }

  @override
  String toString() {
    return 'ProfileModel(userId: $userId, fullName: $fullName, age: $age)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
