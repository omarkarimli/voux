import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DetailEvent {}

class LoadDetailEvent extends DetailEvent {
  final String imagePath;
  final String responseText;

  LoadDetailEvent(this.imagePath, this.responseText);
}

abstract class DetailState {}

class DetailInitialState extends DetailState {}

class DetailLoadedState extends DetailState {
  final String imagePath;
  final String responseText;

  DetailLoadedState(this.imagePath, this.responseText);
}

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  DetailBloc() : super(DetailInitialState()) {
    on<LoadDetailEvent>((event, emit) {
      emit(DetailLoadedState(event.imagePath, event.responseText));
    });
  }
}
