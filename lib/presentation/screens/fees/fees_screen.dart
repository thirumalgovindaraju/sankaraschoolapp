// lib/presentation/screens/fees/fees_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({Key? key}) : super(key: key);

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _feeRecords = [
    {
      'student_id': 'S001',
      'student_name': 'Rajesh Kumar',
      'class': '10-A',
      'total_fee': 50000.0,
      'paid': 35000.0,
      'pending': 15000.0,
      'last_payment': DateTime.now().subtract(const Duration(days: 15)),
      'status': 'Partial',
    },
    {
      'student_id': 'S002',
      'student_name': 'Priya Sharma',
      'class': '10-B',
      'total_fee': 50000.0,
      'paid': 50000.0,
      'pending': 0.0,
      'last_payment': DateTime.now().subtract(const Duration(days: 30)),
      'status': 'Paid',
    },
    {
      'student_id': 'S003',
      'student_name': 'Amit Singh',
      'class': '9-A',
      'total_fee': 45000.0,
      'paid': 20000.0,
      'pending': 25000.0,
      'last_payment': DateTime.now().subtract(const Duration(days: 60)),
      'status': 'Partial',
    },
    {
      'student_id': 'S004',
      'student_name': 'Sneha Patel',
      'class': '11-A',
      'total_fee': 55000.0,
      'paid': 0.0,
      'pending': 55000.0,
      'last_payment': null,
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fee Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Payments'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPaymentsTab(),
          _buildPendingTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.payment),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final totalFees = _feeRecords.fold<double>(0, (sum, record) => sum + record['total_fee']);
    final totalPaid = _feeRecords.fold<double>(0, (sum, record) => sum + record['paid']);
    final totalPending = _feeRecords.fold<double>(0, (sum, record) => sum + record['pending']);
    final collectionRate = (totalPaid / totalFees * 100).toStringAsFixed(1);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Fees',
                  '₹${_formatAmount(totalFees)}',
                  Icons.account_balance_wallet,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Collected',
                  '₹${_formatAmount(totalPaid)}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  '₹${_formatAmount(totalPending)}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Collection Rate',
                  '$collectionRate%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fee Structure
          Text(
            'Fee Structure',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildFeeStructureCard(),

          const SizedBox(height: 24),

          // Recent Transactions
          Text(
            'Recent Transactions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._feeRecords.take(3).map((record) => _buildTransactionCard(record)),
        ],
      ),
    );
  }

  Widget _buildPaymentsTab() {
    final paidRecords = _feeRecords.where((r) => r['paid'] > 0).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paidRecords.length,
      itemBuilder: (context, index) {
        return _buildPaymentCard(paidRecords[index]);
      },
    );
  }

  Widget _buildPendingTab() {
    final pendingRecords = _feeRecords.where((r) => r['pending'] > 0).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pendingRecords.length,
      itemBuilder: (context, index) {
        return _buildPendingCard(pendingRecords[index]);
      },
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeStructureCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFeeItem('Tuition Fee', 25000),
            _buildFeeItem('Lab Fee', 5000),
            _buildFeeItem('Library Fee', 3000),
            _buildFeeItem('Sports Fee', 2000),
            _buildFeeItem('Development Fee', 10000),
            const Divider(height: 24),
            _buildFeeItem('Total', 45000, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${_formatAmount(amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? Colors.blue : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(record['status']).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(record['status']),
            color: _getStatusColor(record['status']),
            size: 20,
          ),
        ),
        title: Text(
          record['student_name'],
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          '${record['class']} • ${record['status']}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${_formatAmount(record['paid'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.green,
              ),
            ),
            if (record['pending'] > 0)
              Text(
                '₹${_formatAmount(record['pending'])} pending',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record['student_name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${record['student_id']} • ${record['class']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(record['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record['status'],
                    style: TextStyle(
                      color: _getStatusColor(record['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountDetail('Total', record['total_fee'], Colors.blue),
                _buildAmountDetail('Paid', record['paid'], Colors.green),
                _buildAmountDetail('Pending', record['pending'], Colors.orange),
              ],
            ),
            if (record['last_payment'] != null) ...[
              const SizedBox(height: 12),
              Text(
                'Last Payment: ${DateFormat('MMM dd, yyyy').format(record['last_payment'])}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> record) {
    return _buildPaymentCard(record);
  }

  Widget _buildAmountDetail(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${_formatAmount(amount)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Partial':
        return Colors.orange;
      case 'Pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle;
      case 'Partial':
        return Icons.access_time;
      case 'Pending':
        return Icons.pending;
      default:
        return Icons.info;
    }
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Payment'),
        content: const Text('Payment recording form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment recorded successfully')),
              );
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );
  }
}