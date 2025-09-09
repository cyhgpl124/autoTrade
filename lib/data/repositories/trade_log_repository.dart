import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trade_log_model.dart';

class TradeLogRepository {
  final FirebaseFirestore _firestore;

  TradeLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<TradeLog>> getTradeLogsStream() {
    return _firestore.collection('trade_logs')
      .orderBy('timestamp', descending: true)
      .limit(100) // 최근 100개 기록만 가져옴
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => TradeLog.fromFirestore(doc)).toList();
      });
  }
}