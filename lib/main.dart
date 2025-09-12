import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/font_provider.dart';
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'services/food_service.dart';
import 'pages/home/home_page.dart';
import 'pages/orders/orders_page.dart';
import 'pages/cart/cart_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/auth/login_page.dart';
import 'services/auth_service.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => FoodProvider(foodService: FoodService())),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});
  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final AuthService _auth = AuthService();
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomePage(),
      const OrdersPage(),
      const CartPage(),
      SettingsPage(
        onLoginPressed: () => _openLogin(context),
        onLogoutPressed: _handleLogout,
      ),
    ];
  }

  Future<void> _openLogin(BuildContext context) async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
    if (!mounted) return;
    if (res == true) setState(() {});
  }

  Future<void> _handleLogout() async {
    await _auth.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final localeProv = Provider.of<LocaleProvider>(context);
    final fontProv = Provider.of<FontProvider>(context);

    return MaterialApp(
      title: 'Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: fontProv.scale),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: fontProv.scale),
      ),
      themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: localeProv.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('es'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder<String?>(
        future: _auth.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Nếu có token thì load Home với navigation
          if (snapshot.data != null) {
            return Scaffold(
              body: _screens[_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.grey,
                onTap: (index) => setState(() => _currentIndex = index),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: AppLocalizations.of(context).t('home') ?? 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.list_alt),
                    label: AppLocalizations.of(context).t('orders') ?? 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.shopping_cart),
                    label: AppLocalizations.of(context).t('cart') ?? 'Cart',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.settings),
                    label: AppLocalizations.of(context).t('settings') ?? 'Settings',
                  ),
                ],
              ),
            );
          }

          // Nếu chưa có token → vào LoginPage luôn
          return const LoginPage();
        },
      ),
    );
  }
}