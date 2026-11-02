import 'package:flutter/foundation.dart';

import '../models/menu_item.dart';

class CartItem {
  final MenuItem item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  int get priceNumeric {
    final clean = item.price.replaceAll(RegExp(r'[^\d]'), '');
    return int.tryParse(clean) ?? 0;
  }

  int get subtotal => priceNumeric * quantity;
}

class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get totalCount => _items.values.fold(0, (sum, i) => sum + i.quantity);

  int get totalPrice => _items.values.fold(0, (sum, i) => sum + i.subtotal);

  int getQuantity(String itemName) => _items[itemName]?.quantity ?? 0;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  // ---------- CRUD OPERATIONS ----------

  // Create / Add item
  void addItem(MenuItem item) {
    if (_items.containsKey(item.name)) {
      _items[item.name]!.quantity++;
    } else {
      _items[item.name] = CartItem(item: item, quantity: 1);
    }
    notifyListeners();
  }

  // Update / Decrease item
  void decreaseItem(MenuItem item) {
    if (!_items.containsKey(item.name)) return;
    if (_items[item.name]!.quantity > 1) {
      _items[item.name]!.quantity--;
    } else {
      _items.remove(item.name);
    }
    notifyListeners();
  }

  // Update / Set exact quantity
  void setQuantity(MenuItem item, int qty) {
    if (qty <= 0) {
      _items.remove(item.name);
    } else {
      if (_items.containsKey(item.name)) {
        _items[item.name]!.quantity = qty;
      } else {
        _items[item.name] = CartItem(item: item, quantity: qty);
      }
    }
    notifyListeners();
  }

  // Delete / Remove specific item
  void removeItem(String itemName) {
    _items.remove(itemName);
    notifyListeners();
  }

  // Delete / Clear all
  void clear() {
    _items.clear();
    notifyListeners();
  }

  // Konversi ke format string untuk field List Menu
  // Contoh: "Chicken Skin (2x), Es Teh (3x)"
  String toSummaryString() {
    if (_items.isEmpty) return '';
    return _items.values
        .map((e) => '${e.item.name} (${e.quantity}x)')
        .join(', ');
  }
}
