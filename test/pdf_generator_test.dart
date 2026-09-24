import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/expense_modal.dart';
import 'package:expense_tracker/widget/pdf_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PdfGenerator Offline MultiPage Tests', () {
    test('Generates PDF document without error for few items', () async {
      final expenses = [
        Expense(
          title: 'Groceries at Supermarket',
          amount: 54.50,
          date: DateTime(2026, 3, 15),
          category: 'Groceries',
          folderName: 'Monthly Household',
        ),
        Expense(
          title: 'Electricity Bill',
          amount: 120.00,
          date: DateTime(2026, 3, 16),
          category: 'Bills',
          folderName: 'Monthly Household',
        ),
      ];

      final pdf = await PdfGenerator.createFolderReportPdf(
        folderName: 'Monthly Household',
        expenses: expenses,
        currency: '\$',
      );

      final pdfBytes = await pdf.save();
      expect(pdfBytes, isNotEmpty);
      expect(pdf.document.pdfPageList.pages.length, equals(1));
    });

    test('Generates MultiPage PDF across multiple pages without overflow', () async {
      // 80 expenses would easily overflow a single A4 page and crash pw.Page
      final expenses = List.generate(
        80,
        (i) => Expense(
          title: 'Expense Item #${i + 1}',
          amount: (i + 1) * 12.75,
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
          category: 'Shopping',
          folderName: 'Big Year 2026',
        ),
      );

      final pdf = await PdfGenerator.createFolderReportPdf(
        folderName: 'Big Year 2026',
        expenses: expenses,
        currency: '৳',
      );

      final pdfBytes = await pdf.save();
      expect(pdfBytes, isNotEmpty);
      // Verify that it actually produced multiple pages
      expect(pdf.document.pdfPageList.pages.length, greaterThan(1));
    });

    test('Handles non-Latin currency symbols gracefully offline', () async {
      final currencies = ['৳', '₹', '€', '£', '\$'];
      for (final curr in currencies) {
        final pdf = await PdfGenerator.createFolderReportPdf(
          folderName: 'Test Folder $curr',
          expenses: [
            Expense(
              title: 'Coffee',
              amount: 4.5,
              date: DateTime.now(),
              category: 'Food',
            ),
          ],
          currency: curr,
        );

        final bytes = await pdf.save();
        expect(bytes, isNotEmpty);
      }
    });
  });
}
