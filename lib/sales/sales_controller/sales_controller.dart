import 'dart:async';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_pos/service/firebase_service.dart';
import 'package:my_pos/service/product_model/sale_model.dart';

class SalesController extends GetxController {
  var salesList = <SaleModel>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs; // State for the search query
  StreamSubscription? _salesSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchSales();
  }

  @override
  void onClose() {
    _salesSubscription?.cancel(); // Cancel subscription on close
    super.onClose();
  }

  // Computed property for filtered sales
  List<SaleModel> get filteredSalesList {
    if (searchQuery.value.isEmpty) {
      return salesList; // Return all if search is empty
    }

    final query = searchQuery.value.toLowerCase();
    final dateFormatter = DateFormat.yMMMd().add_jm(); // Consistent date format

    return salesList.where((sale) {
      // Check if date matches
      final formattedDate = dateFormatter.format(sale.date).toLowerCase();
      if (formattedDate.contains(query)) {
        return true;
      }

      // Check if any item name matches
      return sale.items.any((item) {
        final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
        return itemName.contains(query);
      });
    }).toList();
  }

  void fetchSales() {
    isLoading.value = true;
    //FirebaseService.getSales().listen((sales) {
    _salesSubscription?.cancel(); // Cancel previous listener
    _salesSubscription = FirebaseService.getSales().listen((sales) {
      salesList.value = sales;
      isLoading.value = false;
    }, onError: (error) {
      print("Error fetching sales: $error");
      Get.snackbar("Error", "Could not load sales history.");
      isLoading.value = false;
    });
  }
}
