part of 'backtesting_bloc.dart';

abstract class BacktestingEvent extends Equatable {
  const BacktestingEvent();
  @override
  List<Object> get props => [];
}

// 화면이 처음 로드될 때 데이터 요청
class BacktestingDataLoaded extends BacktestingEvent {}

// '백테스팅 실행' 버튼 클릭
class BacktestRequested extends BacktestingEvent {
  final String scenarioId;
  final DateTime startDate;
  final DateTime endDate;

  const BacktestRequested({required this.scenarioId, required this.startDate, required this.endDate});
  @override
  List<Object> get props => [scenarioId, startDate, endDate];
}