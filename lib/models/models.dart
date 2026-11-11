class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;

  UserModel({required this.id, required this.username, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  String get roleDisplay {
    switch (role) {
      case 'admin': return 'Apex Administrator';
      case 'state_coordinator': return 'State Coordinator';
      case 'district_coordinator': return 'District Coordinator';
      case 'taluk_coordinator': return 'Taluk Coordinator';
      default: return 'Member';
    }
  }
}

class DashboardStats {
  final int totalMembers;
  final int totalEvents;
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int totalCoordinators;

  DashboardStats({
    this.totalMembers = 0,
    this.totalEvents = 0,
    this.totalIncome = 0.0,
    this.totalExpense = 0.0,
    this.balance = 0.0,
    this.totalCoordinators = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final balanceNum = json['balance'] ?? 0;
    final incomeNum = json['total_sponsorships'] ?? json['totalIncome'] ?? 0;
    final expenseNum = json['total_expenses'] ?? json['totalExpense'] ?? 0;
    return DashboardStats(
      totalMembers: json['total_members'] ?? json['members_count'] ?? 0,
      totalEvents: json['total_events'] ?? json['events_count'] ?? 0,
      totalIncome: (incomeNum as num).toDouble(),
      totalExpense: (expenseNum as num).toDouble(),
      balance: (balanceNum as num).toDouble(),
      totalCoordinators: json['total_coordinators'] ?? json['coordinators_count'] ?? 0,
    );
  }
}

class MemberModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String status;
  final String? joinDate;

  MemberModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    required this.status,
    this.joinDate,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      email: json['email'],
      phone: json['phone'],
      status: json['status'] ?? 'active',
      joinDate: json['join_date'] ?? json['joinDate'],
    );
  }
}

class EventModel {
  final int id;
  final String title;
  final String? description;
  final String date;
  final String? location;
  final double budget;
  final String status;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    this.location,
    required this.budget,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final b = json['budget'] ?? 0;
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      date: json['date'] ?? '',
      location: json['location'],
      budget: (b as num).toDouble(),
      status: json['status'] ?? 'approved',
    );
  }
}

class NoticeModel {
  final int id;
  final String title;
  final String organization;
  final String eventDescription;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final String chairperson;
  final String contactInfo;

  NoticeModel({
    required this.id,
    required this.title,
    required this.organization,
    required this.eventDescription,
    required this.eventDate,
    required this.eventTime,
    required this.eventVenue,
    required this.chairperson,
    required this.contactInfo,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      organization: json['organization'] ?? 'SSTPA Central Committee',
      eventDescription: json['event_description'] ?? '',
      eventDate: json['event_date'] ?? '',
      eventTime: json['event_time'] ?? '',
      eventVenue: json['event_venue'] ?? '',
      chairperson: json['chairperson'] ?? '',
      contactInfo: json['contact_info'] ?? '',
    );
  }
}

class ExpenseModel {
  final int id;
  final String title;
  final double amount;
  final String category;
  final String date;
  final String status;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.status,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final a = json['amount'] ?? 0;
    return ExpenseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      amount: (a as num).toDouble(),
      category: json['category'] ?? 'General',
      date: json['date'] ?? '',
      status: json['status'] ?? 'approved',
    );
  }
}

class CoordinatorModel {
  final int id;
  final String state;
  final String district;
  final String taluk;
  final String coordinatorName;
  final String role;
  final String? phone;
  final String? email;

  CoordinatorModel({
    required this.id,
    required this.state,
    required this.district,
    required this.taluk,
    required this.coordinatorName,
    required this.role,
    this.phone,
    this.email,
  });

  factory CoordinatorModel.fromJson(Map<String, dynamic> json) {
    return CoordinatorModel(
      id: json['id'] ?? 0,
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      taluk: json['taluk'] ?? '',
      coordinatorName: json['coordinator_name'] ?? json['name'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      email: json['email'],
    );
  }
}
