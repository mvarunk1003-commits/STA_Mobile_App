import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final stats = provider.stats;
    final currency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade800, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.indigo.withAlpha(80), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.amber.shade400,
                    child: Text(
                      (provider.user?.username ?? 'U')[0].toUpperCase(),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo.shade900),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${provider.user?.username ?? 'Guest'}',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            provider.user?.roleDisplay ?? 'Member',
                            style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.sync, color: Colors.white70),
                    onPressed: provider.refreshAll,
                    tooltip: 'Sync Data',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section: Organization KPI Metrics
            const Text('Executive Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildMetricCard(
                  icon: Icons.people_alt,
                  color: Colors.blue.shade700,
                  title: 'Total Members',
                  value: stats.totalMembers > 0 ? '${stats.totalMembers}' : '${provider.members.length}',
                  onTap: () => provider.setTab(1),
                ),
                _buildMetricCard(
                  icon: Icons.event_available,
                  color: Colors.deepOrange.shade600,
                  title: 'Active Events',
                  value: '${provider.events.length}',
                  onTap: () => provider.setTab(2),
                ),
                _buildMetricCard(
                  icon: Icons.account_balance_wallet,
                  color: Colors.teal.shade700,
                  title: 'Net Balance',
                  value: currency.format(stats.balance),
                  onTap: () => provider.setTab(4),
                ),
                _buildMetricCard(
                  icon: Icons.badge,
                  color: Colors.purple.shade700,
                  title: 'Coordinators',
                  value: '${provider.coordinators.length}',
                  onTap: () => provider.setTab(4),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text('Operational Shortcuts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.person_add_alt_1,
                    label: 'Add Member',
                    color: Colors.blue,
                    onTap: () => provider.setTab(1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.post_add,
                    label: 'New Event',
                    color: Colors.deepOrange,
                    onTap: () => provider.setTab(2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    icon: Icons.receipt_long,
                    label: 'Add Expense',
                    color: Colors.teal,
                    onTap: () => provider.setTab(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Announcements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Official Notices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => provider.setTab(3),
                  child: const Text('View All'),
                ),
              ],
            ),
            if (provider.notices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No active notices at this moment', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ...provider.notices.take(3).map((notice) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber.shade100,
                        child: Icon(Icons.campaign, color: Colors.amber.shade900),
                      ),
                      title: Text(notice.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(
                        '${notice.organization} • ${notice.eventDate}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () => provider.setTab(3),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color.withAlpha(25),
              child: Icon(icon, size: 18, color: color),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: color.shade700, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.shade900),
            ),
          ],
        ),
      ),
    );
  }
}
