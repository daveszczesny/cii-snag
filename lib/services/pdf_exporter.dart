
import 'dart:io';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

Future<void> savePdfFile(
  SingleProjectController controller,
  String imageQuality, // "High", "Medium", "Low"
  List<String>? selectedCategories, // Categories to include in the export
  List<String>? selectedStatuses // Statuses to include in the export
) async {
  final pdf = pw.Document();
  final projectName = controller.getName!;


  final logoBytes = await rootBundle.load('lib/assets/logo/CII_logo.png');
  final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      build: (pw.Context context) => [
        pw.SizedBox(height: PdfPageFormat.a4.availableHeight * 0.45),
        // Project name (middle left)
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.SizedBox(width: 10),
            pw.Text(projectName,style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ]
        ),
        pw.SizedBox(height: 24),
        pw.Container(
          width: PdfPageFormat.a4.availableWidth,
          height: 2,
          color: PdfColors.grey700,
          margin: const pw.EdgeInsets.only(top: 2, bottom: 16),
        ),
      ],
      footer: (context) => getFooter(context, logoImage)
    ),
  );


  // PAGE 2

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      build: (pw.Context context) => [
        // Project name (top middle)
        pw.Center(
          child: pw.Text(
            projectName,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 24),
        // "Project Details" with underline
        pw.Text(
          "Project Details",
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Container(
          width: PdfPageFormat.a4.availableWidth,
          height: 2,
          color: PdfColors.grey700,
          margin: const pw.EdgeInsets.only(top: 2, bottom: 16),
        ),
        // Project attributes (example)
        pw.Text("Location: ${controller.getLocation ?? '-'}", style: const pw.TextStyle(fontSize: 14)),
        pw.Text("Client: ${controller.getClient ?? '-'}", style: const pw.TextStyle(fontSize: 14)),
        pw.Text("Contractor: ${controller.getContractor ?? '-'}", style: const pw.TextStyle(fontSize: 14)),
        pw.Text("Reference: ${controller.getProjectRef ?? '-'}", style: const pw.TextStyle(fontSize: 14)),
        pw.Text("Status: ${controller.getStatus ?? '-'}", style: const pw.TextStyle(fontSize: 14)),
        pw.Text("Created: ${controller.getDateCreated != null ? DateFormat('yyyy-MM-dd').format(controller.getDateCreated!) : '-'}", style: const pw.TextStyle(fontSize: 14)),
      ],
      footer: (context) => getFooter(context, logoImage)
    ),
  );

  // PAGE 3: Snag List grouped by category
  pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    build: (pw.Context context) {
      final snagList = controller.getAllSnags()
        // Filter by selected categories if provided
        .where((snag) {
          final snagCategory = (snag.categories != null && snag.categories.isNotEmpty)
              ? snag.categories[0].name
              : "Uncategorized";
          final snagStatus = snag.status?.name;
          final categoryMatch = selectedCategories == null || selectedCategories.isEmpty
              ? true
              : (snagCategory != null && selectedCategories.contains(snagCategory));
          final statusMatch = selectedStatuses == null || selectedStatuses.isEmpty
              ? true
              : (snagStatus != null && selectedStatuses.contains(snagStatus));
          return categoryMatch && statusMatch;
        }).toList();

      // Sort snags by category name
      snagList.sort((a, b) {
        final aCat = (a.categories != null && a.categories.isNotEmpty) ? a.categories[0].name ?? '-' : '-';
        final bCat = (b.categories != null && b.categories.isNotEmpty) ? b.categories[0].name ?? '-' : '-';
        return aCat.compareTo(bCat);
      });

      List<pw.TableRow> rows = [
        // Table header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Index', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${AppStrings.snag()} Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${AppStrings.snag()} Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      ];

      final List<String> statusOrder = Status.values.map((status) => status.name).toList();

      // sort the snagList so that snags with no category are at the end
      snagList.sort((a, b) {
        String aCat = (a.categories != null && a.categories.isNotEmpty) ? a.categories[0].name ?? '-' : '-';
        String bCat = (b.categories != null && b.categories.isNotEmpty) ? b.categories[0].name ?? '-' : '-';

        // Put uncategorized last
        if (aCat == '-' && bCat != '-') return 1;
        if (bCat == '-' && aCat != '-') return -1;

        // Sort by category name
        int catCompare = aCat.compareTo(bCat);
        if (catCompare != 0) return catCompare;

        // Custom status order
        String aStatus = a.status?.name ?? '-';
        String bStatus = b.status?.name ?? '-';
        int aIndex = statusOrder.indexOf(aStatus);
        int bIndex = statusOrder.indexOf(bStatus);

        // If status not found, put it last
        if (aIndex == -1) aIndex = statusOrder.length;
        if (bIndex == -1) bIndex = statusOrder.length;

        return aIndex.compareTo(bIndex);
      });

      String? lastCategory;
      int index = 1;
      for (final snag in snagList) {
        final category = (snag.categories != null && snag.categories.isNotEmpty)
            ? snag.categories[0].name ?? '-'
            : '-';

        // Insert a category header row if the category changes
        if (category != lastCategory) {
          rows.add(
            pw.TableRow(
              children: [
                pw.Container(),
                pw.Container(),
                pw.Container(),
                pw.Container(),
              ],
            ),
          );
          lastCategory = category;
        }

        rows.add(
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text('${index++}'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(snag.name ?? '-'),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(category),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(snag.status?.name ?? '-'),
              ),
            ],
          ),
        );
      }

      return [
        pw.Text(
          'Snag List',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: rows,
        ),
      ];
    },
    footer: (context) => getFooter(context, logoImage)
  ),
);

  final bytes = await pdf.save();
  final pdfDirPath = await getPdfDirectory();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final fileName = '$projectName-$timestamp.pdf';
  final file = File('$pdfDirPath/$fileName');
  await file.writeAsBytes(bytes);


  // create a record of the export
  final pdfRecord = PdfExportRecords(
    exportDate: DateTime.now(),
    fileName: fileName,
    fileHash: _calculateHash(bytes),
    fileSize: bytes.length,
  );

  controller.addPdfExportRecord(pdfRecord);
  await Share.shareXFiles([XFile(file.path)]);
}

Future<void> openPdfFromRecord(PdfExportRecords record) async {
  final pdfDirPath = await getPdfDirectory();
  final filePath = '$pdfDirPath/${record.fileName}';
  final file = File(filePath);
  if (await file.exists()) {
    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Could not open PDF: ${result.message}');
    }
  } else {
    throw FileSystemException('File not found', filePath);
  }
}

String _calculateHash(List<int> bytes) {
  return sha256.convert(bytes).toString();
}

pw.Widget getFooter(pw.Context context, pw.ImageProvider logoImage) {
  return pw.Container(
    width: PdfPageFormat.a4.availableWidth,
    height: 40, // Adjust as needed
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        // Left: Logo
        pw.Image(logoImage, width: 60, height: 30, fit: pw.BoxFit.contain),

        // Center: Produced by CII (centered)
        pw.Expanded(
          child: pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Produced by CII',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
            ),
          ),
        ),

        // Right: Page number
        pw.Text(
          'Page ${context.pageNumber}',
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
        ),
      ],
    ),
  );
}