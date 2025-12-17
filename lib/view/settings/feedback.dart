import 'package:cii/view/utils/text.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Feedback extends StatefulWidget {
  const Feedback({super.key});

  @override
  State<Feedback> createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  final _feedbackController = TextEditingController();

  Future<void> _sendEmail() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter feedback first'))
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'contact@constructionitis.com',
      query: 'subject=Bug Report&body=${Uri.encodeComponent(feedback)}',
    );

    try {
      await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app'))
        );
      }
    }


    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Bug'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red.shade600, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Tell us about the issue',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve the app by describing any bugs or issues you\'ve encountered.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: TextField(
                    controller: _feedbackController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Describe the issue you encountered...\n\nPlease include:\n• What you were trying to do\n• What happened instead\n• Steps to reproduce the issue',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: buildTextButton("Send Bug Report", _sendEmail),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
