part of 'edit_expense_bloc.dart';

sealed class EditExpenseState extends Equatable {
  const EditExpenseState();
  
  @override
  List<Object> get props => [];
}

final class EditExpenseInitial extends EditExpenseState {}

final class EditExpenseLoading extends EditExpenseState {}

final class EditExpenseSuccess extends EditExpenseState {}

final class EditExpenseFailure extends EditExpenseState {
  final String message;
  
  const EditExpenseFailure(this.message);
  
  @override
  List<Object> get props => [message];
}
