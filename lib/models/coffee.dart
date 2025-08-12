import 'package:cloud_firestore/cloud_firestore.dart';

class Coffee {
  final int id;
  final String name;
  final String description;
  final String image;
  final List<String> ingredients;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.ingredients,
  });

  factory Coffee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Coffee(
      id: data['id'] ?? 0,
      name: data['name'] ?? 'Coffee',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
    );
  }
}
