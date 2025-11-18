part of 'delete_expense_bloc.dart';

sealed class DeleteExpenseState extends Equatable {
  const DeleteExpenseState();
  
  @override
  List<Object> get props => [];
}

final class DeleteExpenseInitial extends DeleteExpenseState {}
