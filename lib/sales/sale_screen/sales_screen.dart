import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_pos/sales/sales_controller/sales_controller.dart';

class SalesHistoryScreen extends StatelessWidget {
  final controller = Get.put(SalesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales History'),
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search by date or product name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .scaffoldBackgroundColor, // Or another subtle color
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return Center(
                child: CircularProgressIndicator(color: Colors.blueAccent));
          }
          final displayedSales = controller.filteredSalesList;
          if (displayedSales.isEmpty) {
            // Show different message based on whether a search is active
            return Center(
              child: Text(controller.searchQuery.value.isEmpty
                  ? 'No sales recorded yet.'
                  : 'No sales found matching "${controller.searchQuery.value}".'),
            );
          }

          return ListView.builder(
            itemCount: displayedSales.length,
            itemBuilder: (context, index) {
              final sale = displayedSales[index];
              final priceFormatter =
                  NumberFormat("#,##0.00", "en_US"); // Consistent format
              final dateFormatter =
                  DateFormat.yMMMd().add_jm(); // Consistent format

              return ExpansionTile(
                title: Text(
                    "${priceFormatter.format(sale.totalAmount)} PKR"), // Use PKR
                subtitle: Text(dateFormatter.format(sale.date)),
                children: sale.items.map((item) {
                  return ListTile(
                    title: Text(item['name'] ??
                        'Unknown Product'), // Handle potential null name
                    subtitle: Text(
                        "Qty: ${item['quantity']} × ${priceFormatter.format(item['price'])} PKR"),
                    trailing: Text(
                        "${priceFormatter.format((item['price'] ?? 0) * (item['quantity'] ?? 0))} PKR"), // Calculate item total
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
