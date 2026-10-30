import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  StreamSubscription<User?>? _subscription;

  User? _firebaseUser;
  AppUser? _appUser;
  bool _isInitializing = true;
  bool _isLoading = false;
  bool _isRegistering = false;
  String? _errorMessage;

  AuthProvider() {
    _subscription = _service.authStateChanges.listen(_onAuthChanged);
  }

  User? get firebaseUser => _firebaseUser;
  AppUser? get appUser => _appUser;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isEmailVerified => _firebaseUser?.emailVerified ?? false;
  bool get isStaff => _appUser?.isStaff ?? false;

  Future<void> _onAuthChanged(User? user) async {
    _firebaseUser = user;
    if (_isRegistering) return;
    if (user == null) {
      _appUser = null;
    } else {
      _appUser = await _service.fetchUser(user.uid);
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _isRegistering = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final user = await _service.register(
        name: name,
        email: email,
        password: password,
      );
      _firebaseUser = user;
      _appUser = await _service.fetchUser(user.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _messageFor(e);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again';
      return false;
    } finally {
      _isRegistering = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.login(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _messageFor(e);
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkEmailVerified() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.reloadUser();
      _firebaseUser = _service.currentUser;
    } catch (_) {
      _errorMessage = 'Could not check verification status';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendVerification() async {
    try {
      await _service.sendVerificationEmail();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _messageFor(e);
      return false;
    } catch (_) {
      _errorMessage = 'Could not send the email. Try again later';
      return false;
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Enter a valid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'network-request-failed':
        return 'No internet connection';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return 'Something went wrong. Please try again';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}