import 'package:flutter/foundation.dart';

class CartItem {
  final int id;
  final String name;
  final String image;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    this.qty = 1,
  });
}

class CartModel extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList(growable: false);
  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.qty);
  bool get isEmpty => _items.isEmpty;

  void add(int id, String name, String image) {
    final existing = _items[id];
    if (existing != null) {
      existing.qty += 1;
    } else {
      _items[id] = CartItem(id: id, name: name, image: image);
    }
    notifyListeners();
  }

  void increment(int id) {
    final item = _items[id];
    if (item != null) {
      item.qty += 1;
      notifyListeners();
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
  }

  void remove(int id) {
    _items.remove(id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
