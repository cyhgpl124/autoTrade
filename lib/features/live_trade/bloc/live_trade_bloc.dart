// live_trade/bloc/live_trade_bloc.dart

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
import 'package:stock/data/repositories/trade_log_repository.dart';

part 'live_trade_event.dart';
part 'live_trade_state.dart';

class LiveTradeBloc extends Bloc<LiveTradeEvent, LiveTradeState> {
  final CommandRepository _commandRepo;
  final ScenarioRepository _scenarioRepo;
  final LiveStatusRepository _statusRepo;
  final TradeLogRepository _logRepo;

  // 여러 스트림을 안정적으로 관리하기 위한 구독 객체
  StreamSubscription? _combinedSubscription;

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
    // 각 이벤트에 대한 핸들러를 명확하게 등록
    on<LiveTradeDataLoaded>(_onDataLoaded);
    on<LiveTradeActivationRequested>(_onActivationRequested);
    on<LiveTradeDeactivationRequested>(_onDeactivationRequested);
    on<_LiveTradeDataUpdated>(_onDataUpdated); // 스트림 데이터 처리를 위한 내부 이벤트
  }

  // Bloc이 소멸될 때 스트림 구독을 반드시 취소하여 메모리 누수를 방지
  @override
  Future<void> close() {
    _combinedSubscription?.cancel();
    return super.close();
  }

  /// 데이터를 처음 로드하고 실시간 스트림 감지를 시작하는 메서드
  Future<void> _onDataLoaded(
    LiveTradeDataLoaded event,
    Emitter<LiveTradeState> emit,
  ) async {
    emit(LiveTradeLoadInProgress());
    try {
      // 이전에 실행 중인 스트림이 있다면 안전하게 취소
      await _combinedSubscription?.cancel();

      // 시나리오 목록은 처음에 한 번만 가져옴
      final scenarios = await _scenarioRepo.getScenarios();

      // 실시간 상태 스트림과 로그 스트림을 RxDart를 이용해 하나로 합침
      final combinedStream = Rx.combineLatest2(
        _statusRepo.getLiveStatusStream(),
        _logRepo.getTradeLogsStream(),
        (List<LiveStatus> statuses, List<TradeLog> logs) => {
          'scenarios': scenarios,
          'statuses': statuses,
          'logs': logs,
        },
      );

      // 합쳐진 스트림을 구독하고, 데이터가 변경될 때마다 내부 이벤트를 발생시킴
      _combinedSubscription = combinedStream.listen((data) {
        add(_LiveTradeDataUpdated(
          scenarios: data['scenarios'] as List<Scenario>,
          activeStatuses: data['statuses'] as List<LiveStatus>,
          tradeLogs: data['logs'] as List<TradeLog>,
        ));
      });
    } catch (e) {
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }

  /// 스트림에서 새 데이터가 들어왔을 때 UI 상태를 업데이트하는 내부 이벤트 핸들러
  void _onDataUpdated(
    _LiveTradeDataUpdated event,
    Emitter<LiveTradeState> emit,
  ) {
    // LiveTradeLoadSuccess 상태를 emit하여 UI 갱신
    emit(LiveTradeLoadSuccess(
      scenarios: event.scenarios,
      activeStatuses: event.activeStatuses,
      tradeLogs: event.tradeLogs,
    ));
  }

  /// 실시간 매매 활성화 요청을 처리하는 핸들러
  Future<void> _onActivationRequested(
    LiveTradeActivationRequested event,
    Emitter<LiveTradeState> emit,
  ) async {
    try {
      // 백엔드에 매매 시작 명령 전송
      await _commandRepo.startLiveTrade(scenarioId: event.scenarioId);
      // 성공 후 상태 업데이트는 스트림이 자동으로 감지하므로 여기서 별도 emit은 불필요
    } catch (e) {
      // 실패 시 에러 상태를 emit하여 사용자에게 알림
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }

  /// 실시간 매매 비활성화 요청을 처리하는 핸들러
  Future<void> _onDeactivationRequested(
    LiveTradeDeactivationRequested event,
    Emitter<LiveTradeState> emit,
  ) async {
    try {
      // 백엔드에 매매 중지 명령 전송
      await _commandRepo.stopLiveTrade(scenarioId: event.scenarioId);
    } catch (e) {
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }
}

/// Bloc 내부에서 스트림 데이터를 받아 상태를 업데이트하기 위해 사용하는 이벤트
class _LiveTradeDataUpdated extends LiveTradeEvent {
  final List<Scenario> scenarios;
  final List<LiveStatus> activeStatuses;
  final List<TradeLog> tradeLogs;

  const _LiveTradeDataUpdated({
    required this.scenarios,
    required this.activeStatuses,
    required this.tradeLogs,
  });

  @override
  List<Object> get props => [scenarios, activeStatuses, tradeLogs];
}