class UserProfile {
  final String uid;
  final String? dob;
  final String? gender;
  final String? phone;
  final String? location;

  UserProfile({
    required this.uid,
    this.dob,
    this.gender,
    this.phone,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {'dob': dob, 'gender': gender, 'phone': phone, 'location': location};
  }

  factory UserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return UserProfile(
      uid: uid,
      dob: map['dob'],
      gender: map['gender'],
      phone: map['phone'],
      location: map['location'],
    );
  }
}
