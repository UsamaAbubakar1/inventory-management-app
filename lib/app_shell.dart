// f:/yooutubedata/my_pos/lib/app_shell.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pos/ai_suggestion/screen/ai_suggestion_screen.dart';
import 'package:my_pos/cart_section/screen/cart_screen.dart';
import 'package:my_pos/home/screen/bottom_nav.dart';
import 'package:my_pos/home/screen/product.dart';
import 'package:my_pos/profit_loss_section/screen/profit_loss_screen.dart';
import 'package:my_pos/sales/sale_screen/sales_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  // Route generator for the nested navigator
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/product': // Default/initial route for the shell
        page = ProductScreen();
        break;
      case '/cart':
        page = CartScreen();
        break;
      case '/sale':
        page = SalesHistoryScreen();
        break;
      case '/profitloss':
        page = ProfitLossScreen();
        break;
      case '/ai':
        page = AISuggestionScreen();
        break;
      default:
        // Fallback for unknown routes within the shell
        page = const Center(child: Text('Nested Page Not Found'));
    }
    return GetPageRoute(settings: settings, page: () => page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: Get.nestedKey(1), // ID for the nested navigator
        initialRoute: '/product', // Set the initial route for the shell
        onGenerateRoute: _onGenerateRoute, // Use the custom generator
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
