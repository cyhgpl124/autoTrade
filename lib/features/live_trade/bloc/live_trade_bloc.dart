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

  // 여러 스트림을 관리하기 위한 StreamSubscription
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
    // 이벤트 핸들러 등록
    on<LiveTradeDataLoaded>(_onDataLoaded);
    on<LiveTradeActivationRequested>(_onActivationRequested);
    on<LiveTradeDeactivationRequested>(_onDeactivationRequested);
    on<_LiveTradeDataUpdated>(_onDataUpdated); // 내부 데이터 업데이트 이벤트 추가
  }

  // Bloc이 닫힐 때 스트림 구독을 반드시 취소하여 메모리 누수 방지
  @override
  Future<void> close() {
    _combinedSubscription?.cancel();
    return super.close();
  }

  /// 데이터를 처음 로드하고 스트림 리스닝을 시작하는 메서드
  Future<void> _onDataLoaded(
    LiveTradeDataLoaded event,
    Emitter<LiveTradeState> emit,
  ) async {
    emit(LiveTradeLoadInProgress());
    try {
      // 이전에 실행 중인 스트림이 있다면 취소
      await _combinedSubscription?.cancel();

      // 시나리오 목록은 한 번만 가져옴
      final scenarios = await _scenarioRepo.getScenarios();

      // 실시간 상태와 로그 스트림을 RxDart를 이용해 하나로 합침
      final combinedStream = Rx.combineLatest2(
        _statusRepo.getLiveStatusStream(),
        _logRepo.getTradeLogsStream(),
        (List<LiveStatus> statuses, List<TradeLog> logs) => {
          'scenarios': scenarios,
          'statuses': statuses,
          'logs': logs,
        },
      );

      // 스트림을 구독하고, 데이터가 들어올 때마다 내부 이벤트(_LiveTradeDataUpdated)를 발생시킴
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

  /// 스트림에서 새 데이터가 들어왔을 때 상태를 업데이트하는 내부 이벤트 핸들러
  void _onDataUpdated(
    _LiveTradeDataUpdated event,
    Emitter<LiveTradeState> emit,
  ) {
    // UI에 LiveTradeLoadSuccess 상태를 전달하여 화면 갱신
    emit(LiveTradeLoadSuccess(
      scenarios: event.scenarios,
      activeStatuses: event.activeStatuses,
      tradeLogs: event.tradeLogs,
    ));
  }

  /// 실시간 매매 활성화 요청 처리
  Future<void> _onActivationRequested(
    LiveTradeActivationRequested event,
    Emitter<LiveTradeState> emit,
  ) async {
    try {
      await _commandRepo.startLiveTrade(scenarioId: event.scenarioId);
      // 성공적으로 명령을 보냈다는 것을 사용자에게 알리거나,
      // 상태 업데이트는 스트림이 자동으로 감지하므로 별도의 emit이 필요 없을 수도 있음
      // 여기서는 별다른 상태 변경 없이 스트림의 응답을 기다림
    } catch (e) {
      // 실패 시 에러 상태 emit
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }

  /// 실시간 매매 비활성화 요청 처리
  Future<void> _onDeactivationRequested(
    LiveTradeDeactivationRequested event,
    Emitter<LiveTradeState> emit,
  ) async {
    try {
      await _commandRepo.stopLiveTrade(scenarioId: event.scenarioId);
      // 활성화 요청과 마찬가지로 스트림의 응답을 기다림
    } catch (e) {
      emit(LiveTradeLoadFailure(e.toString()));
    }
  }
}

// BLoC 내부에서만 사용할 데이터 업데이트 이벤트 정의
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