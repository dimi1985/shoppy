import 'package:flutter/foundation.dart';
import 'package:shoppy/models/products.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        price REAL,
        quantity INTEGER,
        totalPrice REAL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'shoppy_test1.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> addProduct(Product product) async {
    final db = await SQLHelper.db();
    var raw = await db.insert(
      "items",
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  // Read all items (item)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Product>> getProducts() async {
    final db = await SQLHelper.db();
    var response = await db.query("items");
    List<Product> list = response.map((c) => Product.fromMap(c)).toList();
    return list;
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  Future<Product?> getProductWithId(int id) async {
    final db = await SQLHelper.db();
    var response = await db.query("items", where: "id = ?", whereArgs: [id]);
    return response.isNotEmpty ? Product.fromMap(response.first) : null;
  }

  static Future<int> updateProduct(Product product) async {
    final db = await SQLHelper.db();
    var response = await db.update("items", product.toMap(),
        where: "id = ?", whereArgs: [product.id]);
    return response;
  }

  // Delete

  static Future<void> deleteProduct(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // Delete
  static Future<void> deleteAll() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
