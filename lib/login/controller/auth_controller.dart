import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pos/service/firebase_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;

  Future<void> loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please fill in all fields");
      return;
    }

    isLoading.value = true;
    try {
      final user = await FirebaseService.signIn(
          emailController.text, passwordController.text);
      if (user != null) {
        Get.offAllNamed('/shell');
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await FirebaseService.logout();
    Get.offAllNamed('/login');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
