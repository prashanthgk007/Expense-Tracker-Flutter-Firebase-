import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_bloc.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_event.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_bloc.dart';
import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_event.dart';
import 'package:expense_tracker_app/Bloc/Expense/Add%20Expense/add_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/Edit%20Expense/edit_expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
import 'package:expense_tracker_app/Bloc/Users/user_bloc.dart';
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
  // Route names (Remain Unchanged)
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

  // --------------------------------------------------------------------------
  // 1. HELPER FOR INDEXEDSTACK (New Method)
  // --------------------------------------------------------------------------
  /// This bypasses MaterialPageRoute creation, preventing unnecessary disposal/reloading.
  static Widget getScreenWidget(String routeName) {
    switch (routeName) {
      case dashboard:
        // BlocProviders for the DashboardScreen
        return MultiBlocProvider(
          providers: [
            // Ensure BudgetBloc is initialized on first load
            BlocProvider(create: (_) => BudgetBloc()..add(LoadBudget())), 
            // Ensure ExpenseSummaryBloc is initialized on first load
            BlocProvider(
              create: (context) => ExpenseSummaryBloc()..add(LoadExpenseSummary()),
            ),
          ],
          child: const DashboardScreen(),
        );

      case listExpense:
        // BlocProviders for the ExpenseListScreen
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => ExpenseBloc()),
            BlocProvider(create: (context) => DeleteExpenseBloc()),
            // The ExpenseSummaryBloc is likely used here too
            BlocProvider(
              create: (context) => ExpenseSummaryBloc()..add(LoadExpenseSummary()),
            ),
          ],
          child: const ExpenseListScreen(),
        );

      default:
        // Fallback for screens not intended for IndexedStack
        return const Scaffold(body: Center(child: Text("Invalid Tab Screen")));
    }
  }


  // --------------------------------------------------------------------------
  // 2. ROUTE GENERATOR (Modified)
  // --------------------------------------------------------------------------
  /// Generates the MaterialPageRoute for screens accessed via navigation methods (like pushNamed).
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // These routes are used for full-screen navigation (push/pop)
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case home:
        // HOME screen is the container for the IndexedStack.
        return MaterialPageRoute(builder: (_) => const HomeScreen()); 
        
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => SignupScreen());
      case dashboard:
      case listExpense:
        // If someone pushes directly to these routes, they get the screen with providers
        return MaterialPageRoute(builder: (_) => getScreenWidget(settings.name!));


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
        return MaterialPageRoute(builder: (_) => ExpenseDetailsScreen());

      case setting:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => UserBloc(),
            child: const SettingsScreen(),
          ),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => AuthBloc(),
            child: ForgotPasswordScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}