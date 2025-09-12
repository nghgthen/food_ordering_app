import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/font_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onLogoutPressed;

  const SettingsPage({
    super.key,
    this.onLoginPressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final theme = Provider.of<ThemeProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final font = Provider.of<FontProvider>(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('settings'))),
      body: FutureBuilder<bool>(
        future: auth.isLoggedIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final isLoggedIn = snapshot.data ?? false;
          
          return ListView(
            children: [
              FutureBuilder<String?>(
                future: auth.userEmail,
                builder: (context, emailSnapshot) {
                  final email = emailSnapshot.data;
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(email ?? loc.t('not_logged')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(isLoggedIn ? Icons.logout : Icons.login),
                title: Text(isLoggedIn ? loc.t('logout') : loc.t('login')),
                onTap: () {
                  if (isLoggedIn) {
                    auth.logout().then((_) => onLogoutPressed?.call());
                  } else {
                    onLoginPressed?.call();
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
          );
        },
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
            children: ['en', 'vi', 'es', 'fr'].map((code) {
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