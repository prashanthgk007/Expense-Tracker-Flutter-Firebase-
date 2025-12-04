class ExpenseSummary {
  final double totalSpent;
  final double thisMonthSpent;
  final Map<String, double> categories;

  ExpenseSummary({
    required this.totalSpent,
    required this.thisMonthSpent,
    required this.categories,
  });

  factory ExpenseSummary.fromMap(Map<String, dynamic> map) {
    final rawCategories = Map<String, dynamic>.from(map["categories"] ?? {});

    // Convert dynamic values to double
    final parsedCategories = rawCategories.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return ExpenseSummary(
      totalSpent: (map["totalSpent"] as num).toDouble(),
      thisMonthSpent: (map["thisMonthSpent"] as num).toDouble(),
      categories: parsedCategories,
    );
  }

  factory ExpenseSummary.empty() {
    return ExpenseSummary(
      totalSpent: 0,
      categories: const {},
      thisMonthSpent: 0,
    );
  }
}
