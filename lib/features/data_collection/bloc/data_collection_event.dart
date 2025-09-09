part of 'data_collection_bloc.dart';


abstract class DataCollectionEvent extends Equatable {
  const DataCollectionEvent();

  @override
  List<Object> get props => [];
}

// '데이터 수집 요청' 버튼을 눌렀을 때 발생하는 이벤트
class DataCollectionRequested extends DataCollectionEvent {
  final String code;
  final String barType;

  const DataCollectionRequested({required this.code, required this.barType});

  @override
  List<Object> get props => [code, barType];
}