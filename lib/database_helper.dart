import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/models/expense.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  //this is variable to store database
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense.db');
    return _database!;
  }

  //initialize database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //create table
  Future _createDB(Database db, int version) async {
    final idType = 'TEXT PRIMARY KEY';
    final doubleType = 'REAL NOT NULL';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $tableExpense (
      ${ExpenseFields.id} $idType,
      ${ExpenseFields.title} $textType,
      ${ExpenseFields.amount} $doubleType,
      ${ExpenseFields.date} $textType,
      ${ExpenseFields.category} $textType
    )
  ''');
  }

  Future<Expense> create(Expense expense) async {
    final db = await instance.database;

    final expenseMap = expense.toJson();
    final updatedExpenseMap = Map<String, dynamic>.from(expenseMap);
    updatedExpenseMap['_category'] = expense.category.index;

    final id = await db.insert(tableExpense, updatedExpenseMap);
    return expense.copy(id: id.toString());
  }

  Future<Expense> readExpense(String id) async {
    final db = await instance.database;

    final maps = await db.query(tableExpense,
        columns: ExpenseFields.values,
        where: '${ExpenseFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Expense.fromJson(maps.first);
    } else {
      throw Exception('ID $id is not found');
    }
  }

  Future<List<Expense>> readAllExpense() async {
    final db = await instance.database;

    // final orderBy = '${ExpenseFields.date} ASC';
    final result = await db.query(tableExpense);

    return result.map((json) => Expense.fromJson(json)).toList();
  }

  Future<int> update(Expense expense) async {
    final db = await instance.database;

    return db.update(
      tableExpense,
      expense.toJson(),
      where: '${ExpenseFields.id} = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete(
      tableExpense,
      where: '${ExpenseFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
