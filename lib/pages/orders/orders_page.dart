import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';
import '../../l10n/app_localizations.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrdersProvider>(context, listen: false).fetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

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
      body: Consumer<OrdersProvider>(
        builder: (context, ordersProvider, child) {
          if (ordersProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ordersProvider.orders.isEmpty) {
            return _buildEmptyOrders(loc);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ordersProvider.orders.length,
            itemBuilder: (context, index) {
              final order = ordersProvider.orders[index];
              debugPrint("📦 Order[$index] = $order");
              return _buildOrderCard(order, loc);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            loc.t('No orders found'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            loc.t('Your orders will appear here'),
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, AppLocalizations loc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Chip(
                  label: Text(
                    order['status']?.toString().toUpperCase() ?? 'PENDING',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(order['status']),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "\$${order['total_amount'] ?? '0'}", // ✅ giữ USD
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Payment method
            Text(
                'Payment: ${order['payment_method']?.toString().toUpperCase() ?? 'CASH'}'),
            const SizedBox(height: 6),

            // Shipping address
            Text('Address: ${order['shipping_address'] ?? 'Not specified'}'),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 6),

            // Order items
            Text(
              'Items:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            ..._buildOrderItems(
              order['items'] ?? order['order_items'], // fallback key
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrderItems(dynamic items) {
    if (items == null || items is! List || items.isEmpty) {
      return [const Text('No items')];
    }

    return items.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text('• ${item['quantity']}x ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: Text(item['name'] ?? 'Unknown item'),
            ),
            Text(
              "\$${item['price'] ?? 0}", // ✅ giữ USD
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
