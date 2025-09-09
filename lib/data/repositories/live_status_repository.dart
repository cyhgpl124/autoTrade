import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/live_status_model.dart';

class LiveStatusRepository {
  final FirebaseFirestore _firestore;

  LiveStatusRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<LiveStatus>> getLiveStatusStream() {
    return _firestore.collection('live_status').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LiveStatus.fromFirestore(doc)).toList();
    });
  }
}