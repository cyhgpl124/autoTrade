part of 'data_collection_bloc.dart';

// Equatable을 사용하여 state 간의 불필요한 리빌드를 방지합니다.
abstract class DataCollectionState extends Equatable {
  const DataCollectionState();

  @override
  List<Object> get props => [];
}

// 초기 상태
class DataCollectionInitial extends DataCollectionState {}

// 명령 전송 중인 상태 (로딩)
class DataCollectionInProgress extends DataCollectionState {}

// 명령 전송 성공 상태
class DataCollectionSuccess extends DataCollectionState {}

// 명령 전송 실패 상태
class DataCollectionFailure extends DataCollectionState {
  final String error;

  const DataCollectionFailure(this.error);

  @override
  List<Object> get props => [error];
}