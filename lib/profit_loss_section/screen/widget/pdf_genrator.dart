import 'dart:io';
import 'package:flutter/services.dart'; // Required for font loading
import 'package:intl/intl.dart';
import 'package:my_pos/service/product_model/sale_model.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfGenerator {
  static Future<void> generateAndOpenProfitLossPdf({
    required List<SaleModel> filteredSales,
    required double totalRevenue,
    required double totalCost,
    required double totalProfit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Create a new PDF document.
      final PdfDocument document = PdfDocument();
      // Add a page.
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;
      final Size pageSize = page.getClientSize(); // Use client size for drawing

      // --- Setup Fonts and Formats ---
      // Consider loading a TTF font for better character support if needed
      // final ByteData fontData = await rootBundle.load('assets/fonts/YourFont.ttf');
      // final PdfFont contentFont = PdfTrueTypeFont(fontData.buffer.asUint8List(), 10);
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 16,
          style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 12,
          style: PdfFontStyle.bold);
      final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final PdfFont smallContentFont =
          PdfStandardFont(PdfFontFamily.helvetica, 9);

      final currencyFormatter = NumberFormat("#,##0.00", "en_US");
      final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
      final DateFormat dateTimeFormatter = DateFormat('yyyy-MM-dd hh:mm a');

      double currentY = 0; // Track current Y position

      // --- Title ---
      const String titleText = 'Profit & Loss Report';
      final Size titleSize = titleFont.measureString(titleText);
      graphics.drawString(
        titleText,
        titleFont,
        bounds: Rect.fromLTWH((pageSize.width - titleSize.width) / 2, currentY,
            titleSize.width, titleSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.center),
      );
      currentY += titleSize.height + 15;

      // --- Date Range ---
      String dateRangeText = 'Period: All Time';
      if (startDate != null || endDate != null) {
        String start =
            startDate != null ? dateFormatter.format(startDate) : 'Start';
        String end = endDate != null ? dateFormatter.format(endDate) : 'End';
        dateRangeText = 'Period: $start to $end';
      }
      final Size dateRangeSize = contentFont.measureString(dateRangeText);
      graphics.drawString(
        dateRangeText,
        contentFont,
        bounds:
            Rect.fromLTWH(0, currentY, pageSize.width, dateRangeSize.height),
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
      currentY += dateRangeSize.height + 15;

      // --- Summary Section ---
      graphics.drawString(
        'Summary',
        headerFont,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, headerFont.height),
      );
      currentY += headerFont.height + 5;

      final List<Map<String, String>> summaryData = [
        {
          'label': 'Total Revenue:',
          'value': '${currencyFormatter.format(totalRevenue)} PKR'
        },
        {
          'label': 'Total Cost:',
          'value': '${currencyFormatter.format(totalCost)} PKR'
        },
        {
          'label': 'Net Profit:',
          'value': '${currencyFormatter.format(totalProfit)} PKR'
        },
      ];

      for (var item in summaryData) {
        graphics.drawString(
          '${item['label']} ${item['value']}',
          contentFont,
          bounds: Rect.fromLTWH(
              10, currentY, pageSize.width - 20, contentFont.height),
        );
        currentY += contentFont.height + 3;
      }
      currentY += 15; // Add spacing

      // --- Sale-wise Profit Section ---
      graphics.drawString(
        'Sale-wise Profit Details',
        headerFont,
        bounds: Rect.fromLTWH(0, currentY, pageSize.width, headerFont.height),
      );
      currentY += headerFont.height + 10;

      // Create a PDF grid class for the table.
      final PdfGrid grid = PdfGrid();
      // Specify the grid column count.
      grid.columns.add(count: 4);
      // Add grid headers.
      final PdfGridRow headerRow = grid.headers.add(1)[0];
      headerRow.cells[0].value = 'Date';
      headerRow.cells[1].value = 'Total Sale (PKR)';
      headerRow.cells[2].value = 'Total Cost (PKR)';
      headerRow.cells[3].value = 'Profit (PKR)';
      // Style header
      headerRow.style = PdfGridCellStyle(
        backgroundBrush: PdfSolidBrush(PdfColor(211, 211, 211)), // Light grey
        font: PdfStandardFont(PdfFontFamily.helvetica, 10,
            style: PdfFontStyle.bold),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.center,
            lineAlignment: PdfVerticalAlignment.middle),
      );

      // Add data rows.
      for (final sale in filteredSales) {
        double saleRevenue = 0, saleCost = 0;
        for (var item in sale.items) {
          saleRevenue += (item['price'] ?? 0) * (item['quantity'] ?? 0);
          saleCost += (item['costPrice'] ?? 0) * (item['quantity'] ?? 0);
        }
        final profit = saleRevenue - saleCost;

        final PdfGridCellStyle dataCellStyle = PdfGridCellStyle(
          font: smallContentFont,
          format: PdfStringFormat(
              alignment: PdfTextAlignment.right,
              lineAlignment: PdfVerticalAlignment.middle),
        );

        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = dateTimeFormatter.format(sale.date);
        row.cells[1].value = currencyFormatter.format(saleRevenue);
        row.cells[2].value = currencyFormatter.format(saleCost);
        row.cells[3].value = currencyFormatter.format(profit);
        row.style = dataCellStyle;
      }

      // Style specific columns
      grid.columns[0].format = PdfStringFormat(
          alignment: PdfTextAlignment.left,
          lineAlignment: PdfVerticalAlignment.middle);
      // Align Date left

      // Set grid layout properties
      final PdfLayoutFormat gridLayoutFormat = PdfLayoutFormat(
        layoutType:
            PdfLayoutType.paginate, // Allow table to span multiple pages
        breakType: PdfLayoutBreakType.fitPage,
      );

      // Draw the grid.
      final PdfLayoutResult? gridResult = grid.draw(
        page: page, // Draw on the current page first
        bounds: Rect.fromLTWH(0, currentY, pageSize.width,
            pageSize.height - currentY), // Available space
        format: gridLayoutFormat, // Pass layout format here
      );
      // --- Save and Open the PDF ---
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path =
          '${directory.path}/ProfitLossReport_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
      final File file = File(path);
      await file.writeAsBytes(await document.save());

      // Dispose the document.
      document.dispose();

      // Open the file.
      await OpenFilex.open(path);
    } catch (e) {
      print('Error generating PDF: $e');
      // Optionally show a snackbar or dialog to the user
      // Get.snackbar("Error", "Could not generate PDF report: $e");
      throw Exception("Failed to generate PDF: $e"); // Re-throw if needed
    }
  }
}
