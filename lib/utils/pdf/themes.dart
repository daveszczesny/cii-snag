import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/status.dart';
import 'package:cii/services/pdf_exporter.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.MultiPage buildSnagPage_theme1(String projectName, SnagController snag, String imageQuality, List processedImages, pw.ImageProvider logoImage, [pw.ThemeData? theme]) {
  return pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    theme: theme,
    header: (context) => getHeader(projectName),
    margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    footer: (context) => getFooter(context, logoImage),
    build: (pw.Context context) {
      return [
        // Snag name above everything
        pw.SizedBox(height: 8),
        pw.Text(
          snag.name,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        // Main content row: Details on left, images on right
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left side: Details (remaining width)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  ...() {
                    final Map<String, String> snagAttributes = {
                      "ID": snag.getId,
                      "Created": DateFormat(AppDateTimeFormat.dateTimeFormatPattern).format(snag.dateCreated),
                      "Assignee": snag.assignee == "" ? '-' : snag.assignee,
                      "Due Date": snag.getDueDate != null ? snag.getDueDateString! : '-',
                      "Location": snag.location == "" ? '-' : snag.location,
                      'Category': (snag.categories != null && snag.categories!.isNotEmpty) ? snag.categories![0].name ?? 'Uncategorized' : 'Uncategorized',
                      'Status': snag.status?.name ?? '-',
                    };

                    if (snag.status.name == Status.completed.name) {
                      snagAttributes.addEntries(
                        [
                          MapEntry('Final Remarks', snag.finalRemarks == "" ? '-' : snag.finalRemarks),
                          MapEntry('Reviewed By', snag.reviewedBy == "" ? '-' :snag.reviewedBy),
                        ]
                      );
                    }
                    
                    List<pw.Widget> widgets = [];
                    snagAttributes.forEach((label, value) {
                      widgets.add(
                        pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 80,
                              child: pw.Text('$label:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                            ),
                            pw.Expanded(
                              child: pw.Text(value),
                            ),
                          ],
                        ),
                      );
                      widgets.add(pw.SizedBox(height: 4));
                    });
                    return widgets;
                  }(),
                  pw.SizedBox(height: 4),
                  pw.Text('Description:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(snag.description ?? '-', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
            
            pw.SizedBox(width: 16),
            
            // Right side: Images (45% width)
            pw.Container(
              width: PdfPageFormat.a4.availableWidth * 0.45,
              child: pw.Column(
                children: [
                  // Main image (large)
                  if (processedImages.isNotEmpty)
                    pw.Container(
                      width: double.infinity,
                      height: PdfPageFormat.a4.availableWidth * 0.45,
                      child: pw.Image(processedImages[0], fit: pw.BoxFit.cover),
                    ),
                  // Smaller images below
                  if (processedImages.length > 1) ...[  
                    pw.SizedBox(height: 8),
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: processedImages.skip(1).map<pw.Widget>((img) {
                        return pw.Container(
                          width: (PdfPageFormat.a4.availableWidth * 0.45 - 8) / 2,
                          height: (PdfPageFormat.a4.availableWidth * 0.45 - 8) / 2,
                          child: pw.Image(img, fit: pw.BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ];

    },
  );
}