import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_pos/ai_suggestion/screen/ai_suggestion_screen.dart';
import 'package:my_pos/app_shell.dart';
import 'package:my_pos/home/screen/product.dart';
import 'package:my_pos/profit_loss_section/screen/profit_loss_screen.dart';
import 'package:my_pos/sales/sale_screen/sales_screen.dart';
import 'package:my_pos/cart_section/screen/cart_screen.dart';
import 'package:my_pos/home/screen/bottom_nav.dart';
import 'package:my_pos/login/screen/auth_screen.dart';
import 'package:my_pos/splash.dart';
import 'package:my_pos/utils/constants/text_strings.dart';
import 'package:my_pos/utils/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: TTexts.appName,
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash', // Start with the splash screen
        getPages: [
          GetPage(name: '/splash', page: () => const SplashScreen()),
          GetPage(
              name: '/login',
              page: () => LoginScreen()), // Assuming LoginScreen is imported
          // The AppShell contains its own nested navigation
          GetPage(name: '/shell', page: () => const AppShell(), children: [
            // These routes are now handled by AppShell's nested Navigator
            GetPage(name: '/cart', page: () => CartScreen()),
            GetPage(name: '/sale', page: () => SalesHistoryScreen()),
            GetPage(name: '/product', page: () => ProductScreen()),
            GetPage(name: '/profitloss', page: () => ProfitLossScreen()),
            GetPage(name: '/ai', page: () => AISuggestionScreen()),
          ]),
        ]);
  }
}
