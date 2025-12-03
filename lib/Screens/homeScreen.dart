  import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_bloc.dart';
  import 'package:expense_tracker_app/Bloc/Dashboard/Budget/Category,%20Chart%20&%20Summary/expense_summary_event.dart';
  import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_bloc.dart';
  import 'package:expense_tracker_app/Bloc/Dashboard/Budget/budget_event.dart';
  import 'package:expense_tracker_app/Bloc/Expense/Delete%20Expense/delete_expense_bloc.dart';
  import 'package:expense_tracker_app/Bloc/Expense/List%20Expense/expense_bloc.dart';
  import 'package:expense_tracker_app/Helper/router.dart';
  import 'package:expense_tracker_app/Screens/List/expenseListScreen.dart';
  import 'package:expense_tracker_app/Screens/dashboardScreen.dart';
  import 'package:expense_tracker_app/Services/expense_service.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    int _selectedIndex = 0;
    late PageController _pageController;

    final List<String> _pageRoutes = [AppRoutes.dashboard, AppRoutes.listExpense];

    late List<Widget> _pages;

    @override
    void initState() {
      super.initState();
      _pages = _pageRoutes.map((route) => _getPage(route)).toList();
      _pageController = PageController(initialPage: _selectedIndex);
      _loadLastSelectedTab();
    }

    Widget _getPage(String routeName) {
      switch (routeName) {
        case AppRoutes.dashboard:
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => BudgetBloc()..add(LoadBudget())),
              BlocProvider(
                create: (context) =>
                    ExpenseSummaryBloc()..add(LoadExpenseSummary()),
              ),
            ],
            child: const DashboardScreen(),
          );

        case AppRoutes.listExpense:
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => ExpenseBloc()),
              BlocProvider(create: (context) => DeleteExpenseBloc()),
            ],
            child: const ExpenseListScreen(),
          );

        default:
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => BudgetBloc()..add(LoadBudget())),
              BlocProvider(
                create: (context) =>
                    ExpenseSummaryBloc()..add(LoadExpenseSummary()),
              ),
            ],
            child: const DashboardScreen(),
          );
      }
    }

    Future<void> _loadLastSelectedTab() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int index = prefs.getInt('lastSelectedTab') ?? 0;
      setState(() {
        _selectedIndex = index;
        _pageController = PageController(initialPage: _selectedIndex);
      });
    }

    Future<void> _saveSelectedTab(int index) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastSelectedTab', index);
    }

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
        _pageController.jumpToPage(index);
        _saveSelectedTab(index);
      });
    }

    @override
    Widget build(BuildContext context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BudgetBloc()..add(LoadBudget())),
          BlocProvider(create: (context) => ExpenseBloc()),
          BlocProvider(create: (context) => DeleteExpenseBloc()),
        ],
        child: Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _pages,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt),
                label: 'Expenses',
              ),
            ],
          ),
        ),
      );
    }
  }
