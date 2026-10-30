import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service = IncidentService();
  final StorageService _storage = StorageService();
  StreamSubscription<List<Incident>>? _subscription;

  AppUser? _user;
  List<Incident> _incidents = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _categoryFilter;
  String? _statusFilter;

  List<Incident> get incidents => _incidents;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get categoryFilter => _categoryFilter;
  String? get statusFilter => _statusFilter;

  int get totalCount => _incidents.length;
  int get submittedCount => _countOf(AppConstants.statusSubmitted);
  int get inProgressCount => _countOf(AppConstants.statusInProgress);
  int get resolvedCount => _countOf(AppConstants.statusResolved);

  List<Incident> get filteredIncidents {
    final query = _searchQuery.toLowerCase();
    return _incidents.where((incident) {
      final matchesSearch = query.isEmpty ||
          incident.title.toLowerCase().contains(query) ||
          incident.description.toLowerCase().contains(query) ||
          incident.location.toLowerCase().contains(query);
      final matchesCategory =
          _categoryFilter == null || incident.category == _categoryFilter;
      final matchesStatus =
          _statusFilter == null || incident.status == _statusFilter;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  Incident? findById(String id) {
    for (final incident in _incidents) {
      if (incident.id == id) return incident;
    }
    return null;
  }

  void updateUser(AppUser? user) {
    if (user?.uid == _user?.uid && user?.role == _user?.role) return;
    _user = user;
    _subscription?.cancel();
    _subscription = null;
    _incidents = [];
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    if (user == null) return;

    _isLoading = true;
    final stream = user.isStaff
        ? _service.streamAllIncidents()
        : _service.streamUserIncidents(user.uid);
    _subscription = stream.listen(
      (data) {
        _incidents = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _isLoading = false;
        _errorMessage = 'Could not load reports';
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    _categoryFilter = value;
    notifyListeners();
  }

  void setStatusFilter(String? value) {
    _statusFilter = value;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  Future<bool> submitIncident({
    required String title,
    required String description,
    required String category,
    required String location,
    File? image,
  }) async {
    final user = _user;
    if (user == null) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = _service.newId();
      String? imageUrl;
      if (image != null) {
        imageUrl = await _storage.uploadIncidentImage(image, id);
      }
      final incident = Incident(
        id: id,
        title: title,
        description: description,
        category: category,
        location: location,
        status: AppConstants.statusSubmitted,
        imageUrl: imageUrl,
        reporterId: user.uid,
        reporterName: user.name,
        createdAt: DateTime.now(),
      );
      await _service.createIncident(incident);
      return true;
    } catch (_) {
      _errorMessage = 'Could not submit the report. Please try again';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String incidentId, String status) async {
    final user = _user;
    if (user == null || !user.isStaff) {
      _errorMessage = 'Only staff can update the status';
      notifyListeners();
      return false;
    }
    try {
      await _service.updateStatus(
        incidentId: incidentId,
        status: status,
        staffName: user.name,
      );
      return true;
    } catch (_) {
      _errorMessage = 'Could not update the status';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteIncident(Incident incident) async {
    try {
      await _service.deleteIncident(incident.id);
      if (incident.imageUrl != null) {
        await _storage.deleteImage(incident.imageUrl!);
      }
      return true;
    } catch (_) {
      _errorMessage = 'Could not delete the report';
      notifyListeners();
      return false;
    }
  }

  int _countOf(String status) =>
      _incidents.where((incident) => incident.status == status).length;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}