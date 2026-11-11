import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _defaultBaseUrl = 'http://10.0.2.2:5055';
  String _baseUrl = _defaultBaseUrl;
  String? _token;

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('sstpa_base_url') ?? _defaultBaseUrl;
    _token = prefs.getString('sstpa_jwt_token');
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.replaceAll(RegExp(r'/$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sstpa_base_url', _baseUrl);
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('sstpa_jwt_token', token);
    } else {
      await prefs.remove('sstpa_jwt_token');
    }
  }

  Map<String, String> _headers() {
    final h = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  // --- AUTHENTICATION ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/api/users/login');
    final res = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    ).timeout(const Duration(seconds: 12));

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 && data['token'] != null) {
      await setToken(data['token']);
      return data;
    }
    throw Exception(data['error'] ?? 'Login failed (${res.statusCode})');
  }

  Future<void> logout() async {
    await setToken(null);
  }

  // --- DASHBOARD / STATS ---
  Future<DashboardStats> getDashboardStats() async {
    try {
      final url = Uri.parse('$_baseUrl/api/reports/dashboard-stats');
      final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return DashboardStats.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return DashboardStats();
  }

  // --- MEMBERS ---
  Future<List<MemberModel>> getMembers() async {
    final url = Uri.parse('$_baseUrl/api/members');
    final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => MemberModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load members (${res.statusCode})');
  }

  Future<bool> addMember(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/api/members');
    final res = await http.post(url, headers: _headers(), body: jsonEncode(payload));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // --- EVENTS ---
  Future<List<EventModel>> getEvents() async {
    // Prefer authenticated if available, else public
    final endpoint = isAuthenticated ? '/api/events' : '/api/events/public/all';
    final url = Uri.parse('$_baseUrl$endpoint');
    final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => EventModel.fromJson(item)).toList();
    }
    throw Exception('Failed to load events');
  }

  Future<bool> addEvent(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/api/events');
    final res = await http.post(url, headers: _headers(), body: jsonEncode(payload));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // --- NOTICES ---
  Future<List<NoticeModel>> getNotices() async {
    final url = Uri.parse('$_baseUrl/api/event-notices/public');
    final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => NoticeModel.fromJson(item)).toList();
    }
    return [];
  }

  // --- EXPENSES ---
  Future<List<ExpenseModel>> getExpenses() async {
    final url = Uri.parse('$_baseUrl/api/reports/expenses-list');
    final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => ExpenseModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<bool> addExpense(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_baseUrl/api/reports/expenses-list');
    final res = await http.post(url, headers: _headers(), body: jsonEncode(payload));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  // --- COORDINATORS ---
  Future<List<CoordinatorModel>> getCoordinators() async {
    final url = Uri.parse('$_baseUrl/api/coordinators/public');
    final res = await http.get(url, headers: _headers()).timeout(const Duration(seconds: 10));
    if (res.statusCode == 200) {
      final List list = jsonDecode(res.body);
      return list.map((item) => CoordinatorModel.fromJson(item)).toList();
    }
    return [];
  }
}
