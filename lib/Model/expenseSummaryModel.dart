class ExpenseSummary {
  final double totalSpent;
  final double thisMonthSpent;
  final double thisWeekSpent;
  final double todaySpent;
  final Map<String, double> categories;

  ExpenseSummary({
    required this.totalSpent,
    required this.thisMonthSpent,
    required this.thisWeekSpent,
    required this.todaySpent,
    required this.categories,
  });

  factory ExpenseSummary.fromMap(Map<String, dynamic> map) {
    final rawCategories = Map<String, dynamic>.from(map["categories"] ?? {});

    final parsedCategories = rawCategories.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExpenseSummary(
      totalSpent: (map["totalSpent"] as num).toDouble(),
      thisMonthSpent: (map["thisMonthSpent"] as num).toDouble(),
      thisWeekSpent: (map["thisWeekSpent"] as num).toDouble(),
      todaySpent: (map["todaySpent"] as num).toDouble(),
      categories: parsedCategories,
    );
  }
}

