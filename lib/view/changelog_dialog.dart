import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:cii/services/changelog_service.dart';


class ChangelogDialog extends StatefulWidget{
  final String changelog;

  const ChangelogDialog({Key? key, required this.changelog}) : super(key : key);

  @override
  State<ChangelogDialog> createState() => _ChangelogDialogState();
}

class _ChangelogDialogState extends State<ChangelogDialog> {

  List<ChangelogSection> sections = [];

  @override
  void initState() {
    super.initState();
    _parseChangelog();
  }

  void _parseChangelog() {
    final lines = widget.changelog.split("\n");
    String currentVersion = "";
    DateTime? currentDate;
    List<String> currentContent = [];

    for (String line in lines) {
      if (line.startsWith('## ')) {
        final headerText = line.substring(3); // "## "
        final parts = headerText.split(' - ');
        currentVersion = parts[0];
        currentDate = parts.length > 1 ? DateTime.tryParse(parts[1]) : null;
      } else if (line.trim().isNotEmpty) {
        currentContent.add(line);
      }
    }

    if (currentVersion.isNotEmpty) {
      sections.add(ChangelogSection(currentVersion, currentContent.join("\n"), currentDate));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("What's New"),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "NEW",
                      style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: "Roboto")
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sections[0].version,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: "Roboto"
                          ),
                        ),
                        if (sections[0].date != null)
                          Text(
                            "${sections[0].date!.day}/${sections[0].date!.month}/${sections[0].date!.year}",
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])
                          ),
                        ],
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 16),
                // content
                Markdown(
                  data: sections[0].content,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(fontSize: 14, fontFamily: "Roboto"),
                    listBullet: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ChangelogService.markChangelogSeen();
            Navigator.of(context).pop();
          },
          child: const Text("Got it", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}


class ChangelogSection {
  final String version;
  final String content;
  final DateTime? date;

  ChangelogSection(this.version, this.content, this.date);
}
