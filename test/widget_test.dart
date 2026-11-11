import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/models.dart';

void main() {
  test('UserModel deserialization test', () {
    final user = UserModel.fromJson({
      'id': 1,
      'username': 'admin',
      'email': 'admin@sstpa.org',
      'role': 'admin',
    });
    expect(user.id, 1);
    expect(user.username, 'admin');
    expect(user.roleDisplay, 'Apex Administrator');
  });

  test('DashboardStats deserialization test', () {
    final stats = DashboardStats.fromJson({
      'balance': 50000.0,
      'total_members': 120,
      'total_events': 15,
      'total_sponsorships': 80000.0,
      'total_expenses': 30000.0,
    });
    expect(stats.balance, 50000.0);
    expect(stats.totalMembers, 120);
    expect(stats.totalEvents, 15);
  });
}
