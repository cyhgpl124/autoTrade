import 'package:cloud_firestore/cloud_firestore.dart';

class TradeLog {
  final String action; // 'buy' or 'sell'
  final String code;
  final String scenarioName;
  final int price;
  final int quantity;
  final Timestamp timestamp;

  TradeLog({
    required this.action,
    required this.code,
    required this.scenarioName,
    required this.price,
    required this.quantity,
    required this.timestamp,
  });

  factory TradeLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return TradeLog(
      action: data['action'] ?? 'unknown',
      code: data['code'] ?? '',
      scenarioName: data['scenario_name'] ?? '알 수 없는 시나리오',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}