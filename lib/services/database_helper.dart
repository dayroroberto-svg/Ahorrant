import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import '../models/transaction_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._internal();

  DatabaseHelper._internal();
  factory DatabaseHelper() => instance;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Obtener el directorio de la aplicación
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ahorrant.db');

    // Crear o abrir la base de datos
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  void _onCreate(Database db, int version) async {
    // Tabla de transacciones
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        origin TEXT NOT NULL,
        description TEXT,
        synced INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // INSERTAR una transacción
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // OBTENER todas las transacciones
  Future<List<Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // OBTENER transacciones no sincronizadas
  Future<List<Transaction>> getUnsyncedTransactions() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  // ACTUALIZAR una transacción (marcar como sincronizada)
  Future<int> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // ELIMINAR una transacción
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contar total de transacciones
  Future<int> getTransactionCount() async {
    final db = await instance.database;
    var result = await db.rawQuery('SELECT COUNT(*) FROM transactions');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Cerrar base de datos
  Future close() async {
    final db = await instance.database;
    return db.close();
  }
}
