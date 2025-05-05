import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pos/service/firebase_service.dart';
import 'package:my_pos/service/product_model/product_model.dart';
import 'package:my_pos/service/product_model/sale_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartController extends GetxController {
  var cartItems = <String, CartItem>{}.obs;

  void addToCart(ProductModel product) {
    if (cartItems.containsKey(product.id)) {
      cartItems[product.id]!.quantity++;
    } else {
      cartItems[product.id] = CartItem(product: product, quantity: 1);
    }
    cartItems.refresh();
  }

  void removeFromCart(String productId) {
    cartItems.remove(productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (cartItems.containsKey(productId)) {
      cartItems[productId]!.quantity = quantity;
      cartItems.refresh();
    }
  }

  double get total {
    return cartItems.values
        .fold(0, (sum, item) => sum + item.product.sellPrice * item.quantity);
  }

  void clearCart() {
    cartItems.clear();
  }

  Future<void> checkout() async {
    // Check if cart is empty before proceeding
    if (cartItems.isEmpty) {
      Get.snackbar("Checkout Failed", "Your cart is empty.",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return; // Stop execution if cart is empty
    }

    try {
      // 1. Deduct stock for each item
      for (var item in cartItems.values) {
        // Input validation for quantity (optional but good practice)
        if (item.quantity <= 0) {
          throw Exception("Invalid quantity for ${item.product.name}");
        }
        await FirebaseService.deductStock(item.product.id, item.quantity);
      }

      // 2. Prepare the SaleModel
      final sale = SaleModel(
        // Use a more robust ID generation if needed (e.g., UUID)
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(), // Use a consistent timestamp
        totalAmount: total, // Use the calculated total
        items: cartItems.values
            .map((e) => {
                  'productId': e.product.id,
                  'name': e.product.name, // Store name at time of sale
                  'quantity': e.quantity,
                  'costPrice':
                      e.product.costPrice, // Store cost at time of sale
                  'price': e.product.sellPrice, // Store price at time of sale
                  'subtotal': e.quantity * e.product.sellPrice,
                  'profit':
                      (e.product.sellPrice - e.product.costPrice) * e.quantity,
                })
            .toList(),
      );

      await FirebaseService.recordSale(sale);

      clearCart();
      Get.snackbar("Checkout Success", "Sale recorded & stock updated");
    } catch (e) {
      Get.snackbar("Checkout Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
