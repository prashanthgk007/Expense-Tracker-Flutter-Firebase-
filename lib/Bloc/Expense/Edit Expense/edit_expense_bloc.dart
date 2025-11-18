import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'edit_expense_event.dart';
part 'edit_expense_state.dart';

class EditExpenseBloc extends Bloc<EditExpenseEvent, EditExpenseState> {
  EditExpenseBloc() : super(EditExpenseInitial()) {
    on<EditExpenseEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
