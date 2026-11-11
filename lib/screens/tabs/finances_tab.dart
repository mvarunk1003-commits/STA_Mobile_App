import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class FinancesTab extends StatefulWidget {
  const FinancesTab({super.key});

  @override
  State<FinancesTab> createState() => _FinancesTabState();
}

class _FinancesTabState extends State<FinancesTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseDialog(BuildContext context, AppProvider provider) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Logistics');
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now()));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record New Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Title / Description *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹) *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: catCtrl,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (titleCtrl.text.trim().isEmpty || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid title and amount')),
                );
                return;
              }
              final ok = await provider.createExpense(
                titleCtrl.text.trim(),
                amount,
                catCtrl.text.trim(),
                dateCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense recorded successfully!')),
                );
              }
            },
            child: const Text('Save Expense'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.indigo.shade900,
            indicatorColor: Colors.indigo.shade900,
            tabs: const [
              Tab(icon: Icon(Icons.account_balance_wallet, size: 18), text: 'Finances & Expenses'),
              Tab(icon: Icon(Icons.people_outline, size: 18), text: 'Coordinators'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Section 1: Expenses
          RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Net Balance Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade800, Colors.teal.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Total Treasury Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        currency.format(provider.stats.balance),
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Inflow / Sponsors', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text(
                                currency.format(provider.stats.totalIncome),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Container(height: 24, width: 1, color: Colors.white30),
                          Column(
                            children: [
                              const Text('Total Expenses', style: TextStyle(color: Colors.white60, fontSize: 11)),
                              Text(
                                currency.format(provider.stats.totalExpense),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Vouchers & Expenses', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                      onPressed: () => _showAddExpenseDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (provider.expenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No recorded expenses found', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ...provider.expenses.map((e) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade50,
                            child: Icon(Icons.receipt, color: Colors.teal.shade700),
                          ),
                          title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${e.category} • ${e.date}', style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                            currency.format(e.amount),
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )),
              ],
            ),
          ),

          // Section 2: Coordinators Directory
          RefreshIndicator(
            onRefresh: provider.refreshAll,
            child: provider.coordinators.isEmpty
                ? const Center(
                    child: Text('No coordinators directory available', style: TextStyle(color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: provider.coordinators.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final c = provider.coordinators[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.purple.shade50,
                                    child: Icon(Icons.badge, color: Colors.purple.shade700),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.coordinatorName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          c.role.replaceAll('_', ' ').toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.purple.shade800,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.map_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${c.taluk.isNotEmpty ? '${c.taluk}, ' : ''}${c.district}, ${c.state}',
                                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              if (c.phone != null && c.phone!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Text(c.phone!, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                              if (c.email != null && c.email!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(c.email!, style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
