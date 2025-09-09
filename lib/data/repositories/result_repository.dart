import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/backtest_result_model.dart';

class ResultRepository {
  final FirebaseFirestore _firestore;

  ResultRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 결과 목록을 실시간 스트림으로 제공
  Stream<List<BacktestResult>> getResultsStream() {
    return _firestore.collection('result_tables')
      .orderBy('tested_at', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => BacktestResult.fromFirestore(doc)).toList();
      });
  }
}