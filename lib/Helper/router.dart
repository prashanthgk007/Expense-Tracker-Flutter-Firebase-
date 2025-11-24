import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_state.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Edit%20Expense/edit_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_event.dart';
import 'package:expense_tracker_app/Model/expenseModel.dart';
import 'package:expense_tracker_app/Screens/Add/addExpense.dart';
import 'package:expense_tracker_app/Screens/Details/detailScreen.dart';
import 'package:expense_tracker_app/Screens/Edit/editExpense.dart';
import 'package:expense_tracker_app/Screens/List/expenseListScreen.dart';
import 'package:expense_tracker_app/Screens/dashboardScreen.dart';
import 'package:expense_tracker_app/Screens/forgotPasswordScreen.dart';
import 'package:expense_tracker_app/Screens/homeScreen.dart';
import 'package:expense_tracker_app/Screens/loginScreen.dart';
import 'package:expense_tracker_app/Screens/settingsScreen.dart';
import 'package:expense_tracker_app/Screens/signUpScreen.dart';
import 'package:expense_tracker_app/Screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String listExpense = '/list-expense';
  static const String addExpense = '/add-expense';
  static const String editExpense = '/edit-expense';
  static const String expenseDetails = '/expense-details';
  static const String setting = '/settings';
  static const String forgotPassword = '/forgot-password';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());

      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case listExpense:
        return MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => ExpenseBloc(),
              ),

              BlocProvider(create: (context) => DeleteExpenseBloc()),
            ],
            child: const ExpenseListScreen(),
          ),
        );

      case addExpense:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AddExpenseBloc(),
            child: const AddExpenseScreen(),
          ),
        );

      case editExpense:
        final expense = settings.arguments;
        if (expense is ExpenseModel) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => EditExpenseBloc(),
              child: EditExpenseScreen(expense: expense),
            ),
          );
        } else {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Invalid expense data")),
            ),
          );
        }

      case expenseDetails:
        final expense = settings.arguments;
        return MaterialPageRoute(builder: (_) => ExpenseDetailsScreen());

      case setting:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
