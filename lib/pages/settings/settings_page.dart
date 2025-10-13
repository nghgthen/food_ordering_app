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
    final isDark = theme.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('settings')),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader(context, loc.t('account'), isDark),
            _buildAccountCard(context, auth, loc, isDark),
            SizedBox(height: 24),

            // Display Section
            _buildSectionHeader(context, loc.t('display'), isDark),
            _buildDisplayCard(context, theme, font, locale, loc, isDark),
            SizedBox(height: 24),

            // Language Section
            _buildSectionHeader(context, loc.t('language'), isDark),
            _buildLanguageCard(context, locale, loc, isDark),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  Widget _buildAccountCard(
      BuildContext context, AuthProvider auth, AppLocalizations loc, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('email'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          auth.email ?? loc.t('not_logged'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        auth.isLoggedIn ? Icons.logout : Icons.login,
                        size: 20,
                        color: auth.isLoggedIn ? Colors.red : Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        auth.isLoggedIn ? loc.t('logout') : loc.t('login'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: auth.isLoggedIn ? Colors.red : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayCard(
      BuildContext context,
      ThemeProvider theme,
      FontProvider font,
      LocaleProvider locale,
      AppLocalizations loc,
      bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        child: Column(
          children: [
            _buildCardOption(
              context,
              Icons.dark_mode,
              loc.t('dark_mode'),
              isDark,
              isFirst: true,
              widget: Switch(
                value: theme.isDark,
                onChanged: (v) => theme.setDark(v),
              ),
            ),
            Divider(height: 1, indent: 16, endIndent: 16),
            _buildCardOption(
              context,
              Icons.format_size,
              loc.t('font_size'),
              isDark,
              widget: SizedBox(
                width: 150,
                child: Row(
                  children: [
                    Text('A', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: font.scale,
                        min: 0.8,
                        max: 1.4,
                        divisions: 6,
                        onChanged: (v) => font.setScale(v),
                      ),
                    ),
                    Text('A', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, LocaleProvider locale,
      AppLocalizations loc, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLangDialog(context, locale),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.language,
                      color: Theme.of(context).primaryColor,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('language'),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          locale.locale.languageCode.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardOption(
    BuildContext context,
    IconData icon,
    String title,
    bool isDark, {
    Widget? widget,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 22,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (widget != null) widget,
        ],
      ),
    );
  }

  void _showLangDialog(BuildContext context, LocaleProvider locale) {
    final loc = AppLocalizations.of(context);
    final languages = {
      'en': 'English',
      'vi': 'Tiếng Việt',
      'es': 'Español',
      'fr': 'Français',
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            loc.t('language'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: languages.entries.map((entry) {
                final isSelected = locale.locale.languageCode == entry.key;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      locale.setLocale(Locale(entry.key));
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            )
                          else
                            Icon(
                              Icons.circle_outlined,
                              color: Colors.grey[400],
                              size: 20,
                            ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}