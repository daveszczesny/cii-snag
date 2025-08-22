
import 'dart:io';
import 'package:cii/controllers/single_project_controller.dart';
import 'package:cii/controllers/snag_controller.dart';
import 'package:cii/models/pdfexportrecords.dart';
import 'package:cii/models/status.dart';
import 'package:cii/utils/common.dart';
import 'package:cii/view/utils/constants.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

Future<void> savePdfFile(
  BuildContext context,
  SingleProjectController controller,
  String imageQuality, // "High", "Medium", "Low",
  Function themeFunction,
  List<String>? selectedCategories, // Categories to include in the export
  List<String>? selectedStatuses // Statuses to include in the export
) async {

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator())
  );

  try {

    final pdf = pw.Document();
    final projectName = controller.getName!;


    final logoBytes = await rootBundle.load('lib/assets/logo/CII_logo.png');
    final compressedLogoImage = await processImageForQuality(logoBytes.buffer.asUint8List(), imageQuality);
    final logoImage = pw.MemoryImage(compressedLogoImage);

    final snagList = controller.getAllSnags()
      .where((snag) {
        final snagCategory = snag.categories.isNotEmpty
            ? snag.categories[0].name
            : "Uncategorized";
        final snagStatus = snag.status.name;
        final categoryMatch = selectedCategories == null || selectedCategories.isEmpty
            ? true
            : (selectedCategories.contains(snagCategory));
        final statusMatch = selectedStatuses == null || selectedStatuses.isEmpty
            ? true
            : (selectedStatuses.contains(snagStatus));
        return categoryMatch && statusMatch;
      }).toList();

    final frontPage = buildFrontPage(projectName, logoImage);
    final projectDetailPage = buildProjectDetailsPage(projectName, controller, logoImage);
    final snagListPage = buildSnagListPage(projectName, controller, imageQuality, selectedCategories, selectedStatuses, snagList, logoImage);

    pdf.addPage(frontPage);
    pdf.addPage(projectDetailPage);
    pdf.addPage(snagListPage);

    // Process all images in parallel with caching
    final Map<String, pw.MemoryImage> imageCache = {};
    final allImagePaths = snagList
      .expand((snag) => [...snag.imagePaths, ...snag.annotatedImagePaths.values])
      .where((path) => path.isNotEmpty)
      .toSet();

    // Process all unique images in parallel
    await Future.wait(
      allImagePaths.map((path) async {
        try {
          final file = File(path);
          if (await file.exists()) {
            final imgBytes = await file.readAsBytes();
            final processed = await processImageForQuality(imgBytes, imageQuality);
            imageCache[path] = pw.MemoryImage(processed);
          }
        } catch (e) {
          // Skip failed images
        }
      }),
    );

    for (final snag in snagList) {
      // Use cached processed images
      final processedImages = snag.imagePaths
        ?.where((path) => imageCache.containsKey(path))
        .map((path) {
          // Check if there's an annotated version of this image
          final annotatedPath = snag.annotatedImagePaths[path];
          if (annotatedPath != null && imageCache.containsKey(annotatedPath)) {
            return imageCache[annotatedPath]!;
          }
          return imageCache[path]!;
        })
        .toList() ?? <pw.MemoryImage>[];

      final snagPageThemed = themeFunction(projectName, snag, imageQuality, processedImages, logoImage);
      pdf.addPage(snagPageThemed);
    }

    // =====================================
    // =========== SAVE PDF FILE ===========
    // =====================================

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

    Navigator.of(context).pop();
  } catch (e) {
    print(e);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error generating PDF')),
    );
  }
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

pw.Widget getHeader(String projectName) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 16),
    child: pw.Center(
      child: pw.Text(
        projectName,
        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
      ),
    ),
  );
}

pw.Widget getFooter(pw.Context context, pw.ImageProvider logoImage) {
  final pageWidth = PdfPageFormat.a4.width;
  const leftMargin = 24.0;
  
  return pw.Container(
    width: pageWidth,
    height: 40,
    child: pw.Stack(
      children: [
        // Logo - positioned at left margin
        pw.Positioned(
          left: leftMargin,
          top: 5,
          child: pw.Image(
            logoImage, 
            width: 60, 
            height: 30, 
            fit: pw.BoxFit.contain
          ),
        ),
        
        // "Produced by CII" - absolutely centered on the page
        pw.Positioned(
          left: 0,
          right: 0,
          top: 14,
          child: pw.Center(
            child: pw.Text(
              'Produced by CII',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
            ),
          ),
        ),
        
        // Page number - positioned at right margin
        pw.Positioned(
          right: leftMargin,
          top: 14,
          child: pw.Text(
            'Page ${context.pageNumber}',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.normal),
          ),
        ),
      ],
    ),
  );
}


pw.MultiPage buildFrontPage(String projectName, pw.ImageProvider logoImage) {
  return pw.MultiPage(
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
  );
}

pw.MultiPage buildProjectDetailsPage(String projectName, SingleProjectController controller, pw.ImageProvider logoImage) {
  return pw.MultiPage(
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
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Location:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getLocation == "" ? '-' : controller.getLocation!, style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Client:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getClient == "" ? '-' : controller.getClient!, style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Contractor:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getContractor == "" ? '-' : controller.getContractor!, style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Reference:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getProjectRef!, style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Status:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getStatus!, style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Container(
                      width: 80,
                      child: pw.Text('Created:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Expanded(
                      child: pw.Text(controller.getDateCreated != null ? DateFormat('yyyy-MM-dd').format(controller.getDateCreated!) : '-', style: const pw.TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 12),
                pw.Text('Description:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(controller.getDescription == "" ? '-' : controller.getDescription!, style: const pw.TextStyle(fontSize: 14))
              ]
            )
          ),
           pw.SizedBox(width: 16),
          // Right side: Images (45% width)
          pw.Container(
            width: PdfPageFormat.a4.availableWidth * 0.55,
            child: pw.Column(
              children: []
            )
          )
        ]
      ),
    ],
    footer: (context) => getFooter(context, logoImage)
  );
}

pw.MultiPage buildSnagListPage(
  String projectName,
  SingleProjectController controller,
  String imageQuality,
  List<String>? selectedCategories,
  List<String>? selectedStatuses,
  List snagList,
  pw.ImageProvider logoImage) {
  return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (context) => getHeader(projectName),
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      build: (pw.Context context) {
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
          pw.SizedBox(height: 8),
          pw.Text(
            '${AppStrings.snag()} List',
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
    );
}

pw.MultiPage buildSnagPage(String projectName, SnagController snag, String imageQuality, List processedImages, pw.ImageProvider logoImage) {
  return pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    header: (context) => getHeader(projectName),
    margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    footer: (context) => getFooter(context, logoImage),
    build: (pw.Context context) {
      return [
        // Snag name above everything
        pw.Text(
          snag.name ?? '-',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        
        // Main content row: Images on left, details on right
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left side: Images (35% width)
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
                      spacing: 2,
                      runSpacing: 2,
                      children: processedImages.skip(1).map<pw.Widget>((img) {
                        return pw.Container(
                          width: (PdfPageFormat.a4.availableWidth * 0.45) / 2.5,
                          height: (PdfPageFormat.a4.availableWidth * 0.45) / 2.5,
                          child: pw.Image(img, fit: pw.BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            pw.SizedBox(width: 16),
            
            // Right side: Details (remaining width)
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Category: ${(snag.categories != null && snag.categories!.isNotEmpty) ? snag.categories![0].name : 'Uncategorized'}'),
                  pw.SizedBox(height: 4),
                  pw.Text('Status: ${snag.status?.name ?? '-'}'),
                  pw.SizedBox(height: 8),
                  pw.Text('Description:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(snag.description ?? '-', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ];

    },
  );
}

Future<Uint8List> processImageForQuality(Uint8List originalBytes, String imageQuality) async {
  final image = img.decodeImage(originalBytes);
  if (image == null) return originalBytes;

  int quality;
  int minWidth;
  
  switch (imageQuality) {
    case 'Low':
      quality = 10;
      minWidth = 800; // Scale down for email
      break;
    case 'Medium':
      quality = 30;
      minWidth = 1200;
      break;
    case 'High':
    default:
      quality = 65;
      minWidth = 1920; // Keep higher resolution
      break;
  }

  final result = await FlutterImageCompress.compressWithList(
    originalBytes,
    minWidth: minWidth,
    minHeight: 600,
    quality: quality,
    format: CompressFormat.jpeg,
  );

  return result;
}