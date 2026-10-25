// ============================================================
//  USER PROFILE — Login kiye hue student ki details
// ============================================================

class UserProfile {
  final String phone;
  final String name;
  final String email;
  final String college;
  final String city;

  const UserProfile({
    required this.phone,
    required this.name,
    required this.email,
    required this.college,
    required this.city,
  });

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

  UserProfile copyWith({String? name, String? email, String? college, String? city}) {
    return UserProfile(
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      college: college ?? this.college,
      city: city ?? this.city,
    );
  }
}
