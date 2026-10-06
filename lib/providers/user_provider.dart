import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  User? _currentUser;
  bool _initializing = true;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get initializing => _initializing;

  // ───────────── Initialize ─────────────
  // Ensure the admin account exists in Firestore on startup.
  Future<void> init() async {
    try {
      final adminQuery = await _usersCollection
          .where('email', isEqualTo: 'admin@helptrack.com')
          .limit(1)
          .get();

      if (adminQuery.docs.isEmpty) {
        // Create the admin user in Firestore
        await _usersCollection.add({
          'name': 'Admin',
          'email': 'admin@helptrack.com',
          'password': 'admin123',
          'role': 'admin',
        });
      }
    } catch (_) {}
    _initializing = false;
    notifyListeners();
  }

  // ───────────── Register ─────────────
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (name.trim().isEmpty) return 'Please enter your name';
    if (!email.contains('@')) return 'Please enter a valid email';
    if (password.length < 4) return 'Password must be at least 4 characters';

    try {
      // Check if email already exists
      final existing = await _usersCollection
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return 'An account with this email already exists';
      }

      // Save new user
      final docRef = await _usersCollection.add({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'role': 'user',
      });

      _currentUser = User(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
        role: 'user',
      );
      notifyListeners();
      return null;
    } catch (e) {
      return 'Registration failed: ${e.toString()}';
    }
  }

  // ───────────── Login ─────────────
  Future<String?> login({
    required String email,
    required String password,
    String requiredRole = 'user',
  }) async {
    try {
      final query = await _usersCollection
          .where('email', isEqualTo: email.trim().toLowerCase())
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 'No account found with this email';
      }

      final data = query.docs.first.data() as Map<String, dynamic>;
      final storedPassword = data['password'] ?? '';
      final storedRole = data['role'] ?? 'user';

      if (storedPassword != password) {
        return 'Incorrect password';
      }
      if (storedRole != requiredRole) {
        return 'This is not a $requiredRole account';
      }

      _currentUser = User(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        password: storedPassword,
        role: storedRole,
      );
      notifyListeners();
      return null;
    } catch (e) {
      return 'Login failed: ${e.toString()}';
    }
  }

  // ───────────── Logout ─────────────
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
