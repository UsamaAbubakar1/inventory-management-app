import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pos/cart_section/cart_controller/cart_controller.dart';
import 'package:my_pos/home/controller/product_controller.dart';
import 'package:my_pos/service/firebase_service.dart';

class ProductScreen extends StatelessWidget {
  final controller = Get.put(ProductController());
  final FirebaseService firebaseService = FirebaseService();
  ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products"),
        automaticallyImplyLeading: false,
        actions: [
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   tooltip: 'Logout',
          //   onPressed: () async {
          //     try {
          //       await FirebaseService.logout();
          //       // Reset bottom nav index if needed (optional)
          //       Get.find<BottomNavController>().currentIndex.value = 0;
          //       // Navigate to login and remove all previous routes
          //       Get.offAllNamed('/login');
          //     } catch (e) {
          //       Get.snackbar("Logout Failed", "An error occurred: $e",
          //           backgroundColor: Colors.red, colorText: Colors.white);
          //     }
          //   },
          // ),
        ],
        // Add other actions like cart icon if needed
        bottom: PreferredSize(
          // Add search bar here
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) =>
                  controller.searchQuery.value = value, // Update search query
              decoration: InputDecoration(
                hintText: 'Search products by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .scaffoldBackgroundColor
                    .withOpacity(0.8), // Adjust color
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 10,
        backgroundColor: Colors.blueAccent,
        onPressed: () => showProductForm(context),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        // if (controller.isLoading.value)
        //   return Center(child: CircularProgressIndicator());

        final displayedProducts = controller.filteredProductList;

        if (displayedProducts.isEmpty) {
          return Center(
            child: Text(controller.searchQuery.value.isEmpty
                ? 'No products added yet.'
                : 'No products found matching "${controller.searchQuery.value}".'),
          );
        }
        return ListView.builder(
            itemCount: displayedProducts.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final product = displayedProducts[index];
              return Container(
                height: 200, // Adjust height as needed
                margin: const EdgeInsets.only(
                    bottom: 16.0), // Spacing between cards
                clipBehavior:
                    Clip.antiAlias, // Ensures content respects border radius
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/main.jpg'), // Your background image
                    fit: BoxFit.cover,
                    // Add a color filter for better text visibility
                    //   colorFilter: ColorFilter.mode(
                    //       Colors.black.withOpacity(0.5), BlendMode.darken),
                    // ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          //color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActionButton(Icons.edit, Colors.blue, () {
                              controller.editProduct(product);
                              showProductForm(context);
                            }),
                            _buildActionButton(Icons.delete, Colors.red, () {
                              Get.defaultDialog(
                                  title: "Delete Product?",
                                  middleText:
                                      "Are you sure you want to delete ${product.name}?",
                                  textConfirm: "Delete",
                                  textCancel: "Cancel",
                                  buttonColor: Colors.red,
                                  onConfirm: () {
                                    controller.deleteProduct(product.id);
                                    Get.back(); // Close dialog
                                  });
                            }),
                            _buildActionButton(
                                Icons.shopping_cart, Colors.green, () {
                              final cart = Get.put(
                                  CartController()); // Use find if already put
                              cart.addToCart(product);
                              Get.snackbar(
                                "${product.name} Added",
                                "Added 1 unit to cart.",
                                snackPosition: SnackPosition.BOTTOM,
                                duration: Duration(seconds: 1),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    // Product Name and Details at Bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          "${product.name} (Stock: ${product.stockQuantity} | PKR ${product.sellPrice})",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
// Unchanged lines
            });
      }),
    );
  }
  //           return ListTile(
  //             title: Text(product.name),
  //             subtitle: Text(
  //                 'Stock: ${product.stockQuantity} | ₹${product.sellPrice}'),
  //             trailing: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 IconButton(
  //                     icon: Icon(Icons.edit),
  //                     onPressed: () {
  //                       controller.editProduct(product);
  //                       showProductForm(context);
  //                     }),
  //                 IconButton(
  //                     icon: Icon(Icons.delete),
  //                     onPressed: () {
  //                       // Optional: Show delete confirmation
  //                       Get.defaultDialog(
  //                           title: "Delete Product?",
  //                           middleText:
  //                               "Are you sure you want to delete ${product.name}?",
  //                           textConfirm: "Delete",
  //                           textCancel: "Cancel",
  //                           onConfirm: () {
  //                             controller.deleteProduct(product.id);
  //                             Get.back(); // Close dialog
  //                           });
  //                     }),
  //                 IconButton(
  //                   icon: Icon(Icons.shopping_cart),
  //                   onPressed: () {
  //                     final cart = Get.put(CartController());
  //                     cart.addToCart(product);
  //                     Get.snackbar(
  //                       "${product.name} Added",
  //                       "Added 1 unit to cart.",
  //                       snackPosition: SnackPosition.BOTTOM,
  //                       duration: Duration(seconds: 1),
  //                     );
  //                   },
  //                 )
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     }),
  //   );
  // }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(40),
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 20),
          constraints: BoxConstraints(), // Remove default padding
          padding: EdgeInsets.symmetric(horizontal: 6),
          visualDensity: VisualDensity.compact,
          tooltip: icon == Icons.edit
              ? 'Edit'
              : (icon == Icons.delete ? 'Delete' : 'Add to Cart'),
          splashRadius: 20,
          onPressed: onPressed,
        ),
      ),
    );
  }

  void showProductForm(BuildContext context) {
    final nameCtrl = TextEditingController(text: controller.name.value);
    final costCtrl = TextEditingController(text: controller.costPrice.value);
    final sellCtrl = TextEditingController(text: controller.sellPrice.value);
    final stockCtrl = TextEditingController(text: controller.stock.value);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(labelText: 'Product Name'),
              onChanged: (val) => controller.name.value = val,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costCtrl,
              decoration: InputDecoration(labelText: 'Cost Price'),
              keyboardType: TextInputType.number,
              onChanged: (val) => controller.costPrice.value = val,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: sellCtrl,
              decoration: InputDecoration(labelText: 'Sell Price'),
              keyboardType: TextInputType.number,
              onChanged: (val) => controller.sellPrice.value = val,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: stockCtrl,
              decoration: InputDecoration(labelText: 'Stock Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (val) => controller.stock.value = val,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                controller.addOrUpdateProduct();
                Get.back();
              },
              child: Text(controller.editingProductId.value.isEmpty
                  ? "Add Product"
                  : "Update Product"),
            ),
          ],
        ),
      ),
    );
  }
}
