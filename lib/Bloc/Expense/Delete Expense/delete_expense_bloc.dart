import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'delete_expense_event.dart';
part 'delete_expense_state.dart';

class DeleteExpenseBloc extends Bloc<DeleteExpenseEvent, DeleteExpenseState> {
  DeleteExpenseBloc() : super(DeleteExpenseInitial()) {
    on<DeleteExpenseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
