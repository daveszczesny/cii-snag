import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangelogService {
  static const bool _debugAlwaysShow = false;

  static const String _lastVersionKey = 'last_seen_version';

  static Future<bool> shouldShowChangelog() async {
    if (_debugAlwaysShow) return true;


    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    final lastVersion = prefs.getString(_lastVersionKey);

    return lastVersion != packageInfo.version;
  }

  static Future<void> markChangelogSeen() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVersionKey, packageInfo.version); 
  }

  static Future<String> getLatestChangelog() async {
    final fullChangelog = await rootBundle.loadString('lib/assets/changelog.md');
    final lines = fullChangelog.split('\n');
    
    List<String> latestSection = [];
    bool foundFirstSection = false;
    
    for (String line in lines) {
      if (line.startsWith('## ')) {
        if (foundFirstSection) break; // Stop at second section
        foundFirstSection = true;
      }
      if (foundFirstSection) {
        latestSection.add(line);
      }
    }
    
    return latestSection.join('\n');
  }
}
