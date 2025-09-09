part of 'live_trade_bloc.dart';

abstract class LiveTradeState extends Equatable {
  const LiveTradeState();
  @override
  List<Object> get props => [];
}

class LiveTradeInitial extends LiveTradeState {}

class LiveTradeLoadInProgress extends LiveTradeState {}

class LiveTradeLoadSuccess extends LiveTradeState {
  final List<Scenario> scenarios;
  final List<LiveStatus> activeStatuses;
  final List<TradeLog> tradeLogs;

  const LiveTradeLoadSuccess({
    this.scenarios = const [],
    this.activeStatuses = const [],
    this.tradeLogs = const [],
  });

  // 특정 시나리오가 활성화 상태인지 확인하는 헬퍼 메소드
  bool isScenarioActive(String scenarioId) {
    return activeStatuses.any((s) => s.scenarioId == scenarioId && s.status == 'active');
  }

  @override
  List<Object> get props => [scenarios, activeStatuses, tradeLogs];
}

class LiveTradeLoadFailure extends LiveTradeState {
  final String error;
  const LiveTradeLoadFailure(this.error);
  @override
  List<Object> get props => [error];
}