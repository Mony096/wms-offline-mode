import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  static init(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY,
        username VARCHAR(25),
        password VARCHAR(25),
        default_login INTEGER DEFAULT 1,
        default_warehouse TEXT NULL,
        last_login TEXT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE warehouses(
        id INTEGER PRIMARY KEY,
        WarehouseCode VARCHAR(25),
        WarehouseName VARCHAR(25),
        BusinessPlaceID INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE unit_of_measurements(
        id INTEGER PRIMARY KEY,
        AlternateUoM INTEGER,
        AlternateQuantity VARCHAR(12),
        BaseQuantity VARCHAR(12),
        AbsEntry INTEGER,
        Code VARCHAR(25),
        Name VARCHAR(25),
        UoMGroupEntry INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE bin_locations(
        id INTEGER PRIMARY KEY,
        AbsEntry INTEGER,
        BinCode VARCHAR(50),
        Warehouse VARCHAR(50),
        Sublevel1 VARCHAR(50) NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY,
        ItemCode VARCHAR(50),
        ItemName TEXT NULL,
        UoMGroupEntry INTEGER NULL,
        InventoryUOM VARCHAR(20) NULL,
        InventoryUoMEntry INTEGER NULL,
        PurchaseItem VARCHAR(20) NULL,
        SalesItem VARCHAR(20) NULL,
        InventoryItem VARCHAR(20) NULL,
        UoMGroupDefinitionCollection TEXT NULL
      )
    ''');
  }
}
