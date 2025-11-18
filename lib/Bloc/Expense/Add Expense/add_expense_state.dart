import 'package:equatable/equatable.dart';

abstract class AddExpenseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddExpenseInitial extends AddExpenseState {}

class AddExpenseLoading extends AddExpenseState {}

class AddExpenseSuccess extends AddExpenseState {}

class AddExpenseFailure extends AddExpenseState {
  final String message;
  AddExpenseFailure(this.message);

  @override
  List<Object?> get props => [message];
}
