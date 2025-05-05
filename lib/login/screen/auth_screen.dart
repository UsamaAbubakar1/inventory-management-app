import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:my_pos/login/controller/auth_controller.dart';
import 'package:my_pos/utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  final controller = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 20),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 50),
            Obx(
              () => // Wrap the button with another Obx to react to isLoading
                  ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : controller.loginUser, // Disable when loading
                child: const Text("Login"),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
