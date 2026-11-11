import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/members_tab.dart';
import 'tabs/events_tab.dart';
import 'tabs/notices_tab.dart';
import 'tabs/finances_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Widget> _tabs = [
    DashboardTab(),
    MembersTab(),
    EventsTab(),
    NoticesTab(),
    FinancesTab(),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Members Directory',
    'Events Management',
    'Official Circulars',
    'Treasury & Coordinators',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, size: 20, color: Colors.indigo),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'STPA',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
            ),
            Text(
              _titles[provider.currentTab],
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Live Data',
            onPressed: provider.isLoading ? null : provider.refreshAll,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out from SSTPA Portal?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading && provider.events.isEmpty && provider.members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _tabs[provider.currentTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.currentTab,
        onDestinationSelected: provider.setTab,
        elevation: 4,
        indicatorColor: Colors.amber.shade200,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Colors.indigo),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: Colors.indigo),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event, color: Colors.indigo),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article, color: Colors.indigo),
            label: 'Circulars',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: Colors.indigo),
            label: 'Accounts',
          ),
        ],
      ),
    );
  }
}
