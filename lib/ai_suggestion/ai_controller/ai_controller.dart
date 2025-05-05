import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:my_pos/service/ai_service.dart';
import 'package:my_pos/service/product_model/product_model.dart';
import 'package:my_pos/service/product_model/sale_model.dart';

class AIController extends GetxController {
  var suggestions = "".obs;
  var isLoading = false.obs;

  Future<void> fetchSuggestions(
      List<SaleModel> sales, List<ProductModel> inventory) async {
    try {
      isLoading.value = true;
      final prompt = buildPrompt(sales, inventory);
      final result = await AIService.getAISuggestions(prompt);
      suggestions.value = result;
    } catch (e) {
      suggestions.value = "Failed to get suggestions: $e";
    } finally {
      isLoading.value = false;
    }
  }

  String buildPrompt(List<SaleModel> sales, List<ProductModel> inventory) {
    final saleSummary = sales.map((s) {
      final itemStr = s.items.map((i) {
        return "${i['name'] ?? 'Unknown'} - Qty: ${i['quantity'] ?? 0}, Sold at: ${i['price'] ?? 0.0}, Cost: ${i['costPrice'] ?? 0.0}";
      }).join('\n');

      return "Sale on ${s.date.toIso8601String()}:\n$itemStr";
    }).join('\n\n');

    // Iterate over the list of products for inventory string
    final inventoryStr = inventory.map((product) {
      return "${product.name} - Stock: ${product.stockQuantity}, Cost: ${product.costPrice}";
    }).join('\n');

    return """
Here is the past sales and current inventory data. 
Please give actionable insights like:
- Which products to restock
- What’s selling the most
- Low stock alerts
- Suggestions for profit increase

SALES DATA:
$saleSummary

INVENTORY:
$inventoryStr
""";
  }
}
