part of 'backtesting_bloc.dart';

abstract class BacktestingState extends Equatable {
  const BacktestingState();
  @override
  List<Object> get props => [];
}

class BacktestingInitial extends BacktestingState {}

// 시나리오, 결과 목록 로딩 중
class BacktestingLoadInProgress extends BacktestingState {}

// 로딩 성공. UI에 필요한 모든 데이터를 담고 있음
class BacktestingLoadSuccess extends BacktestingState {
  final List<Scenario> scenarios;
  final List<BacktestResult> results;

  const BacktestingLoadSuccess({this.scenarios = const [], this.results = const []});
  @override
  List<Object> get props => [scenarios, results];
}

class BacktestingLoadFailure extends BacktestingState {
  final String error;
  const BacktestingLoadFailure(this.error);
  @override
  List<Object> get props => [error];
}

// 백테스팅 명령 전송 중
class BacktestingExecutionInProgress extends BacktestingState {}
// 백테스팅 명령 전송 성공
class BacktestingExecutionSuccess extends BacktestingState {}
// 백테스팅 명령 전송 실패
class BacktestingExecutionFailure extends BacktestingState {
    final String error;
  const BacktestingExecutionFailure(this.error);
  @override
  List<Object> get props => [error];
}