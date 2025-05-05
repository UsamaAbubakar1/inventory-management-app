import 'dart:async';

import 'package:get/get.dart';
import 'package:my_pos/service/firebase_service.dart';
import 'package:my_pos/service/product_model/product_model.dart';

class ProductController extends GetxController {
  var productList = <ProductModel>[].obs;
  var isLoading = true.obs;
  var searchQuery = ''.obs;

  final name = ''.obs;
  final costPrice = ''.obs;
  final sellPrice = ''.obs;
  final stock = ''.obs;
  final editingProductId = ''.obs;

  StreamSubscription? _productSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchProducts(); // Fetch products when controller is initialized
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }

  // Computed property for filtered products
  List<ProductModel> get filteredProductList {
    if (searchQuery.value.isEmpty) {
      return productList; // Return all if search is empty
    }

    final query = searchQuery.value.toLowerCase();

    return productList.where((product) {
      // Check if product name matches
      final productName = product.name.toLowerCase();
      return productName.contains(query);
    }).toList();
  }

  void fetchProducts() {
    isLoading.value = true;
    _productSubscription?.cancel(); // Cancel previous listener
    _productSubscription = FirebaseService.getProducts().listen((products) {
      productList.value = products;
      isLoading.value = false;
    }, onError: (error) {
      print("Error fetching products: $error");
      Get.snackbar("Error", "Could not load products.");
      isLoading.value = false;
    });
  }

  Future<void> addOrUpdateProduct() async {
    final product = ProductModel(
      id: editingProductId.value.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : editingProductId.value,
      name: name.value,
      costPrice: double.parse(costPrice.value),
      sellPrice: double.parse(sellPrice.value),
      stockQuantity: int.parse(stock.value),
    );

    if (editingProductId.value.isEmpty) {
      await FirebaseService.addProduct(product);
    } else {
      await FirebaseService.updateProduct(product);
    }

    clearFields();
  }

  void editProduct(ProductModel product) {
    name.value = product.name;
    costPrice.value = product.costPrice.toString();
    sellPrice.value = product.sellPrice.toString();
    stock.value = product.stockQuantity.toString();
    editingProductId.value = product.id;
  }

  void deleteProduct(String id) async {
    await FirebaseService.deleteProduct(id);
  }

  void clearFields() {
    name.value = '';
    costPrice.value = '';
    sellPrice.value = '';
    stock.value = '';
    editingProductId.value = '';
  }
}
