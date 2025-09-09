// lib/data/models/scenario_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 일반적인 지표 비교 조건을 나타내는 클래스 (매수 조건용)
class IndicatorCondition {
  final String barType;
  final int barOffset1;
  final String indicator1;
  final String operator;
  final int barOffset2;
  final String indicator2;

  IndicatorCondition({
    this.barType = '일봉', this.barOffset1 = 0, required this.indicator1,
    required this.operator, this.barOffset2 = 0, required this.indicator2,
  });

  Map<String, dynamic> toJson() => {
        'bar_type': barType, 'bar_offset1': barOffset1, 'indicator1': indicator1,
        'operator': operator, 'bar_offset2': barOffset2, 'indicator2': indicator2,
      };

  factory IndicatorCondition.fromMap(Map<String, dynamic> map) {
    return IndicatorCondition(
      barType: map['bar_type'] ?? '일봉', operator: map['operator'] ?? 'cross_above',
      indicator1: map['indicator1'] ?? 'ma_5', barOffset1: map['bar_offset1'] ?? 0,
      indicator2: map['indicator2'] ?? 'ma_20', barOffset2: map['bar_offset2'] ?? 0,
    );
  }
}

/// 매도 조건의 타입을 정의하는 열거형(enum)
// ⭐️ stopLoss 제거
enum SellConditionType { indicator, trailingStop }

/// 트레일링 스탑의 기준 타입을 정의하는 열거형(enum)
enum TrailingStopType { fromPurchase, fromHigh }

/// 다양한 타입의 매도 조건을 나타내는 클래스
class SellCondition {
  final SellConditionType type;
  final IndicatorCondition? indicatorCondition;
  final double? value; // 트레일링 스탑의 % 값
  final TrailingStopType? trailingStopType; // ⭐️ [신규] 트레일링 스탑 기준

  SellCondition({required this.type, this.indicatorCondition, this.value, this.trailingStopType});

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'indicator_condition': indicatorCondition?.toJson(),
        'value': value,
        'trailing_stop_type': trailingStopType?.name, // ⭐️ 저장 필드 추가
      };

  factory SellCondition.fromMap(Map<String, dynamic> map) {
    return SellCondition(
      type: SellConditionType.values.firstWhere((e) => e.name == map['type'], orElse: () => SellConditionType.indicator),
      indicatorCondition: map['indicator_condition'] != null ? IndicatorCondition.fromMap(map['indicator_condition']) : null,
      value: (map['value'] as num?)?.toDouble(),
      trailingStopType: map['trailing_stop_type'] != null
          ? TrailingStopType.values.firstWhere((e) => e.name == map['trailing_stop_type'])
          : null, // ⭐️ 불러오기 필드 추가
    );
  }
}

/// ⭐️ [신규] 매수 조건들을 담는 그룹 클래스
class BuyConditionGroup {
  final List<IndicatorCondition> conditions;
  BuyConditionGroup({this.conditions = const []});

  Map<String, dynamic> toJson() => {
    'conditions': conditions.map((c) => c.toJson()).toList(),
  };

  factory BuyConditionGroup.fromMap(Map<String, dynamic> map) {
    return BuyConditionGroup(
      conditions: (map['conditions'] as List<dynamic>?)?.map((c) => IndicatorCondition.fromMap(c)).toList() ?? [],
    );
  }
}

/// ⭐️ [신규] 매도 조건들을 담는 그룹 클래스
class SellConditionGroup {
  final List<SellCondition> conditions;
  SellConditionGroup({this.conditions = const []});

  Map<String, dynamic> toJson() => {
      'conditions': conditions.map((c) => c.toJson()).toList(),
  };

  factory SellConditionGroup.fromMap(Map<String, dynamic> map) {
    return SellConditionGroup(
      conditions: (map['conditions'] as List<dynamic>?)?.map((c) => SellCondition.fromMap(c)).toList() ?? [],
    );
  }
}

/// ⭐️ [수정] KODEX 200, KODEX 인버스 각각의 전략 파트 클래스
class StrategyPart {
  final List<BuyConditionGroup> buyConditionGroups;
  final List<SellConditionGroup> sellConditionGroups;

  StrategyPart({this.buyConditionGroups = const [], this.sellConditionGroups = const []});

  Map<String, dynamic> toJson() => {
      'buy_condition_groups': buyConditionGroups.map((g) => g.toJson()).toList(),
      'sell_condition_groups': sellConditionGroups.map((g) => g.toJson()).toList(),
  };

  factory StrategyPart.fromMap(Map<String, dynamic> map) {
    return StrategyPart(
       buyConditionGroups: (map['buy_condition_groups'] as List<dynamic>?)?.map((g) => BuyConditionGroup.fromMap(g)).toList() ?? [],
       sellConditionGroups: (map['sell_condition_groups'] as List<dynamic>?)?.map((g) => SellConditionGroup.fromMap(g)).toList() ?? [],
    );
  }
}

/// 최종 시나리오 모델 (구조는 동일, 참조하는 클래스가 변경됨)
class Scenario {
  final String id;
  final String name;
  final StrategyPart kodex200;
  final StrategyPart kodexInverse;

  Scenario({
    required this.id, required this.name,
    required this.kodex200, required this.kodexInverse,
  });

  Map<String, dynamic> toJson() => {
      'scenario_name': name,
      'kodex_200': kodex200.toJson(),
      'kodex_inverse': kodexInverse.toJson(),
      'created_at': FieldValue.serverTimestamp(),
    };

  factory Scenario.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Scenario(
      id: doc.id,
      name: data['scenario_name'] ?? '이름 없음',
      kodex200: data['kodex_200'] != null ? StrategyPart.fromMap(data['kodex_200']) : StrategyPart(),
      kodexInverse: data['kodex_inverse'] != null ? StrategyPart.fromMap(data['kodex_inverse']) : StrategyPart(),
    );
  }
}

