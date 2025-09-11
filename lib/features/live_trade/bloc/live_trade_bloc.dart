import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/data/models/live_status_model.dart';
import 'package:stock/data/models/scenario_model.dart';
import 'package:stock/data/models/trade_log_model.dart';
import 'package:stock/data/repositories/command_repository.dart';
import 'package:stock/data/repositories/live_status_repository.dart';
import 'package:stock/data/repositories/scenario_repository.dart';
import 'package:stock/data/repositories/trade_log_repository.dart'; // rxdart 패키지 추가 필요
// ... 필요한 모델 및 Repository import

part 'live_trade_event.dart';
part 'live_trade_state.dart';

class LiveTradeBloc extends Bloc<LiveTradeEvent, LiveTradeState> {
  final CommandRepository _commandRepo;
  final ScenarioRepository _scenarioRepo;
  final LiveStatusRepository _statusRepo;
  final TradeLogRepository _logRepo;

  LiveTradeBloc({
    required CommandRepository commandRepo,
    required ScenarioRepository scenarioRepo,
    required LiveStatusRepository statusRepo,
    required TradeLogRepository logRepo,
  })  : _commandRepo = commandRepo,
        _scenarioRepo = scenarioRepo,
        _statusRepo = statusRepo,
        _logRepo = logRepo,
        super(LiveTradeInitial()) {
    on<LiveTradeDataLoaded>(_onDataLoaded);
    on<LiveTradeActivationRequested>((event, emit) => _commandRepo.startLiveTrade(scenarioId: event.scenarioId));
    on<LiveTradeDeactivationRequested>((event, emit) => _commandRepo.stopLiveTrade(scenarioId: event.scenarioId));
  }

  Future<void> _onDataLoaded(
    LiveTradeDataLoaded event,
    Emitter<LiveTradeState> emit,
  ) async {
    emit(LiveTradeLoadInProgress());
    try {
      final scenarios = await _scenarioRepo.getScenarios();

      // 상태 스트림과 로그 스트림을 합쳐서 하나의 상태로 UI에 전달
      final combinedStream = Rx.combineLatest2(
        _statusRepo.getLiveStatusStream(),
        _logRepo.getTradeLogsStream(),
        (List<LiveStatus> statuses, List<TradeLog> logs) => {
          'statuses': statuses,
          'logs': logs,
        },
      );

      await emit.forEach(
        combinedStream,
        onData: (data) => LiveTradeLoadSuccess(
          scenarios: scenarios,
          activeStatuses: data['statuses'] as List<LiveStatus>,
          tradeLogs: data['logs'] as List<TradeLog>,
        ),
      );
    } catch (e) {
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }
}