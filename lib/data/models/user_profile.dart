// ============================================================
//  USER PROFILE — Login kiye hue student ki details
//
//  Backend ke users table ke saath match karta hai:
//   id, full_name, email, phone, college_name
// ============================================================

class UserProfile {
  final int id;           // Database users.id
  final String phone;
  final String name;      // full_name
  final String email;
  final String college;   // college_name
  final String city;
  final String? avatarUrl; // profile_pic URL (server se)

  const UserProfile({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.college,
    required this.city,
    this.avatarUrl,
  });

  /// Server se aaye JSON se banana
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: (json['id'] as num?)?.toInt() ?? 0,
        phone: (json['phone'] as String?) ?? '',
        name: (json['full_name'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        college: (json['college_name'] as String?) ?? '',
        city: '',
        avatarUrl: json['avatar_url'] as String?,
      );

  /// SharedPreferences ke liye flat Map
  Map<String, dynamic> toPrefsMap() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'college': college,
        'city': city,
        'avatarUrl': avatarUrl ?? '',
      };

  factory UserProfile.fromPrefsMap(Map<String, dynamic> m) => UserProfile(
        id: (m['id'] as int?) ?? 0,
        phone: (m['phone'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        college: (m['college'] as String?) ?? '',
        city: (m['city'] as String?) ?? '',
        avatarUrl: (m['avatarUrl'] as String?)?.isEmpty == true
            ? null
            : m['avatarUrl'] as String?,
      );

  /// "Rahul Kumar" → "Rahul"
  String get firstName {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return 'Student';
    return trimmed.split(' ').first;
  }

  /// "Rahul Kumar" → "RK" (profile photo ki jagah)
  String get initials {
    final List<String> parts =
        name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  /// Profile setup poora hua ya nahi
  bool get isComplete => name.trim().isNotEmpty;

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? college,
    String? city,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
