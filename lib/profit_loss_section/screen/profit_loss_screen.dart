import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:my_pos/profit_loss_section/profit_loss_controller/profit_loss_controller.dart';
import 'package:my_pos/profit_loss_section/screen/widget/pdf_genrator.dart';
import 'package:my_pos/profit_loss_section/screen/widget/profit_loss_chart.dart';

class ProfitLossScreen extends StatelessWidget {
  final controller = Get.put(ProfitLossController());
  final currencyFormatter = NumberFormat(
      "#,##0.##", "en_US"); // Using en_US locale for comma separators
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profit & Loss"),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            tooltip: 'View Charts',
            onPressed: () => Get.to(
                () => ProfitLossChartScreen()), // Navigate to chart screen
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined), // PDF icon
            tooltip: 'Download PDF Report',
            onPressed: () async {
              // Show loading indicator (optional but recommended)
              Get.dialog(
                  Center(
                      child:
                          CircularProgressIndicator(color: Colors.blueAccent)),
                  barrierDismissible: false);
              try {
                await PdfGenerator.generateAndOpenProfitLossPdf(
                  filteredSales: controller.filteredSales, // Pass filtered list
                  totalRevenue: controller.totalRevenue.value,
                  totalCost: controller.totalCost.value,
                  totalProfit: controller.totalProfit.value,
                  startDate: controller.startDate.value,
                  endDate: controller.endDate.value,
                );
                Get.back(); // Close loading dialog on success
              } catch (e) {
                Get.back(); // Close loading dialog on error
                Get.snackbar("PDF Error", "Failed to generate report: $e",
                    backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Filter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDatePickerButton(context, true), // Start Date
                  _buildDatePickerButton(context, false), // End Date
                ],
              ),
              SizedBox(height: 5),
              Obx(() => Row(
                    // Display selected dates
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.startDate.value == null
                            ? 'Start: All'
                            : 'Start: ${_dateFormatter.format(controller.startDate.value!)}',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 20),
                      Text(
                        controller.endDate.value == null
                            ? 'End: All'
                            : 'End: ${_dateFormatter.format(controller.endDate.value!)}',
                        style: TextStyle(fontSize: 12),
                      ),
                      if (controller.startDate.value != null ||
                          controller.endDate.value != null)
                        IconButton(
                          icon: Icon(Icons.clear, size: 18),
                          tooltip: 'Clear Filters',
                          onPressed: () {
                            controller.setStartDate(null);
                            controller.setEndDate(null);
                          },
                        )
                    ],
                  )),
              Divider(height: 20),
              Text("Filtered Period Summary",
                  style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 10),

              Text(
                  "Total Revenue: ${currencyFormatter.format(controller.totalRevenue.value)} rupees", // Pass double directly
                  style: TextStyle(fontSize: 18)),
              Text(
                  "Total Cost: ${currencyFormatter.format(controller.totalCost.value)} rupees",
                  style: TextStyle(fontSize: 18)),
              Text(
                  "Net Profit: ${currencyFormatter.format(controller.totalProfit.value)} rupees",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(height: 30),
              Text("Sale-wise Profit (Filtered)",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.filteredSales.length,
                  itemBuilder: (context, index) {
                    //final sale = controller.sales[index];
                    final sale = controller.filteredSales[index];
                    final date = DateFormat.yMMMd().add_jm().format(sale.date);

                    double saleRevenue = 0, saleCost = 0;
                    for (var item in sale.items) {
                      saleRevenue +=
                          (item['price'] ?? 0) * (item['quantity'] ?? 0);
                      saleCost +=
                          (item['costPrice'] ?? 0) * (item['quantity'] ?? 0);
                    }

                    return ListTile(
                      title: Text(
                          "Profit: ${currencyFormatter.format(saleRevenue - saleCost)} rupees"),
                      subtitle: Text("Date: $date"),
                      trailing: Text(
                          "Total: ${currencyFormatter.format(saleRevenue)} rupees"),
                    );
                  },
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  // Helper widget to build date picker buttons
  Widget _buildDatePickerButton(BuildContext context, bool isStartDate) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        minimumSize: Size(120, 40),
      ),
      icon: Icon(Iconsax.calendar_1, color: Colors.white, size: 16),
      label: Text(isStartDate ? "Start Date" : "End Date"),
      onPressed: () async {
        DateTime? initialDate =
            isStartDate ? controller.startDate.value : controller.endDate.value;
        initialDate ??= DateTime.now();

        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020), // Adjust as needed
          lastDate: DateTime.now(), // Can't pick future dates
        );

        if (pickedDate != null) {
          if (isStartDate) {
            controller.setStartDate(pickedDate);
          } else {
            controller.setEndDate(pickedDate);
          }
        }
      },
    );
  }
}
