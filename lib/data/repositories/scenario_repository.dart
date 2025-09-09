// lib/data/repositories/scenario_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scenario_model.dart';

class ScenarioRepository {
  final FirebaseFirestore _firestore;

  ScenarioRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 'scenarios' 컬렉션에 대한 참조
  CollectionReference<Map<String, dynamic>> get _scenariosCollection =>
      _firestore.collection('scenarios');

  /// 1. [유지] 모든 시나리오 목록을 가져옵니다.
  Future<List<Scenario>> getScenarios() async {
    try {
      final snapshot = await _scenariosCollection.orderBy('created_at', descending: true).get();
      return snapshot.docs.map((doc) => Scenario.fromFirestore(doc)).toList();
    } catch (e) {
      print('시나리오 목록 가져오기 실패: $e');
      rethrow;
    }
  }

  /// 2. [신규] 새로운 시나리오를 데이터베이스에 직접 생성합니다.
  Future<void> createScenario(Scenario scenario) async {
    try {
      await _scenariosCollection.add(scenario.toJson());
    } catch (e) {
      print('시나리오 생성 실패: $e');
      rethrow;
    }
  }

  /// 3. [신규] 기존 시나리오를 데이터베이스에서 직접 수정합니다.
  Future<void> updateScenario(Scenario scenario) async {
    try {
      await _scenariosCollection.doc(scenario.id).update(scenario.toJson());
    } catch (e) {
      print('시나리오 수정 실패: $e');
      rethrow;
    }
  }

  /// 4. [신규] 시나리오를 데이터베이스에서 직접 삭제합니다.
  Future<void> deleteScenario({required String scenarioId}) async {
    try {
      await _scenariosCollection.doc(scenarioId).delete();
    } catch (e) {
      print('시나리오 삭제 실패: $e');
      rethrow;
    }
  }
}