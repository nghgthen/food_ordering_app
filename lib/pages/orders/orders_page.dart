import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../../l10n/app_localizations.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final loc = AppLocalizations.of(context);
    
    return FutureBuilder<bool>(
      future: auth.isLoggedIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final isLoggedIn = snapshot.data ?? false;
        
        if (!isLoggedIn) {
          return Scaffold(
            appBar: AppBar(title: Text(loc.t('orders'))),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(loc.t('login_prompt')),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                    child: Text(loc.t('login')),
                  )
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          appBar: AppBar(title: Text(loc.t('orders'))),
          body: const Center(child: Text('Order history (demo)')),
        );
      },
    );
  }
}