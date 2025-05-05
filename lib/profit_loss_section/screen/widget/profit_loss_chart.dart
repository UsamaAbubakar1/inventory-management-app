import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_pos/profit_loss_section/profit_loss_controller/profit_loss_controller.dart';

class ProfitLossChartScreen extends StatelessWidget {
  final ProfitLossController controller = Get.put(ProfitLossController());
  final currencyFormatter = NumberFormat("#,##0.##", "en_US");
  final Map<double, String> bottomTitles = {};

  final dateFormatter = DateFormat('MMM d'); // Short date format for axis

  ProfitLossChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sort sales by date for the line chart
    final sortedSales = List.from(controller.sales)
      ..sort((a, b) => a.date.compareTo(b.date));
    // if (sortedSales.isEmpty) {
    //   return Center(child: Text("No sales data available for charts."));
    // }
    bottomTitles.clear(); // Clear previous titles to avoid duplication
    return Scaffold(
      appBar: AppBar(title: Text("Profit & Loss Charts")),
      body: Obx(() {
        // Use Obx here if you expect data to potentially reload or change
        // while this screen is open, otherwise it might not be strictly necessary
        // if ProfitLossController loads data only once.
        if (controller.sales.isEmpty) {
          return Center(child: Text("No sales data available for charts."));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Profit Over Time",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildProfitLineChart(sortedSales),
              SizedBox(height: 40),
              Text(
                "Revenue vs Cost",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildRevenueCostBarChart(),
              SizedBox(height: 20),
              Text(
                "Profit Distribution",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildProfitDistributionPieChart(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfitLineChart(List<dynamic> sortedSales) {
    final List<FlSpot> spots = [];

    for (int i = 0; i < sortedSales.length; i++) {
      final sale = sortedSales[i];
      double saleRevenue = 0, saleCost = 0;
      for (var item in sale.items) {
        saleRevenue += (item['price'] ?? 0) * (item['quantity'] ?? 0);
        saleCost += (item['costPrice'] ?? 0) * (item['quantity'] ?? 0);
      }
      final profit = saleRevenue - saleCost;
      spots.add(FlSpot(i.toDouble(), profit));

      // Add date labels sparsely to avoid clutter
      if (i % (sortedSales.length ~/ 5 + 1) == 0 ||
          i == sortedSales.length - 1) {
        bottomTitles[i.toDouble()] = dateFormatter.format(sale.date);
      }
    }

    return SizedBox(
      height: 250, // Give the chart a fixed height
      child: LineChart(
        LineChartData(
          //gridData: FlGridData(show: true),

          gridData: FlGridData(
            show: true, // Show grid lines
            drawVerticalLine: true,
            horizontalInterval:
                _calculateHorizontalInterval(spots), // Dynamic interval
            verticalInterval: 1, // Adjust as needed based on x-axis density
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          lineTouchData: LineTouchData(
            enabled: true, // Enable touch interactions
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: _getTooltipItems, // Custom tooltip builder
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Use the bottomTitles map to get the date labels
                  int index = value.round();
                  return bottomTitles.containsKey(index)
                      ? SideTitleWidget(
                          space: 8.0,
                          meta: meta,
                          child: Text(bottomTitles[index]!,
                              style: TextStyle(fontSize: 10)),
                        )
                      : Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50, // Adjust space for currency labels
                interval:
                    _calculateHorizontalInterval(spots), // Match grid interval

                getTitlesWidget: (value, meta) {
                  return Text(currencyFormatter.format(value),
                      style: TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true), // Show dots on data points
              belowBarData: BarAreaData(
                show: true, // Show area below line
                gradient: LinearGradient(
                  // Add a gradient fill
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.green.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateHorizontalInterval(List<FlSpot> spots) {
    if (spots.isEmpty) return 100; // Default if no data
    double maxProfit = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    double minProfit = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double range = maxProfit - minProfit;
    if (range <= 0)
      return (maxProfit / 5)
          .abs()
          .clamp(1, double.infinity); // Handle zero/negative range
    // Aim for roughly 5-10 grid lines
    return (range / 5).ceilToDouble().clamp(1, double.infinity);
  }

  // Custom tooltip builder
  List<LineTooltipItem?> _getTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      final textStyle = TextStyle(
          color: touchedSpot.bar.gradient?.colors.first ??
              touchedSpot.bar.color ??
              Colors.blueGrey,
          fontWeight: FontWeight.bold,
          fontSize: 14);
      // Assuming x corresponds to the index in sortedSales
      final dateStr = bottomTitles[touchedSpot.x.round()] ??
          dateFormatter.format(controller.sales[touchedSpot.x.round()].date);
      return LineTooltipItem(
          '${currencyFormatter.format(touchedSpot.y)}\n', textStyle,
          children: [
            TextSpan(
                text: dateStr,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                    color: Colors.grey[700]))
          ]);
    }).toList();
  }

  Widget _buildRevenueCostBarChart() {
    double totalRevenue = 0, totalCost = 0;
    for (var sale in controller.sales) {
      for (var item in sale.items) {
        totalRevenue += (item['price'] ?? 0) * (item['quantity'] ?? 0);
        totalCost += (item['costPrice'] ?? 0) * (item['quantity'] ?? 0);
      }
    }

    return SizedBox(
      height: 250, // Give the chart a fixed height
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: totalRevenue,
                  color: Colors.green,
                  width: 30,
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: totalCost,
                  color: Colors.red,
                  width: 30,
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value == 0 ? "Revenue" : "Cost",
                      style: TextStyle(fontSize: 10));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(currencyFormatter.format(value),
                      style: TextStyle(fontSize: 10));
                },
              ),
            ),
          ),
        ),
      ),
    );

    //pie chart
  }

  Widget _buildProfitDistributionPieChart() {
    final totalRevenue = controller.totalRevenue.value;
    final totalCost = controller.totalCost.value;
    final totalProfit = controller.totalProfit.value;

    // Handle cases where values might be zero or negative to avoid chart errors
    final displayCost = totalCost > 0 ? totalCost : 0.0;
    final displayProfit = totalProfit > 0 ? totalProfit : 0.0;
    final displayTotal =
        displayCost + displayProfit; // Base the percentages on positive values

    // If there's no cost and no profit, show an empty state or a placeholder
    if (displayTotal <= 0) {
      return SizedBox(
        height: 250,
        child: Center(child: Text("No profit/cost data to display.")),
      );
    }

    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(sectionsSpace: 20, centerSpaceRadius: 60, sections: [
          PieChartSectionData(
            value: displayCost,
            color: Colors.redAccent,
            // title: "", // Remove title from inside
            showTitle: false, // Ensure title is not shown
            radius: 70, // Adjust radius as needed
            badgeWidget: _Badge(
              'Cost\n${currencyFormatter.format(totalCost)} rupees', // Text for the badge
              color: Colors.redAccent,
            ),
            badgePositionPercentageOffset: .50, // Position badge outside
          ),
          PieChartSectionData(
            value: displayProfit,
            color: Colors.greenAccent,
            // title: "", // Remove title from inside
            showTitle: false, // Ensure title is not shown
            radius: 70, // Adjust radius as needed
            badgeWidget: _Badge(
              'Total\n${currencyFormatter.format(totalProfit)} rupees', // Text for the badge
              color: Colors.greenAccent,
            ),
            badgePositionPercentageOffset: .50, // Position badge outside
          ),
          PieChartSectionData(
            value: displayTotal,
            showTitle: false, // Ensure title is not shown
            radius: 70, // Adjust radius as needed
            badgeWidget: _Badge(
              'Profit\n${currencyFormatter.format(totalRevenue)} rupees', // Text for the badge
              color: Colors.greenAccent,
            ),
            badgePositionPercentageOffset: .50,
            color: Colors.blue, // Make the center transparent
          ),
        ]),
      ),
    );
  }

  // Helper widget for Pie Chart Badges
  Widget _Badge(String text, {required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // Semi-transparent background
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text for better contrast
        ),
      ),
    );
  }
}
