import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Export Service — Handles PDF and CSV generation for DuitKu
class ExportService {
  // ─── Dummy Transaction Data (until real DB is connected) ────
  static final List<Map<String, dynamic>> _dummyTransactions = [
    {'date': '2026-04-01', 'category': 'Makanan', 'note': 'Makan siang kantor', 'amount': -45000, 'type': 'Pengeluaran'},
    {'date': '2026-04-02', 'category': 'Transport', 'note': 'Grab ke kantor', 'amount': -25000, 'type': 'Pengeluaran'},
    {'date': '2026-04-03', 'category': 'Gaji', 'note': 'Gaji bulan April', 'amount': 8500000, 'type': 'Pemasukan'},
    {'date': '2026-04-05', 'category': 'Belanja', 'note': 'Beli baju', 'amount': -350000, 'type': 'Pengeluaran'},
    {'date': '2026-04-07', 'category': 'Tagihan', 'note': 'Listrik April', 'amount': -450000, 'type': 'Pengeluaran'},
    {'date': '2026-04-10', 'category': 'Hiburan', 'note': 'Nonton bioskop', 'amount': -85000, 'type': 'Pengeluaran'},
    {'date': '2026-04-12', 'category': 'Investasi', 'note': 'Top-up reksadana', 'amount': -500000, 'type': 'Pengeluaran'},
    {'date': '2026-04-15', 'category': 'Makanan', 'note': 'Groceries', 'amount': -200000, 'type': 'Pengeluaran'},
    {'date': '2026-04-18', 'category': 'Kesehatan', 'note': 'Vitamin', 'amount': -75000, 'type': 'Pengeluaran'},
    {'date': '2026-04-20', 'category': 'Investasi', 'note': 'Dividen saham', 'amount': 250000, 'type': 'Pemasukan'},
  ];

  // ─── Export PDF ─────────────────────────────────────────
  static Future<void> exportPdf(BuildContext context, {String scope = 'Semua Data'}) async {
    final pdf = pw.Document();
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalIncome = _dummyTransactions
        .where((t) => (t['amount'] as int) > 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int));
    final totalExpense = _dummyTransactions
        .where((t) => (t['amount'] as int) < 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('DuitKu — Laporan Keuangan', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Scope: $scope | Dicetak: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Halaman ${context.pageNumber}/${context.pagesCount}', style: const pw.TextStyle(fontSize: 9)),
        ),
        build: (context) => [
          // Summary
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _pdfSummaryBox('Total Pemasukan', formatter.format(totalIncome), PdfColors.green),
              _pdfSummaryBox('Total Pengeluaran', formatter.format(totalExpense.abs()), PdfColors.red),
              _pdfSummaryBox('Saldo Bersih', formatter.format(totalIncome + totalExpense), PdfColors.amber),
            ],
          ),
          pw.SizedBox(height: 24),

          // Table
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.amber50),
            cellPadding: const pw.EdgeInsets.all(6),
            headers: ['Tanggal', 'Kategori', 'Catatan', 'Tipe', 'Nominal'],
            data: _dummyTransactions.map((t) {
              return [
                t['date'],
                t['category'],
                t['note'],
                t['type'],
                formatter.format((t['amount'] as int).abs()),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static pw.Widget _pdfSummaryBox(String label, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: color), borderRadius: pw.BorderRadius.circular(8)),
      child: pw.Column(
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: color)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── Export CSV ─────────────────────────────────────────
  static Future<String> exportCsv() async {
    final List<List<dynamic>> rows = [
      ['Tanggal', 'Kategori', 'Catatan', 'Tipe', 'Nominal'],
      ..._dummyTransactions.map((t) => [
        t['date'],
        t['category'],
        t['note'],
        t['type'],
        t['amount'],
      ]),
    ];

    final String csvData = csv.encode(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/duitku_export_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv');
    await file.writeAsString(csvData);
    return file.path;
  }
}
