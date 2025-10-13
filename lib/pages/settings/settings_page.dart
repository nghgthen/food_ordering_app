import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/font_provider.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final font = Provider.of<FontProvider>(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('settings'))),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(auth.email ?? loc.t('not_logged')),
          ),
          const Divider(),
          ListTile(
            leading: Icon(auth.isLoggedIn ? Icons.logout : Icons.login),
            title: Text(auth.isLoggedIn ? loc.t('logout') : loc.t('login')),
            onTap: () async {
              if (auth.isLoggedIn) {
                await auth.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.t('logged_out'))),
                  );
                }
              } else {
                final res = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
                if (res == true && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.t('login_success'))),
                  );
                }
              }
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(loc.t('dark_mode')),
            value: theme.isDark,
            onChanged: (v) => theme.setDark(v),
            secondary: const Icon(Icons.dark_mode),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              '${loc.t('language')}: ${locale.locale.languageCode.toUpperCase()}',
            ),
            onTap: () => _showLangDialog(context, locale),
          ),
          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(loc.t('font_size')),
            subtitle: Slider(
              value: font.scale,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              onChanged: (v) => font.setScale(v),
            ),
          ),
        ],
      ),
    );
  }

  void _showLangDialog(BuildContext context, LocaleProvider locale) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.t('language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['vi', 'en', 'es', 'fr'].map((code) {
              return ListTile(
                title: Text(code.toUpperCase()),
                onTap: () {
                  locale.setLocale(Locale(code));
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
