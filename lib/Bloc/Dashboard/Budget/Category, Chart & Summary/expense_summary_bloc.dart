import 'dart:async';
import 'package:expense_tracker_app/Services/stream_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'expense_summary_event.dart';
import 'expense_summary_state.dart';

class ExpenseSummaryBloc extends Bloc<ExpenseSummaryEvent, ExpenseSummaryState> {
    final ExpenseStreamService streams = ExpenseStreamService();
  StreamSubscription? _subscription;

  ExpenseSummaryBloc() : super(ExpenseSummaryInitial()) {
    on<LoadExpenseSummary>(_onLoad);
    on<ExpenseSummaryUpdated>(_onSummaryUpdated);
    on<ExpenseSummaryErrorEvent>(_onSummaryError);
  }

  void _onLoad(
      LoadExpenseSummary event, Emitter<ExpenseSummaryState> emit) {
    emit(ExpenseSummaryLoading());
    _subscription?.cancel();

    _subscription = streams.streamExpenseSummary().listen(
      (summary) {
        add(ExpenseSummaryUpdated(summary));
      },
      onError: (e) {
        add(ExpenseSummaryErrorEvent(e.toString()));
      },
    );
  }

  void _onSummaryUpdated(
      ExpenseSummaryUpdated event, Emitter<ExpenseSummaryState> emit) {
    emit(ExpenseSummaryLoaded(event.summary));
  }

  void _onSummaryError(
      ExpenseSummaryErrorEvent event, Emitter<ExpenseSummaryState> emit) {
    emit(ExpenseSummaryError(event.message));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
