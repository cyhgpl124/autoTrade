import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/backtest_result_model.dart';
import '../../../../data/models/scenario_model.dart';
import '../../../../data/repositories/command_repository.dart';
import '../../../../data/repositories/result_repository.dart';
import '../../../../data/repositories/scenario_repository.dart';

part 'backtesting_event.dart';
part 'backtesting_state.dart';

class BacktestingBloc extends Bloc<BacktestingEvent, BacktestingState> {
  final CommandRepository _commandRepository;
  final ScenarioRepository _scenarioRepository;
  final ResultRepository _resultRepository;

  BacktestingBloc({
    required CommandRepository commandRepository,
    required ScenarioRepository scenarioRepository,
    required ResultRepository resultRepository,
  })  : _commandRepository = commandRepository,
        _scenarioRepository = scenarioRepository,
        _resultRepository = resultRepository,
        super(BacktestingInitial()) {
    on<BacktestingDataLoaded>(_onDataLoaded);
    on<BacktestRequested>(_onBacktestRequested);
  }

  Future<void> _onDataLoaded(
    BacktestingDataLoaded event,
    Emitter<BacktestingState> emit,
  ) async {
    emit(BacktestingLoadInProgress());
    try {
      final scenarios = await _scenarioRepository.getScenarios();
      // 결과는 실시간 스트림으로 받으므로, 여기서는 초기 로딩만 처리
      await emit.forEach<List<BacktestResult>>(
        _resultRepository.getResultsStream(),
        onData: (results) => BacktestingLoadSuccess(
          scenarios: scenarios,
          results: results,
        ),
        onError: (error, stackTrace) => BacktestingLoadFailure(error.toString()),
      );
    } catch (e) {
      emit(BacktestingLoadFailure(e.toString()));
    }
  }

  Future<void> _onBacktestRequested(
    BacktestRequested event,
    Emitter<BacktestingState> emit,
  ) async {
    // 백테스팅 실행은 현재 상태에 영향을 주지 않도록 별도 상태로 처리
    // BlocListener를 통해 UI 피드백을 줄 수 있음
     try {
      await _commandRepository.requestBacktest(
        scenarioId: event.scenarioId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
       // emit(BacktestingExecutionSuccess()); // 성공 상태를 UI에 알리고 싶을 경우
    } catch (e) {
       // emit(BacktestingExecutionFailure(e.toString())); // 실패 상태를 UI에 알리고 싶을 경우
    }
  }
}