import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/scenario_model.dart';
import '../../../data/repositories/scenario_repository.dart';

part 'scenario_event.dart';
part 'scenario_state.dart';

class ScenarioBloc extends Bloc<ScenarioEvent, ScenarioState> {
  final ScenarioRepository _scenarioRepository;

  ScenarioBloc({
    required ScenarioRepository scenarioRepository,
  })  : _scenarioRepository = scenarioRepository,
        super(ScenarioInitial()) {
    on<ScenariosLoaded>(_onScenariosLoaded);
    on<ScenarioCreated>(_onScenarioCreated);
    on<ScenarioUpdated>(_onScenarioUpdated);
    on<ScenarioDeleted>(_onScenarioDeleted);
  }

  /// 시나리오 목록을 불러오는 이벤트를 처리합니다.
  Future<void> _onScenariosLoaded(
    ScenariosLoaded event,
    Emitter<ScenarioState> emit,
  ) async {
    emit(ScenarioLoadInProgress());
    try {
      final scenarios = await _scenarioRepository.getScenarios();
      emit(ScenarioLoadSuccess(scenarios));
    } catch (e) {
      emit(ScenarioOperationFailure(e.toString()));
    }
  }

  /// 새로운 시나리오 생성을 처리합니다.
  Future<void> _onScenarioCreated(
    ScenarioCreated event,
    Emitter<ScenarioState> emit,
  ) async {
    emit(ScenarioSaveInProgress());
    try {
      // 이벤트에서 받은 데이터로 새로운 Scenario 객체를 생성합니다.
      final newScenario = Scenario(
        id: '', // ID는 Firestore에서 자동 생성되므로 비워둡니다.
        name: event.name,
        kodex200: event.kodex200,
        kodexInverse: event.kodexInverse,
      );
      // Repository를 통해 Firestore에 데이터를 저장합니다.
      await _scenarioRepository.createScenario(newScenario);
      emit(ScenarioSaveSuccess());
      add(ScenariosLoaded()); // 성공 후 목록을 새로고침합니다.
    } catch (e) {
      emit(ScenarioOperationFailure(e.toString()));
    }
  }

  /// 기존 시나리오 수정을 처리합니다.
  Future<void> _onScenarioUpdated(
    ScenarioUpdated event,
    Emitter<ScenarioState> emit,
  ) async {
    emit(ScenarioSaveInProgress());
    try {
      // 이벤트에서 받은 데이터로 업데이트할 Scenario 객체를 생성합니다.
      final updatedScenario = Scenario(
        id: event.id,
        name: event.name,
        kodex200: event.kodex200,
        kodexInverse: event.kodexInverse,
      );
      // Repository를 통해 Firestore 데이터를 수정합니다.
      await _scenarioRepository.updateScenario(updatedScenario);
      emit(ScenarioSaveSuccess());
      add(ScenariosLoaded()); // 성공 후 목록을 새로고침합니다.
    } catch (e) {
      emit(ScenarioOperationFailure(e.toString()));
    }
  }

  /// 시나리오 삭제를 처리합니다.
  Future<void> _onScenarioDeleted(
    ScenarioDeleted event,
    Emitter<ScenarioState> emit,
  ) async {
    // 삭제 작업은 UI에 즉시 로딩 상태를 보여줄 필요가 없을 수 있으므로,
    // 바로 Repository를 호출합니다.
    try {
      await _scenarioRepository.deleteScenario(scenarioId: event.scenarioId);
      add(ScenariosLoaded()); // 성공 후 목록을 새로고침합니다.
    } catch (e) {
      emit(ScenarioOperationFailure(e.toString()));
    }
  }
}