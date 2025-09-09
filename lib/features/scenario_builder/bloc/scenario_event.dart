part of 'scenario_bloc.dart';

abstract class ScenarioEvent extends Equatable {
  const ScenarioEvent();
  @override
  List<Object> get props => [];
}

class ScenariosLoaded extends ScenarioEvent {}

// ⭐️ 이 이벤트를 추가해주세요 ⭐️
class ScenarioDeleted extends ScenarioEvent {
  final String scenarioId;

  const ScenarioDeleted(this.scenarioId);

  @override
  List<Object> get props => [scenarioId];
}

class ScenarioCreated extends ScenarioEvent {
  final String name;
  final StrategyPart kodex200;
  final StrategyPart kodexInverse;

  const ScenarioCreated({required this.name, required this.kodex200, required this.kodexInverse});
  @override
  List<Object> get props => [name, kodex200, kodexInverse];
}

class ScenarioUpdated extends ScenarioEvent {
  final String id;
  final String name;
  final StrategyPart kodex200;
  final StrategyPart kodexInverse;

  const ScenarioUpdated({required this.id, required this.name, required this.kodex200, required this.kodexInverse});
  @override
  List<Object> get props => [id, name, kodex200, kodexInverse];
}