import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/font_provider.dart';
import 'providers/food_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/orders_provider.dart'; // ✅ thêm import
import 'services/food_service.dart';
import 'pages/home/home_page.dart';
import 'pages/orders/orders_page.dart';
import 'pages/cart/cart_page.dart';
import 'pages/settings/settings_page.dart';
import 'pages/auth/login_page.dart';
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
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()), // ✅ thêm OrdersProvider
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
  int _currentIndex = 0;
  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final localeProv = context.watch<LocaleProvider>();
    final fontProv = context.watch<FontProvider>();

    final screens = [
      const HomePage(),
      const OrdersPage(),
      const CartPage(),
      const SettingsPage(),
    ];

    return MaterialApp(
      title: 'Food Ordering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(fontSizeFactor: fontProv.scale),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFE53935),
          unselectedItemColor: Colors.grey,
          elevation: 8.0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: fontProv.scale),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.grey[900],
          selectedItemColor: const Color(0xFFE53935),
          unselectedItemColor: Colors.grey[600],
          elevation: 8.0,
        ),
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
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 8.0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          onTap: (index) => _onTabTapped(index, context, auth),
          items: [
            _buildNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: AppLocalizations.of(context)?.t('home') ?? 'Home',
            ),
            _buildNavItem(
              icon: Icons.list_alt_outlined,
              activeIcon: Icons.list_alt,
              label: AppLocalizations.of(context)?.t('orders') ?? 'Orders',
              requiresAuth: true,
              isLoggedIn: auth.isLoggedIn,
            ),
            _buildNavItem(
              icon: Icons.shopping_cart_outlined,
              activeIcon: Icons.shopping_cart,
              label: AppLocalizations.of(context)?.t('cart') ?? 'Cart',
              badge: cart.items.isNotEmpty ? cart.items.length.toString() : null,
              requiresAuth: true,
              isLoggedIn: auth.isLoggedIn,
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              activeIcon: Icons.settings,
              label: AppLocalizations.of(context)?.t('settings') ?? 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    String? badge,
    bool requiresAuth = false,
    bool isLoggedIn = true,
  }) {
    Color? iconColor = requiresAuth && !isLoggedIn ? Colors.grey : null;

    return BottomNavigationBarItem(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: iconColor),
          if (requiresAuth && !isLoggedIn)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, size: 10, color: Colors.white),
              ),
            ),
          if (badge != null && badge.isNotEmpty)
            Positioned(
              right: -8,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      activeIcon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(activeIcon, color: requiresAuth && !isLoggedIn ? Colors.grey : const Color(0xFFE53935)),
          if (requiresAuth && !isLoggedIn)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock, size: 10, color: Colors.white),
              ),
            ),
          if (badge != null && badge.isNotEmpty)
            Positioned(
              right: -8,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }

  Future<void> _onTabTapped(int index, BuildContext context, AuthProvider auth) async {
    // Prevent double tap
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastTapTime = now;

    // Check if the tab requires authentication (Orders = 1, Cart = 2)
    if ((index == 1 || index == 2) && !auth.isLoggedIn) {
      // Show login dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)?.t('login_required') ?? 'Login Required'),
          content: Text(AppLocalizations.of(context)?.t('login_to_continue') ?? 'Please login to access this feature'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)?.t('cancel') ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)?.t('login') ?? 'Login'),
            ),
          ],
        ),
      );

      if (result == true) {
        // Navigate to login page
        final loginResult = await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );

        // If login was successful, navigate to the desired tab
        if (loginResult == true && mounted) {
          setState(() => _currentIndex = index);
        }
      }
      return;
    }

    setState(() => _currentIndex = index);
  }
}
