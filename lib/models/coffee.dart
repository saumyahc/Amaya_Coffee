import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'coffee.g.dart';

@HiveType(typeId: 0)
class Coffee extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String image;
  @HiveField(4)
  final List<String> ingredients;
  @HiveField(5)
  final double price;

  Coffee({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.ingredients,
    required this.price,
  });

  factory Coffee.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Coffee(
      id: data['id'] ?? 0,
      // Firestore uses 'title' for the coffee name in this project.
      // Fall back to 'name' if present to remain backward compatible.
      name: (data['title'] ?? data['name'] ?? 'Coffee') as String,
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      ingredients: List<String>.from(data['ingredients'] ?? []),
      price: (data['price'] ?? 0.0).toDouble(),
    );
  }
}
