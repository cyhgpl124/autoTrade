import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/command_repository.dart';

part 'data_collection_event.dart';
part 'data_collection_state.dart';

class DataCollectionBloc
    extends Bloc<DataCollectionEvent, DataCollectionState> {
  final CommandRepository _commandRepository;

  DataCollectionBloc({required CommandRepository commandRepository})
      : _commandRepository = commandRepository,
        super(DataCollectionInitial()) {
    on<DataCollectionRequested>(_onDataCollectionRequested);
  }

  Future<void> _onDataCollectionRequested(
    DataCollectionRequested event,
    Emitter<DataCollectionState> emit,
  ) async {
    emit(DataCollectionInProgress());
    try {
      await _commandRepository.requestDataCollection(
        code: event.code,
        barType: event.barType,
      );
      emit(DataCollectionSuccess());
    } catch (e) {
      emit(DataCollectionFailure(e.toString()));
    }
  }
}