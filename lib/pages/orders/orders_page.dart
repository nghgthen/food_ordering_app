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
  final Set<String> _expandedOrders = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<OrdersProvider>(context, listen: false).fetchOrders());
  }

  // Helper method để lấy localization an toàn
  String _translate(BuildContext context, String key) {
    try {
      final loc = AppLocalizations.of(context);
      return loc?.t(key) ?? key;
    } catch (e) {
      return key; // Fallback to key nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/foods/logo.png',
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'The Best Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            );
          },
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
            return _buildEmptyOrders(context);
          }

          return RefreshIndicator(
            onRefresh: () => ordersProvider.fetchOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ordersProvider.orders.length,
              itemBuilder: (context, index) {
                final order = ordersProvider.orders[index];
                final orderId = order['id'].toString();
                final isExpanded = _expandedOrders.contains(orderId);
                
                return _buildOrderCard(order, context, isExpanded, orderId);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có đơn hàng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Đơn hàng của bạn sẽ hiển thị tại đây',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, BuildContext context, 
                        bool isExpanded, String orderId) {
    final status = order['status']?.toString().toLowerCase() ?? 'pending';
    final canConfirm = status == 'processing' || status == 'shipped';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedOrders.remove(orderId);
            } else {
              _expandedOrders.add(orderId);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: _getStatusColor(status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order['id']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(order['created_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Total Amount
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined, 
                            size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${_getItemCount(order)} món',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_formatPrice(order['total_amount'])} VNĐ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Expanded Details
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _buildExpandedContent(order, context, canConfirm),
                crossFadeState: isExpanded 
                    ? CrossFadeState.showSecond 
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              // Expand/Collapse Button
              const SizedBox(height: 12),
              Center(
                child: Icon(
                  isExpanded 
                      ? Icons.keyboard_arrow_up 
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(Map<String, dynamic> order, BuildContext context, bool canConfirm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 16),

        // Payment Info
        _buildInfoRow(
          Icons.payment,
          'Phương thức thanh toán',
          _getPaymentMethodText(order['payment_method']?.toString() ?? 'cash'),
        ),
        const SizedBox(height: 12),

        // Shipping Address
        _buildInfoRow(
          Icons.location_on_outlined,
          'Địa chỉ giao hàng',
          order['shipping_address'] ?? 'Chưa xác định',
        ),
        const SizedBox(height: 16),
        
        const Divider(),
        const SizedBox(height: 16),

        // Order Items
        Row(
          children: [
            Icon(Icons.receipt_long, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              'Chi tiết đơn hàng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._buildOrderItems(order['items'] ?? order['order_items']),

        // Confirm Receipt Button
        if (canConfirm) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmReceipt(order),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Xác Nhận Đã Nhận Hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildOrderItems(dynamic items) {
    if (items == null || items is! List || items.isEmpty) {
      return [const Text('Không có món')];
    }

    return items.map<Widget>((item) {
      final foodName = item['food']?['name'] ?? 
                       item['name'] ?? 
                       'Món không xác định';
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${item['quantity'] ?? 1}x',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                foodName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Text(
              '${_formatPrice(item['price'])} VNĐ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _confirmReceipt(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Xác Nhận Nhận Hàng'),
          ],
        ),
        content: Text(
          'Bạn đã nhận được Đơn hàng #${order['id']}?\n\nHành động này sẽ đánh dấu đơn hàng là đã hoàn thành.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác Nhận'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await Provider.of<OrdersProvider>(context, listen: false)
            .updateOrderStatus(order['id'], 'completed');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Xác nhận đơn hàng thành công!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  int _getItemCount(Map<String, dynamic> order) {
    final items = order['items'] ?? order['order_items'];
    if (items is List) {
      return items.fold<int>(0, (sum, item) => sum + (item['quantity'] as int? ?? 1));
    }
    return 0;
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    try {
      final numPrice = price is String ? double.parse(price) : price.toDouble();
      return numPrice.toStringAsFixed(0);
    } catch (e) {
      return price.toString();
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date.toString();
    }
  }

  String _getPaymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Thanh toán khi nhận hàng';
      case 'card':
        return 'Thẻ tín dụng/Ghi nợ';
      default:
        return method.toUpperCase();
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.autorenew;
      case 'shipped':
        return Icons.local_shipping;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'ĐÃ HOÀN THÀNH';
      case 'processing':
        return 'ĐANG XỬ LÝ';
      case 'shipped':
        return 'ĐANG GIAO';
      case 'cancelled':
        return 'ĐÃ HỦY';
      default:
        return 'CHỜ XỬ LÝ';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}