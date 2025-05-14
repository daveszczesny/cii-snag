
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

Future<void> savePdfFile() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
        child: pw.Text('Hello World'),
      )
    )
  );

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/example.pdf');
  await file.writeAsBytes(await pdf.save());

  print('PDF saved temp to ${file.path}');

  await Share.shareXFiles([XFile(file.path)]);

  // question should we track the pdf file? Or delete it after sharing?
  await file.delete();

}