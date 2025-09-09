import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStatus {
  final String scenarioId;
  final String status; // 'active' or 'inactive'

  LiveStatus({required this.scenarioId, required this.status});

  factory LiveStatus.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return LiveStatus(
      scenarioId: doc.id,
      status: data['status'] ?? 'inactive',
    );
  }
}