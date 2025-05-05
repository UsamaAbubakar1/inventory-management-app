import 'dart:async';

import 'package:get/get.dart';
import 'package:my_pos/service/firebase_service.dart';
import 'package:my_pos/service/product_model/sale_model.dart';

class ProfitLossController extends GetxController {
  var sales = <SaleModel>[].obs;
  var totalRevenue = 0.0.obs;
  var totalCost = 0.0.obs;
  var totalProfit = 0.0.obs;
  // Date filtering state
  var startDate = Rxn<DateTime>(); // Rxn allows null values
  var endDate = Rxn<DateTime>();

  StreamSubscription? _salesSubscription;

  // Computed property for filtered sales
  List<SaleModel> get filteredSales {
    DateTime? start = startDate.value;
    // Adjust end date to include the entire selected day
    DateTime? end = endDate.value != null
        ? DateTime(endDate.value!.year, endDate.value!.month,
            endDate.value!.day, 23, 59, 59)
        : null;

    return sales.where((sale) {
      final saleDate = sale.date;
      final afterStartDate = start == null ||
          saleDate.isAfter(start) ||
          saleDate.isAtSameMomentAs(start);
      final beforeEndDate = end == null ||
          saleDate.isBefore(end) ||
          saleDate.isAtSameMomentAs(end);
      return afterStartDate && beforeEndDate;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    // Recalculate totals whenever sales, startDate, or endDate change
    ever(sales, (_) => _calculateTotals());
    ever(startDate, (_) => _calculateTotals());
    ever(endDate, (_) => _calculateTotals());
    loadProfitData(); // Load initial sales data
  }

  @override
  void onClose() {
    _salesSubscription
        ?.cancel(); // Cancel subscription when controller is closed
    super.onClose();
  }

  void loadProfitData() {
    _salesSubscription?.cancel(); // Cancel previous subscription if any
    _salesSubscription = FirebaseService.getSales().listen((fetchedSales) {
      sales.value =
          fetchedSales; // This will trigger the 'ever' listener for sales
      // Initial calculation is handled by the 'ever' listener now
    }, onError: (error) {
      // Handle potential errors fetching data
      print("Error fetching sales: $error");
      Get.snackbar("Error", "Could not load sales data.");
      sales.value = []; // Clear sales on error
    });
  }

  // Recalculates totals based on the current filteredSales list
  void _calculateTotals() {
    double revenue = 0;
    double cost = 0;

    for (var sale in filteredSales) {
      // Use filteredSales here
      for (var item in sale.items) {
        final quantity = item['quantity'] ?? 0;
        final sellPrice = item['price'] ?? 0;
        final costPrice = item['costPrice'] ?? 0;
        revenue += sellPrice * quantity;
        cost += costPrice * quantity;
      }
    }

    totalRevenue.value = revenue;
    totalCost.value = cost;
    totalProfit.value = revenue - cost;
  }

  void setStartDate(DateTime? date) {
    startDate.value = date;
  }

  void setEndDate(DateTime? date) {
    endDate.value = date;
  }
}


  // void loadProfitData() {
  //   FirebaseService.getSales().listen((fetchedSales) {
  //     sales.value = fetchedSales;

  //     double revenue = 0;
  //     double cost = 0;

  //     for (var sale in fetchedSales) {
  //       for (var item in sale.items) {
  //         final quantity = item['quantity'] ?? 0;
  //         final sellPrice = item['price'] ?? 0;
  //         final costPrice = item['costPrice'] ?? 0;

  //         revenue += sellPrice * quantity;
  //         cost += costPrice * quantity;
  //       }
  //     }

  //     totalRevenue.value = revenue;
  //     totalCost.value = cost;
  //     totalProfit.value = revenue - cost;
  //   });
  // }

