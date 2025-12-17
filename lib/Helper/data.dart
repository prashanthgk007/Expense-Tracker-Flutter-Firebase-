import 'package:expense_tracker_app/Helper/enum.dart';

class Data {
  static List<String> allCategories = [
    "Food",
    "Travel",
    "Shopping",
    "Health",
    "Bills",
    "Others",
  ];

  static String showCategoryDisplayName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return "Food";
      case ExpenseCategory.travel:
        return "Travel";
      case ExpenseCategory.shopping:
        return "Shopping";
      case ExpenseCategory.health:
        return "Health";
      case ExpenseCategory.bills:
        return "Bills";
      case ExpenseCategory.other:
        return "Others";
    }
  }

  static ExpenseCategory getCategoryValueFromList(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return ExpenseCategory.food;
      case 'travel':
        return ExpenseCategory.travel;
      case 'shopping':
        return ExpenseCategory.shopping;
      case 'health':
        return ExpenseCategory.health;
      case 'bills':
        return ExpenseCategory.bills;
      case 'others':
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.other;
    }
  }
}
