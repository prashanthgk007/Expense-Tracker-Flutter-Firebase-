part of 'edit_expense_bloc.dart';

sealed class EditExpenseState extends Equatable {
  const EditExpenseState();
  
  @override
  List<Object> get props => [];
}

final class EditExpenseInitial extends EditExpenseState {}
