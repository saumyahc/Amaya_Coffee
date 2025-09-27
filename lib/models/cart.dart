import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartItem {
  final int id;
  final String name;
  final String image;
  final double price;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.qty = 1,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'image': image, 'price': price, 'qty': qty};
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      qty: map['qty'] ?? 1,
    );
  }
}

class CartModel extends ChangeNotifier {
  final Map<int, CartItem> _items = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  List<CartItem> get items => _items.values.toList(growable: false);
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.qty);
  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + (item.price * item.qty));
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _isLoading;

  // Initialize cart from Firestore
  Future<void> loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final cartDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      _items.clear();
      for (var doc in cartDoc.docs) {
        final cartItem = CartItem.fromMap(doc.data());
        _items[cartItem.id] = cartItem;
      }

      print('Cart loaded successfully: ${_items.length} items');
    } catch (e) {
      print('Error loading cart: $e');
      // Cart loading failed, but don't show error to user
      // Items will remain empty and user can add new items
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save cart to Firestore
  Future<void> _saveCartToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userCartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');

      // Clear existing cart items
      final existingItems = await userCartRef.get();
      for (var doc in existingItems.docs) {
        await doc.reference.delete();
      }

      // Add current cart items
      for (var item in _items.values) {
        await userCartRef.add(item.toMap());
      }
    } catch (e) {
      print('Error saving cart: $e');
      // You could add a retry mechanism or user notification here
    }
  }

  void add(int id, String name, String image, double price) {
    final existing = _items[id];
    if (existing != null) {
      existing.qty += 1;
    } else {
      _items[id] = CartItem(id: id, name: name, image: image, price: price);
    }
    notifyListeners();
    _saveCartToFirestore();
  }

  void increment(int id) {
    final item = _items[id];
    if (item != null) {
      item.qty += 1;
      notifyListeners();
      _saveCartToFirestore();
    }
  }

  void decrement(int id) {
    final item = _items[id];
    if (item == null) return;
    if (item.qty > 1) {
      item.qty -= 1;
    } else {
      _items.remove(id);
    }
    notifyListeners();
    _saveCartToFirestore();
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
    _saveCartToFirestore();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveCartToFirestore();
  }

  // Don't clear cart on logout - keep it for when user returns
  void clearOnLogout() {
    // Only clear local cart, keep Firestore data
    _items.clear();
    notifyListeners();
  }
}
