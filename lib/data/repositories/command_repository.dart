import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase Firestore의 'commands' 컬렉션과 통신하는 역할만 담당하는 클래스입니다.
class CommandRepository {
  // Firestore 인스턴스에 대한 참조를 저장합니다. '_'(언더스코어)는 private 멤버를 의미합니다.
  final FirebaseFirestore _firestore;

  // 생성자: 외부에서 Firestore 인스턴스를 주입받거나, 없으면 기본 인스턴스를 사용합니다.
  // 이는 나중에 테스트 코드를 작성할 때 유용합니다.
  CommandRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 'commands' 컬렉션에 대한 참조를 가져오는 private getter입니다.
  CollectionReference get _commandsCollection =>
      _firestore.collection('commands');

  /// 1. 데이터 수집 명령을 Firestore에 전송합니다.
  Future<void> requestDataCollection({
    required String code,
    required String barType,
  }) async {
    try {
      await _commandsCollection.add({
        'command': 'collect_data',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'payload': {
          'code': code,
          'bar_type': barType,
        },
      });
    } catch (e) {
      // 실제 앱에서는 에러 로깅 라이브러리를 사용해 기록하는 것이 좋습니다.
      print('데이터 수집 명령 전송 실패: $e');
      rethrow; // 에러를 BLoC 레이어로 다시 던져서 UI에 실패 상태를 알릴 수 있게 합니다.
    }
  }

  /// 3. 백테스팅 실행 명령을 Firestore에 전송합니다.
  Future<void> requestBacktest({
    required String scenarioId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _commandsCollection.add({
        'command': 'run_backtest',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'payload': {
          'scenario_id': scenarioId,
          // Firestore는 DateTime 객체를 Timestamp로 자동 변환해줍니다.
          'start_date': startDate,
          'end_date': endDate,
        },
      });
    } catch (e) {
      print('백테스팅 실행 명령 전송 실패: $e');
      rethrow;
    }
  }

  /// 4. 실전 매매 시작 명령을 Firestore에 전송합니다.
  Future<void> startLiveTrade({required String scenarioId}) async {
    try {
      await _commandsCollection.add({
        'command': 'start_live_trade',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'payload': {'scenario_id': scenarioId},
      });
    } catch (e) {
      print('실전 매매 시작 명령 전송 실패: $e');
      rethrow;
    }
  }

  /// 5. 실전 매매 중지 명령을 Firestore에 전송합니다.
  Future<void> stopLiveTrade({required String scenarioId}) async {
    try {
      await _commandsCollection.add({
        'command': 'stop_live_trade',
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'payload': {'scenario_id': scenarioId},
      });
    } catch (e) {
      print('실전 매매 중지 명령 전송 실패: $e');
      rethrow;
    }
  }
}