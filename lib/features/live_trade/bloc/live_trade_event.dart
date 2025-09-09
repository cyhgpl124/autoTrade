part of 'live_trade_bloc.dart';

abstract class LiveTradeEvent extends Equatable {
  const LiveTradeEvent();
  @override
  List<Object> get props => [];
}

class LiveTradeDataLoaded extends LiveTradeEvent {}

class LiveTradeActivationRequested extends LiveTradeEvent {
  final String scenarioId;
  const LiveTradeActivationRequested(this.scenarioId);
  @override
  List<Object> get props => [scenarioId];
}

class LiveTradeDeactivationRequested extends LiveTradeEvent {
  final String scenarioId;
  const LiveTradeDeactivationRequested(this.scenarioId);
  @override
  List<Object> get props => [scenarioId];
}