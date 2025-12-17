import 'package:flutter/material.dart';

class TermsConditions extends StatefulWidget {
  const TermsConditions({super.key});

  @override
  State<TermsConditions> createState() => _TermsConditionsState();
}

class _TermsConditionsState extends State<TermsConditions> {

  String _termsText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final text = await DefaultAssetBundle.of(context).loadString("lib/assets/text/terms_conditions.txt");
    setState(() => _termsText = text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(_termsText, style: Theme.of(context).textTheme.bodyMedium)
      )
    );
  }
}