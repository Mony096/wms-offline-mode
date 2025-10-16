import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wms_mobile/utilies/database/schema.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  // Private constructor
  DatabaseHelper._internal();

  // Factory method to return the singleton instance
  factory DatabaseHelper() => _instance;

  // Database instance
  static Database? _database;

  // Database getter
  Future<Database> get database async {
    if (_database != null) return _database!;

    dropAllTables();
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'wms.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<Database> init() async {
    String path = join(await getDatabasesPath(), 'wms.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    await DatabaseSchema.init(db);
  }

  Future<void> dropAllTables() async {
    final db = await database;
    List<Map<String, dynamic>> tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    for (var table in tables) {
      await db.execute("DROP TABLE IF EXISTS ${table['name']}");
    }

    log('All table cleared');
  }

  // CRUD operations
  Future<int> insert(Map<String, dynamic> item) async {
    Database db = await database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> queryAllItems() async {
    Database db = await database;
    return await db.query('items');
  }

  Future<int> updateItem(Map<String, dynamic> item) async {
    Database db = await database;
    int id = item['id'];
    return await db.update('items', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
