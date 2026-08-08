class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String city;
  final String street;
  final String zipCode;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.city,
    required this.street,
    required this.zipCode,
  });

  String get fullName {
    final nameParts =
        [firstName.trim(), lastName.trim()].where((part) => part.isNotEmpty);
    return nameParts.join(' ').trim();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final nameJson = json['name'] as Map<String, dynamic>?;
    final addressJson = json['address'] as Map<String, dynamic>?;

    return User(
      id: json['id'] as int,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      firstName: nameJson?['firstname'] as String? ?? '',
      lastName: nameJson?['lastname'] as String? ?? '',
      city: addressJson?['city'] as String? ?? '',
      street: addressJson?['street'] as String? ?? '',
      zipCode: addressJson?['zipcode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'name': {
        'firstname': firstName,
        'lastname': lastName,
      },
      'address': {
        'city': city,
        'street': street,
        'zipcode': zipCode,
      },
    };
  }
}
