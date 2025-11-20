import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../features/daily_entry/domain/entities/daily_entry.dart';

class PdfGenerator {
  static Future<void> generateEntriesReport({
    required List<DailyEntry> entries,
    String? businessName,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    print('DEBUG: PdfGenerator - Starting report generation');
    print('DEBUG: PdfGenerator - Entries count: ${entries.length}');
    print('DEBUG: PdfGenerator - Business name: $businessName');

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'AED ', decimalDigits: 2);

    // Calculate totals
    double totalSales = 0;
    double totalBank = 0;
    double totalCash = 0;
    double totalShopExpense = 0;
    double totalMiscExpense = 0;

    for (var entry in entries) {
      totalSales += entry.totalSale;
      totalBank += entry.bankAmount;
      totalCash += entry.cashAmount;
      totalShopExpense += entry.shopExpense;
      totalMiscExpense += entry.miscExpense;
    }

    final totalExpenses = totalShopExpense + totalMiscExpense;
    final netProfit = totalSales - totalExpenses;

    // Build PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(businessName, startDate, endDate, dateFormat),
          pw.SizedBox(height: 20),

          // Summary Section
          _buildSummary(
            totalSales: totalSales,
            totalBank: totalBank,
            totalCash: totalCash,
            totalShopExpense: totalShopExpense,
            totalMiscExpense: totalMiscExpense,
            totalExpenses: totalExpenses,
            netProfit: netProfit,
            currencyFormat: currencyFormat,
          ),
          pw.SizedBox(height: 30),

          // Entries Table Header
          pw.Text(
            'Daily Entries (${entries.length} entries)',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),

          // Entries List
          ...entries.map((entry) => _buildEntryCard(entry, dateFormat, currencyFormat)),
        ],
        footer: (context) => _buildFooter(context),
      ),
    );

    // Show preview and print dialog
    print('DEBUG: PdfGenerator - Building PDF document...');
    try {
      print('DEBUG: PdfGenerator - Calling Printing.layoutPdf...');
      await Printing.layoutPdf(
        onLayout: (format) async {
          print('DEBUG: PdfGenerator - onLayout callback called');
          final pdfBytes = await pdf.save();
          print('DEBUG: PdfGenerator - PDF bytes generated: ${pdfBytes.length} bytes');
          return pdfBytes;
        },
        name: 'expense_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      print('DEBUG: PdfGenerator - PDF generation completed successfully');
    } catch (e, stackTrace) {
      print('DEBUG: PdfGenerator - Error in Printing.layoutPdf: $e');
      print('DEBUG: PdfGenerator - Stack trace: $stackTrace');
      rethrow;
    }
  }

  static pw.Widget _buildHeader(
    String? businessName,
    DateTime? startDate,
    DateTime? endDate,
    DateFormat dateFormat,
  ) {
    String dateRange = '';
    if (startDate != null && endDate != null) {
      dateRange = '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}';
    } else if (startDate != null) {
      dateRange = 'From ${dateFormat.format(startDate)}';
    } else if (endDate != null) {
      dateRange = 'Until ${dateFormat.format(endDate)}';
    } else {
      dateRange = 'All Time';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Shop Expense Tracker',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (businessName != null)
                  pw.Text(
                    businessName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey700,
                    ),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Expense Report',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  dateRange,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 2, color: PdfColors.blue800),
      ],
    );
  }

  static pw.Widget _buildSummary({
    required double totalSales,
    required double totalBank,
    required double totalCash,
    required double totalShopExpense,
    required double totalMiscExpense,
    required double totalExpenses,
    required double netProfit,
    required NumberFormat currencyFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Summary',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: _buildSummaryItem(
                  'Total Sales',
                  currencyFormat.format(totalSales),
                  PdfColors.green700,
                ),
              ),
              pw.Expanded(
                child: _buildSummaryItem(
                  'Total Expenses',
                  currencyFormat.format(totalExpenses),
                  PdfColors.red700,
                ),
              ),
              pw.Expanded(
                child: _buildSummaryItem(
                  'Net Profit',
                  currencyFormat.format(netProfit),
                  netProfit >= 0 ? PdfColors.green800 : PdfColors.red800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Bank Amount:', currencyFormat.format(totalBank)),
                    pw.SizedBox(height: 6),
                    _buildDetailRow('Cash Amount:', currencyFormat.format(totalCash)),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Shop Expense:', currencyFormat.format(totalShopExpense)),
                    pw.SizedBox(height: 6),
                    _buildDetailRow('Misc Expense:', currencyFormat.format(totalMiscExpense)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800)),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildEntryCard(
    DailyEntry entry,
    DateFormat dateFormat,
    NumberFormat currencyFormat,
  ) {
    final balance = entry.balance;
    final balanceColor = balance.abs() < 0.01
        ? PdfColors.green600
        : balance < 0
            ? PdfColors.red600
            : PdfColors.orange600;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Date and Balance
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                dateFormat.format(entry.entryDate),
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: balanceColor.shade(0.05),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  balance.abs() < 0.01
                      ? 'Balanced'
                      : balance < 0
                          ? 'Shortage: ${currencyFormat.format(balance.abs())}'
                          : 'Excess: ${currencyFormat.format(balance)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),

          // Amounts
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildAmountBox(
                  'Total Sale',
                  currencyFormat.format(entry.totalSale),
                  PdfColors.green800,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildAmountBox(
                  'Bank',
                  currencyFormat.format(entry.bankAmount),
                  PdfColors.blue600,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildAmountBox(
                  'Cash',
                  currencyFormat.format(entry.cashAmount),
                  PdfColors.orange600,
                ),
              ),
            ],
          ),

          // Expenses
          if (entry.shopExpenseItems.isNotEmpty || entry.miscExpenseItems.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Text(
              'Expenses',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
            pw.SizedBox(height: 6),
          ],

          // Shop Expenses
          if (entry.shopExpenseItems.isNotEmpty) ...[
            pw.Text(
              'Shop Expenses (${currencyFormat.format(entry.shopExpense)})',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            ...entry.shopExpenseItems.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('- ${item.name}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      currencyFormat.format(item.amount),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 4),
          ],

          // Misc Expenses
          if (entry.miscExpenseItems.isNotEmpty) ...[
            pw.Text(
              'Miscellaneous Expenses (${currencyFormat.format(entry.miscExpense)})',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            ...entry.miscExpenseItems.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('- ${item.name}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text(
                      currencyFormat.format(item.amount),
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Notes
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 4),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Note: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                pw.Expanded(
                  child: pw.Text(
                    entry.notes!,
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildAmountBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
        border: pw.Border.all(color: color.shade(0.7)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8,
              color: color.shade(0.3),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Shop Expense Tracker - Expense Report',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }
}
