import 'package:get/get.dart';

class BottomNavController extends GetxController {
  // Current tab index
  var currentIndex = 0.obs;

  // List of routes corresponding to each tab
  final tabs = [
    '/product', // Index 0
    '/cart', // Index 1 (Matches CartScreen route name)
    '/sale', // Index 2 (Matches SalesHistoryScreen route name)
    '/profitloss', // Index 3 (Matches ProfitLossScreen route name)
    '/ai',
  ];

  // Change tab and navigate
  void changeTab(int index) {
    currentIndex.value = index;
    Get.offNamed(tabs[index], id: 1);
  }
}
