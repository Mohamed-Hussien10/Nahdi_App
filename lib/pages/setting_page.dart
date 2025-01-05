import 'package:flutter/material.dart';
import 'package:nahdy/components/app_localizations.dart';
import 'package:nahdy/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context).translate;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t("settings"),
          style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.teal),
              title: Text(
                t("privacy_policy"),
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () {
                _launchPrivacyPolicy();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language, color: Colors.teal),
              title: Text(
                t("language"),
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? t("arabic")
                      : t("english")),
              onTap: () {
                _showLanguageDialog(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.teal),
              title: Text(
                t("app_version"),
                style: const TextStyle(fontSize: 18),
              ),
              subtitle: const Text("1.0.0"),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    var t = AppLocalizations.of(context).translate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t("select_language")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(t("english")),
              onTap: () {
                _changeLanguage(context, const Locale('en'));
              },
            ),
            ListTile(
              title: Text(t("arabic")),
              onTap: () {
                _changeLanguage(context, const Locale('ar'));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, Locale newLocale) async {
    // Save the selected language to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', newLocale.languageCode);

    // Change the app locale
    MyApp.of(context).setLocale(newLocale);
    Navigator.pop(context); // Close the dialog
  }

  // Function to launch the privacy policy link
  Future<void> _launchPrivacyPolicy() async {
    const url =
        'https://www.privacypolicies.com/live/007a32f5-c9c9-4c86-a5df-37d12254826b';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
