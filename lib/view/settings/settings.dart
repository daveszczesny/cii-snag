import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/settings/company_settings.dart';
import 'package:cii/view/settings/datetime_settings.dart';
import 'package:cii/view/settings/naming_settings.dart';
import 'package:cii/view/settings/privacy_policy.dart';
import 'package:cii/view/settings/terms_conditions.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

Widget settingsTab(BuildContext context, IconData icon, String label, StatefulWidget w) {
  return InkWell(
    borderRadius: BorderRadius.circular(16),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => w),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        // Remove color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen, // Outline color
          width: 2,               // Outline thickness
        ),
      ),
      margin: const EdgeInsets.all(8),
      width: 120,
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primaryGreen),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          shrinkWrap: true,
          children: [
            settingsTab(context, Icons.text_fields, "Terminology", const NamingSettings()),
            settingsTab(context, Icons.calendar_today, "Date Time Format", const DateTimeSettings()),
            settingsTab(context, Icons.apartment, "Company", const CompanySettings()),
            settingsTab(context, Icons.description, "Terms & Conditions", const TermsConditions()),
            settingsTab(context, Icons.privacy_tip, "Terms & Conditions", const PrivacyPolicy()),
          ],
        ),
      ),
    );
  }
}