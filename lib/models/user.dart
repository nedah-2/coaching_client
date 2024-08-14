import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String email;
  String phone;
  String age;
  String gender;
  String country;
  String goal;
  String submission;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.country,
    required this.goal,
    required this.submission,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      age: data['age'] ?? '',
      gender: data['gender'] ?? '',
      country: data['country'] ?? '',
      goal: data['goal'] ?? '',
      submission: data['submission'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'country': country,
      'goal': goal,
      'submission': submission,
    };
  }
}
