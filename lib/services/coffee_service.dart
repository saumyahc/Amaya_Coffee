import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coffee.dart';

class CoffeeService {
  CoffeeService(this._firestore);
  final FirebaseFirestore _firestore;

  Stream<List<Coffee>> coffeesStream() {
    return _firestore
        .collection('coffees')
        .orderBy('id')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Coffee.fromFirestore).toList());
  }
}
