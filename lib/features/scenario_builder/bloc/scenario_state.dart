part of 'scenario_bloc.dart';

abstract class ScenarioState extends Equatable {
  const ScenarioState();
  @override
  List<Object> get props => [];
}

class ScenarioInitial extends ScenarioState {}
class ScenarioLoadInProgress extends ScenarioState {}
class ScenarioSaveInProgress extends ScenarioState {}
class ScenarioSaveSuccess extends ScenarioState {}

class ScenarioLoadSuccess extends ScenarioState {
  final List<Scenario> scenarios;
  const ScenarioLoadSuccess(this.scenarios);
  @override
  List<Object> get props => [scenarios];
}

class ScenarioOperationFailure extends ScenarioState {
  final String error;
  const ScenarioOperationFailure(this.error);
  @override
  List<Object> get props => [error];
}