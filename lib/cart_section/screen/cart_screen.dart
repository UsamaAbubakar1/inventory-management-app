import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pos/cart_section/cart_controller/cart_controller.dart';

class CartScreen extends StatelessWidget {
  final controller = Get.put(CartController());

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return Center(child: Text("Cart is empty"));
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                children: controller.cartItems.entries.map((entry) {
                  final item = entry.value;
                  return ListTile(
                    title: Text(item.product.name),
                    subtitle:
                        Text("${item.product.sellPrice} x ${item.quantity}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (item.quantity > 1) {
                              controller.updateQuantity(
                                  entry.key, item.quantity - 1);
                            } else {
                              controller.removeFromCart(entry.key);
                            }
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            controller.updateQuantity(
                                entry.key, item.quantity + 1);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Total: ${controller.total.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      // We'll hook this to checkout logic
                      controller.checkout();
                    },
                    child: Text("Checkout"),
                  ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }
}
