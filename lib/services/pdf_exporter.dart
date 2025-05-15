
import 'dart:io';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/models/status.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<void> savePdfFile(SingleProjectController controller) async {
  final pdf = pw.Document();
  final projectName = controller.getName!;
  final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Stack(
        children: [
          pw.Positioned(
            left: 0,
            top: PdfPageFormat.a4.availableHeight / 2 - 40,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  projectName,
                  style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Container(width: PdfPageFormat.a4.availableHeight * 0.85, height: 2, color: PdfColors.grey700)
              ]
            )
          ),
          pw.Positioned(
            bottom: 24, left:0, right:0, child: pw.Text('Produced by CII', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal))
          ),
          pw.Positioned(
            bottom: 24, right: 0, child: pw.Text(today, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal))
          )
        ]
      )
    )
  );

  // PAGE 2
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Stack(
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
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
          ),
          pw.Positioned(
            bottom: 24, left:0, right:0, child: pw.Text('Produced by CII', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal))
          ),
          pw.Positioned(
            bottom: 24, right: 0, child: pw.Text('Page 2/6', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal))
          ),
        ]
      )
    ),
  );

  // PAGE 3: Snag List grouped by category
  pdf.addPage(
  pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    build: (pw.Context context) {
      final snagList = controller.getAllSnags();
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
              child: pw.Text('Snag Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Category', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('Snag Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
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
    footer: (context) => pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Produced by CII', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal)),
        pw.Text('Page ${context.pageNumber}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal)),
      ],
    ),
  ),
);

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/example.pdf');
  await file.writeAsBytes(await pdf.save());

  print('PDF saved temp to ${file.path}');

  await Share.shareXFiles([XFile(file.path)]);

  // question should we track the pdf file? Or delete it after sharing?
  await file.delete();

}