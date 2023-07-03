import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// this section is for database

// this is to name the table. table is called expense
final String tableExpense = 'expense';

class ExpenseFields {
  static final List<String> values = [id, title, amount, date, category];

  // this variable is to name the columns. it does not store data
  static final String id = '_id';
  static final String title = '_title';
  static final String amount = '_amount';
  static final String date = '_date';
  static final String category = '_category';
}

//------------------------------

final formatter = DateFormat.yMd();

const uuid = Uuid();

enum Category { food, travel, leisure, work }

const categoryIcons = {
  Category.food: Icons.restaurant,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.sports_esports,
  Category.work: Icons.work,
};

class Expense {
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }

  Map<String, Object?> toJson() => {
        ExpenseFields.id: id,
        ExpenseFields.title: title,
        ExpenseFields.amount: amount.toString(),
        ExpenseFields.date: date.toIso8601String(),
        ExpenseFields.category: categoryToString(category),
      };

  String categoryToString(Category category) {
    return category.toString().split('.').last;
  }

  Expense copy({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    Category? category,
  }) =>
      Expense(
        id: id ?? this.id,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        category: category ?? this.category,
      );

  static Expense fromJson(Map<String, Object?> json) => Expense(
        id: json[ExpenseFields.id] as String,
        title: json[ExpenseFields.title] as String,
        amount: json[ExpenseFields.amount] as double,
        date: DateTime.parse(json[ExpenseFields.date] as String),
        category:
            Category.values[int.parse(json[ExpenseFields.category] as String)],
      );
}

class ExpenseBucket {
  const ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  final Category category;
  final List<Expense> expenses;

  double get totalExpense {
    double sum = 0;

    for (var expense in expenses) {
      sum += expense.amount;
    }

    return sum;
  }
}
