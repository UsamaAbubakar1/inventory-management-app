import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:my_pos/home/controller/bnav_controller.dart';

class BottomNavBar extends StatelessWidget {
  final controller = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey.withAlpha(100),
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Iconsax.box_add), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Iconsax.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(
              icon: Icon(Iconsax.money_recive), label: 'Sales'),
          BottomNavigationBarItem(
              icon: Icon(Icons.show_chart), label: 'Profit'),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline_sharp), label: 'AI'),
        ],
      );
    });
  }
}
