import 'package:cii/utils/colors/app_colors.dart';
import 'package:cii/view/settings/app_settings.dart';
import 'package:cii/view/settings/company_settings.dart';
import 'package:cii/view/settings/feedback.dart';
import 'package:cii/view/settings/naming_settings.dart';
import 'package:cii/view/settings/privacy_policy.dart';
import 'package:cii/view/settings/terms_conditions.dart';
import 'package:cii/view/settings/feedback.dart' as ReportFeedback;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,
                children: [
                  settingsTab(context, Icons.dashboard_customize_outlined, "App", const AppSettings()),
                  settingsTab(context, Icons.text_fields, "Terminology", const NamingSettings()),
                  // settingsTab(context, Icons.apartment, "Company", const CompanySettings()),
                  settingsTab(context, Icons.description, "Terms & Conditions", const TermsConditions()),
                  settingsTab(context, Icons.privacy_tip, "Privacy Policy", const PrivacyPolicy()),
                  settingsTab(context, Icons.feedback_outlined, "Report a bug", const ReportFeedback.Feedback()),
                ],
              ),
            ),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'App Version: ${snapshot.data!.version}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}