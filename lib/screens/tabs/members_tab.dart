import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  String _searchQuery = '';

  void _showAddMemberDialog(BuildContext context, AppProvider provider) {
    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstCtrl,
                decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastCtrl,
                decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (firstCtrl.text.trim().isEmpty || lastCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter first and last name')),
                );
                return;
              }
              final ok = await provider.createMember(
                firstCtrl.text.trim(),
                lastCtrl.text.trim(),
                phoneCtrl.text.trim(),
                emailCtrl.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Member added successfully!')),
                );
              }
            },
            child: const Text('Save Member'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final members = provider.members.where((m) {
      final q = _searchQuery.toLowerCase();
      return m.fullName.toLowerCase().contains(q) ||
          (m.phone != null && m.phone!.contains(q)) ||
          (m.email != null && m.email!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Member List
          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.refreshAll,
              child: members.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? 'No members in directory' : 'No matching members found',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: members.length,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemBuilder: (context, index) {
                        final m = members[index];
                        final active = m.status.toLowerCase() == 'active';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 1.5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                m.firstName.isNotEmpty ? m.firstName[0].toUpperCase() : 'M',
                                style: TextStyle(color: Colors.indigo.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(m.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (m.phone != null && m.phone!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(m.phone!, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                if (m.email != null && m.email!.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(m.email!, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: active ? Colors.green.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: active ? Colors.green.shade200 : Colors.grey.shade300),
                              ),
                              child: Text(
                                m.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: active ? Colors.green.shade800 : Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo.shade800,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Member', style: TextStyle(color: Colors.white)),
        onPressed: () => _showAddMemberDialog(context, provider),
      ),
    );
  }
}
