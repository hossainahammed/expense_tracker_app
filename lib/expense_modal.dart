class Expense {
  String title;
  double amount;
  DateTime date;
  String category;
  String? folderName;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.folderName,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'folderName': folderName,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      title: json['title'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      category: json['category'],
      folderName: json['folderName'],
    );
  }
}
