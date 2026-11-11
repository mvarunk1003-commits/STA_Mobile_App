import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class NoticesTab extends StatelessWidget {
  const NoticesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notices = provider.notices;

    return RefreshIndicator(
      onRefresh: provider.refreshAll,
      child: notices.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mark_email_unread_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('No circulars or notices published yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notices.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final n = notices[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200, width: 1.2),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Organization Header banner
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.amber.shade100,
                              child: Icon(Icons.stars, size: 16, color: Colors.amber.shade900),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                n.organization.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Text(
                              n.eventDate,
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Notice Title
                        Text(
                          n.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                        if (n.eventDescription.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            n.eventDescription,
                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Venue / Chairperson / Contact info
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (n.eventVenue.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.place, size: 14, color: Colors.red),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Venue: ${n.eventVenue}',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              if (n.chairperson.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 14, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Chairperson: ${n.chairperson}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (n.contactInfo.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.contact_phone, size: 14, color: Colors.green),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Contact: ${n.contactInfo}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
