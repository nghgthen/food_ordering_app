import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../l10n/app_localizations.dart';

class CartPage extends StatelessWidget {
  final VoidCallback? onRequestLogin;
  final void Function(int)? onSwitchTab;
  const CartPage({super.key, this.onRequestLogin, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final cart = Provider.of<CartProvider>(context);
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
            appBar: AppBar(
              title: Image.asset(
                'assets/images/foods/logo.png',
                height: 40,
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    loc.t('login_prompt_cart'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: onRequestLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: Text(loc.t('login')),
                  )
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Image.asset(
              'assets/images/foods/logo.png',
              height: 40,
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          body: cart.items.isEmpty
              ? _buildEmptyCart(loc)
              : _buildCartWithItems(cart, context, loc),
        );
      },
    );
  }

  Widget _buildEmptyCart(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            loc.t('Not yet added a dish...'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            loc.t('Please add the dish...'),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCartWithItems(
      CartProvider cart, BuildContext context, AppLocalizations loc) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Text(
            'Your Food Cart',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _buildCartItem(item, cart, context);
            },
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildOrderSummary(cart, loc),
              _buildCheckoutButton(context, cart, loc),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  item.food.image.startsWith('assets/')
                      ? item.food.image
                      : 'assets/images/${item.food.image}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    if (kDebugMode) {
                      debugPrint('Lỗi tải ảnh: ${item.food.image}');
                    }
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.fastfood, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.food.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${item.food.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () => cart.updateQuantity(item.food.id, item.quantity - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => cart.updateQuantity(item.food.id, item.quantity + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, AppLocalizations loc) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("\$${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text("\$0.99",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.t('total'),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${(cart.totalPrice + 0.99).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartProvider cart, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: () => _processCheckout(context, cart, loc),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Checkout',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _processCheckout(BuildContext context, CartProvider cart, AppLocalizations loc) {
  final addressController = TextEditingController();
  String paymentMethod = "cash";
  final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Checkout'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: addressController,
            decoration: const InputDecoration(labelText: "Shipping Address"),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: paymentMethod,
            items: const [
              DropdownMenuItem(value: "cash", child: Text("Cash on Delivery")),
              DropdownMenuItem(value: "card", child: Text("Credit/Debit Card")),
            ],
            onChanged: (val) => paymentMethod = val!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(loc.t('cancel')),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(ctx);

            // ✅ Lưu lại items trước khi clear
            final orderItems = cart.items
                .map((item) => {
                      "food_id": item.food.id,
                      "quantity": item.quantity,
                      "price": item.food.price,
                    })
                .toList();

            final totalAmount = cart.totalPrice + 0.99;

            final success = await _submitOrder(
              cart,
              addressController.text,
              paymentMethod,
              context,
            );

            if (success) {
              // Update OrdersProvider trước khi clear giỏ
              ordersProvider.addOrder({
                "id": DateTime.now().millisecondsSinceEpoch,
                "total_amount": totalAmount,
                "payment_method": paymentMethod,
                "shipping_address": addressController.text,
                "status": "pending",
                "items": orderItems,
              });

              cart.clearCart();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully!')),
              );

              // Nếu có bottom nav → chuyển tab Orders
              if (onSwitchTab != null) onSwitchTab!(1);
            }
          },
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      ],
    ),
  );
}


  Future<bool> _submitOrder(CartProvider cart, String address,
      String paymentMethod, BuildContext context) async {
    final auth = AuthService();
    final token = await auth.getToken();
    final userId = await auth.getUserId();

    if (token == null || token.isEmpty) {
      debugPrint("❌ Token is null or empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid token, please login again!')),
      );
      return false;
    }

    if (userId == null) {
      debugPrint("❌ UserId is null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid user ID, please login again!')),
      );
      return false;
    }

    final url = Uri.parse("http://172.20.10.3:8000/api/orders");
    final orderData = {
      "user_id": userId,
      "total_amount": cart.totalPrice + 0.99,
      "status": "pending",
      "shipping_address": address,
      "payment_method": paymentMethod,
      "payment_status": "unpaid",
      "items": cart.items
          .map((item) => {
                "food_id": item.food.id,
                "quantity": item.quantity,
                "price": item.food.price,
              })
          .toList(),
    };

    debugPrint("📦 Sending order: $orderData");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(orderData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("✅ Order success: ${response.body}");
      return true;
    } else {
      debugPrint("❌ Order failed: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order failed!')),
      );
      return false;
    }
  }
}
