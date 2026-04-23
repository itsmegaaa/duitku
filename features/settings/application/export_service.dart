import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../transactions/domain/transaction_model.dart';
import 'package:intl/intl.dart';

class ExportService {
  static final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static Future<void> exportToCsv(List<TransactionModel> models) async {
    List<List<dynamic>> rows = [];
    rows.add(["ID", "Jenis", "Nominal", "Tanggal", "Kategori", "Catatan"]);

    for (var trx in models) {
      rows.add([
        trx.id,
        trx.type,
        trx.amount,
        trx.date.toIso8601String(),
        trx.categoryId,
        trx.note,
      ]);
    }

    String csvData = csv.encode(rows);
    
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/export_duitku_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(path);
    await file.writeAsString(csvData);
    
    // In real app, we would share this file to external apps.
  }

  static Future<void> exportToPdf(List<TransactionModel> models) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Laporan Transaksi DuitKu', textScaleFactor: 2),
                  pw.Text(DateFormat('dd MMM yyyy').format(DateTime.now())),
                ]
              )
            ),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ["Jenis", "Nominal", "Tanggal", "Catatan"],
              data: models.map((trx) {
                return [
                  trx.type.toUpperCase(),
                  currencyFormat.format(trx.amount),
                  DateFormat('dd/MM/yyyy HH:mm').format(trx.date),
                  trx.note,
                ];
              }).toList(),
            )
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Laporan_DuitKu',
    );
  }
}
