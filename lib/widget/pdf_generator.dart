import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../expense_modal.dart';

class PdfGenerator {
  static String _getCurrencyCode(String symbol) {
    switch (symbol) {
      case '৳':
        return 'BDT';
      case '\$':
        return 'USD';
      case '€':
        return 'EUR';
      case '₹':
        return 'INR';
      case '£':
        return 'GBP';
      default:
        return symbol;
    }
  }

  static Future<pw.ThemeData> _buildPdfTheme() async {
    pw.Font baseFont;
    pw.Font baseFontBold;
    final List<pw.Font> fallbackFonts = [];

    try {
      final regularData =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      baseFont = pw.Font.ttf(regularData);
      baseFontBold = pw.Font.ttf(boldData);

      try {
        final bengaliData = await rootBundle.load(
          'assets/fonts/NotoSansBengali-Regular.ttf',
        );
        fallbackFonts.add(pw.Font.ttf(bengaliData));
      } catch (_) {}

      try {
        final devanagariData = await rootBundle.load(
          'assets/fonts/NotoSansDevanagari-Regular.ttf',
        );
        fallbackFonts.add(pw.Font.ttf(devanagariData));
      } catch (_) {}
    } catch (_) {
      baseFont = pw.Font.helvetica();
      baseFontBold = pw.Font.helveticaBold();
    }

    return pw.ThemeData.withFont(
      base: baseFont,
      bold: baseFontBold,
      fontFallback: fallbackFonts,
    );
  }

  /// Builds a modern multi-page PDF document with custom branding and offline fonts.
  static Future<pw.Document> createFolderReportPdf({
    required String folderName,
    required List<Expense> expenses,
    required String currency,
  }) async {
    final currencyCode = _getCurrencyCode(currency);
    final theme = await _buildPdfTheme();
    final pdf = pw.Document(theme: theme);

    // Color palette
    final primaryColor = PdfColor.fromHex('#0284C7');
    final deepBlueColor = PdfColor.fromHex('#0369A1');
    final skyBlueColor = PdfColor.fromHex('#38BDF8');
    final iceBlueBg = PdfColor.fromHex('#F0F9FF');
    final slateDark = PdfColor.fromHex('#0F172A');
    final slateBody = PdfColor.fromHex('#1E293B');
    final slateMuted = PdfColor.fromHex('#64748B');
    final slateLightText = PdfColor.fromHex('#94A3B8');
    final cardBg = PdfColor.fromHex('#F8FAFC');
    final borderLight = PdfColor.fromHex('#E2E8F0');
    final borderBlue = PdfColor.fromHex('#BAE6FD');
    final badgeBg = PdfColor.fromHex('#E0F2FE');

    // Try loading the app logo image safely from assets
    pw.MemoryImage? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/icon.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // In case the asset is missing or in headless tests
    }

    final totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);
    final currentDateStr = DateFormat.yMMMd().format(DateTime.now());
    final fullDateStr =
        DateFormat.yMMMd().add_jm().format(DateTime.now());

    // Logo widget or stylized monogram fallback
    final pw.Widget logoWidget =
        logoImage != null
            ? pw.Container(
              width: 34,
              height: 34,
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.ClipRRect(
                horizontalRadius: 8,
                verticalRadius: 8,
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
            )
            : pw.Container(
              width: 34,
              height: 34,
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              alignment: pw.Alignment.center,
              child: pw.Text(
                'SW',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: borderLight, width: 1.2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // App Logo and Brand Info
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    logoWidget,
                    pw.SizedBox(width: 10),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'SpendWise',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: deepBlueColor,
                              ),
                            ),
                            pw.SizedBox(width: 6),
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: pw.BoxDecoration(
                                color: badgeBg,
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                'STATEMENT',
                                style: pw.TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Personal Finance & Expense Report',
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            color: slateMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Folder Name & Date badge (Only Folder Name, no "Folder:" tag)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: iceBlueBg,
                        border: pw.Border.all(color: borderBlue, width: 0.8),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        folderName,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: deepBlueColor,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: $currentDateStr',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        color: slateMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 14),
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: pw.BoxDecoration(
              color: primaryColor, // Vibrant Ocean Blue
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Stack(
              alignment: pw.Alignment.center,
              children: [
                // Centered "Made by SpendWise"
                pw.Align(
                  alignment: pw.Alignment.center,
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 5,
                        height: 5,
                        decoration: pw.BoxDecoration(
                          color: skyBlueColor, // Sky Blue dot
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.SizedBox(width: 7),
                      pw.Text(
                        'Made by SpendWise',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        '  •  Track Expenses Easily & Stay Within Budget',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: borderBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right aligned page numbering pill
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: pw.BoxDecoration(
                      color: deepBlueColor,
                      borderRadius: pw.BorderRadius.circular(10),
                    ),
                    child: pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) => [
          // Modern Hero Summary Card
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: cardBg,
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: borderLight, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Left: Folder Title & Transaction count (without Avg)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      folderName,
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: slateDark,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${expenses.length} transaction${expenses.length == 1 ? '' : 's'}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: deepBlueColor,
                      ),
                    ),
                  ],
                ),

                // Right: Big Total Spent Highlight
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: pw.BoxDecoration(
                    color: iceBlueBg,
                    border: pw.Border.all(color: borderBlue, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TOTAL AMOUNT',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: deepBlueColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '${totalAmount.toStringAsFixed(2)} $currencyCode',
                        style: pw.TextStyle(
                          fontSize: 19,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),

          // Transactions Table with SN instead of #
          pw.TableHelper.fromTextArray(
            headers: ['SN', 'Date', 'Title / Description', 'Category', 'Amount'],
            data: List.generate(expenses.length, (i) {
              final e = expenses[i];
              return [
                '${i + 1}',
                DateFormat.yMMMd().format(e.date),
                e.title,
                e.category,
                '${e.amount.toStringAsFixed(2)} $currencyCode',
              ];
            }),
            headerStyle: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: slateDark, // Sleek Slate 900
            ),
            headerHeight: 28,
            cellHeight: 25,
            cellStyle: pw.TextStyle(fontSize: 9.5, color: slateBody),
            cellAlignments: const {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
            headerAlignments: const {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
            },
            columnWidths: const {
              0: pw.FixedColumnWidth(28),
              1: pw.FlexColumnWidth(2.2),
              2: pw.FlexColumnWidth(3.8),
              3: pw.FlexColumnWidth(2.6),
              4: pw.FlexColumnWidth(2.4),
            },
            rowDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: borderLight, width: 0.5),
              ),
            ),
            oddRowDecoration: pw.BoxDecoration(
              color: cardBg,
              border: pw.Border(
                bottom: pw.BorderSide(color: borderLight, width: 0.5),
              ),
            ),
          ),
          pw.SizedBox(height: 14),

          // Grand Total Box at bottom of list
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: pw.BoxDecoration(
                color: iceBlueBg,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: borderBlue, width: 1.2),
              ),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Grand Total: ',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: slateDark,
                    ),
                  ),
                  pw.Text(
                    '${totalAmount.toStringAsFixed(2)} $currencyCode',
                    style: pw.TextStyle(
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(height: 10),

          // Subtext metadata centered
          pw.Align(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Report exported via SpendWise on $fullDateStr',
              style: pw.TextStyle(
                fontSize: 8,
                color: slateLightText,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf;
  }

  /// Generates the multi-page PDF and opens the native printing/preview dialog.
  static Future<void> generateAndPrintFolderReport(
    String folderName,
    List<Expense> expenses,
    String currency,
  ) async {
    final pdf = await createFolderReportPdf(
      folderName: folderName,
      expenses: expenses,
      currency: currency,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Expense_Report_${folderName.replaceAll(' ', '_')}.pdf',
    );
  }
}
