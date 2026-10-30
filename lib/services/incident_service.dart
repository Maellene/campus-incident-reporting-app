import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident.dart';
import '../utils/constants.dart';

class IncidentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(AppConstants.incidentsCollection);

  String newId() => _collection.doc().id;

  Future<void> createIncident(Incident incident) async {
    await _collection.doc(incident.id).set({
      ...incident.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Incident>> streamAllIncidents() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_toIncidents);
  }

  Stream<List<Incident>> streamUserIncidents(String uid) {
    return _collection
        .where('reporterId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final list = _toIncidents(snapshot);
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateStatus({
    required String incidentId,
    required String status,
    required String staffName,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedBy': staffName,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (status == AppConstants.statusInProgress) {
      data['inProgressAt'] = FieldValue.serverTimestamp();
    }
    if (status == AppConstants.statusResolved) {
      data['resolvedAt'] = FieldValue.serverTimestamp();
    }
    await _collection.doc(incidentId).update(data);
  }

  Future<void> deleteIncident(String incidentId) async {
    await _collection.doc(incidentId).delete();
  }

  List<Incident> _toIncidents(QuerySnapshot<Map<String, dynamic>> snapshot) {
    return snapshot.docs
        .map((doc) => Incident.fromMap(doc.data(), doc.id))
        .toList();
  }
}