import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});

  void _showAddEventDialog(BuildContext context, AppProvider provider) {
    final titleCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 7))));
    final locationCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule New Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Event Title *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD) *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: 'Venue / Location', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Budget (₹)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Description / Purpose', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty || dateCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter event title and date')),
                );
                return;
              }
              final budget = double.tryParse(budgetCtrl.text.trim()) ?? 0.0;
              final ok = await provider.createEvent(
                titleCtrl.text.trim(),
                dateCtrl.text.trim(),
                locationCtrl.text.trim(),
                budget,
                descCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event submitted successfully!')),
                );
              }
            },
            child: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final events = provider.events;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: events.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No scheduled events found', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: events.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final ev = events[index];
                  final isApproved = ev.status.toLowerCase() == 'approved';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  ev.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isApproved ? Colors.green.shade50 : Colors.amber.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isApproved ? Colors.green.shade300 : Colors.amber.shade300,
                                  ),
                                ),
                                child: Text(
                                  ev.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isApproved ? Colors.green.shade800 : Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 14, color: Colors.indigo.shade600),
                              const SizedBox(width: 6),
                              Text(ev.date, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 16),
                              if (ev.location != null && ev.location!.isNotEmpty) ...[
                                Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ev.location!,
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (ev.description != null && ev.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              ev.description!,
                              style: const TextStyle(color: Colors.black87, fontSize: 13),
                            ),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget: ${currency.format(ev.budget)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                              Text(
                                'ID: #${ev.id}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Event', style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddEventDialog(context, provider),
      ),
    );
  }
}
