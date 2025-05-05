import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:my_pos/ai_suggestion/ai_controller/ai_controller.dart';
import 'package:my_pos/home/controller/product_controller.dart';
import 'package:my_pos/profit_loss_section/profit_loss_controller/profit_loss_controller.dart';

class AISuggestionScreen extends StatelessWidget {
  final controller = Get.put(AIController());
  final salesController = Get.put(ProfitLossController());
  final productController =
      Get.put(ProductController()); // Use find as ProductScreen likely put it

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI Suggestions"),
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: controller.isLoading.value
              ? Center(
                  child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MarkdownBody(
                      data: controller.suggestions.value,
                      selectable: true,
                    ),
                  ),
                ),
        );
      }),
      // f:\yooutubedata\my_pos\lib\ai_suggestion\screen\ai_suggestion_screen.dart
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () async {
          controller.fetchSuggestions(
              salesController.sales, productController.productList);
        },
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
        tooltip: 'Fetch Suggestions',
      ),
    );
  }
}
