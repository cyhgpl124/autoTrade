import 'package:cloud_firestore/cloud_firestore.dart';

class BacktestResult {
  final String id;
  final String scenarioId;
  final String scenarioName;
  final String graphUrl;
  final Map<String, dynamic> summary;
  final Timestamp testedAt;

  BacktestResult({
    required this.id,
    required this.scenarioId,
    required this.scenarioName,
    required this.graphUrl,
    required this.summary,
    required this.testedAt,
  });

  factory BacktestResult.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BacktestResult(
      id: doc.id,
      scenarioId: data['scenario_id'] ?? '',
      scenarioName: data['scenario_name'] ?? '이름 없음',
      graphUrl: data['graph_url'] ?? '',
      summary: data['summary'] ?? {},
      testedAt: data['tested_at'] ?? Timestamp.now(),
    );
  }
}