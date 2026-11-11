import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();

  UserModel? _user;
  DashboardStats _stats = DashboardStats();
  List<MemberModel> _members = [];
  List<EventModel> _events = [];
  List<NoticeModel> _notices = [];
  List<ExpenseModel> _expenses = [];
  List<CoordinatorModel> _coordinators = [];

  bool _isLoading = false;
  String? _errorMessage;
  int _currentTab = 0;

  UserModel? get user => _user;
  DashboardStats get stats => _stats;
  List<MemberModel> get members => _members;
  List<EventModel> get events => _events;
  List<NoticeModel> get notices => _notices;
  List<ExpenseModel> get expenses => _expenses;
  List<CoordinatorModel> get coordinators => _coordinators;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentTab => _currentTab;
  bool get isLoggedIn => _user != null && api.isAuthenticated;

  Future<void> init() async {
    await api.init();
    if (api.isAuthenticated) {
      // Refresh user session / dashboard
      await refreshAll();
    }
  }

  void setTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await api.login(username, password);
      if (res['user'] != null) {
        _user = UserModel.fromJson(res['user']);
      }
      await refreshAll();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await api.logout();
    _user = null;
    _members = [];
    _events = [];
    _currentTab = 0;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        api.getDashboardStats(),
        api.getEvents(),
        api.getNotices(),
        api.getCoordinators(),
      ]);

      _stats = results[0] as DashboardStats;
      _events = results[1] as List<EventModel>;
      _notices = results[2] as List<NoticeModel>;
      _coordinators = results[3] as List<CoordinatorModel>;

      if (api.isAuthenticated) {
        try {
          _members = await api.getMembers();
        } catch (_) {}
        try {
          _expenses = await api.getExpenses();
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createMember(String firstName, String lastName, String phone, String email) async {
    final success = await api.addMember({
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email.isEmpty ? null : email,
      'status': 'active',
    });
    if (success) {
      await refreshAll();
    }
    return success;
  }

  Future<bool> createEvent(String title, String date, String location, double budget, String desc) async {
    final success = await api.addEvent({
      'title': title,
      'date': date,
      'location': location,
      'budget': budget,
      'description': desc,
    });
    if (success) {
      await refreshAll();
    }
    return success;
  }

  Future<bool> createExpense(String title, double amount, String category, String date) async {
    final success = await api.addExpense({
      'title': title,
      'amount': amount,
      'category': category,
      'date': date,
    });
    if (success) {
      await refreshAll();
    }
    return success;
  }
}
