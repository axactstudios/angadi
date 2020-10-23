import 'package:angadi/classes/cart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "cartdb.db";
  static final _databaseVersion = 1;
  static final table = 'Cart';
  static final columnId = 'id';
  static final columnProductName = 'productName';
  static final columnImageUrl = 'imgUrl';
  static final columnPrice = 'price';
  static final columnQuantity = 'qty';
  static final columnQuantityTag = 'qtyTag';

//  static final columnDetail = 'details';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  onCreate() async {
    Database db = await instance.database;
    db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnProductName TEXT NOT NULL,
            $columnImageUrl TEXT NOT NULL,
            $columnPrice TEXT NOT NULL,
            $columnQuantity INTEGER NOT NULL,
            $columnQuantityTag TEXT NOT NULL
          )
          ''');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnProductName TEXT NOT NULL,
            $columnImageUrl TEXT NOT NULL,
            $columnPrice TEXT NOT NULL,
            $columnQuantity INTEGER NOT NULL,
            $columnQuantityTag TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Cart item) async {
    Database db = await instance.database;
    return await db.insert(table, {
      'productName': item.productName,
      'imgUrl': item.imgUrl,
      'price': item.price,
      'qty': item.qty,
      'qtyTag': item.qtyTag
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryRows(name, qtyTag) async {
    Database db = await instance.database;
    var x = await db
        .query(table,
            where:
                "$columnProductName LIKE '%$name%' AND $columnQuantityTag LIKE '%$qtyTag%'")
        .catchError((e) {
      print(e);
    });
    print(x.toString());
    return await db
        .query(table,
            where:
                "$columnProductName LIKE '%$name%' AND $columnQuantityTag LIKE '%$qtyTag%'")
        .catchError((e) {
      print(e);
    });
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> check(String name, String qtyTag) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $table WHERE $columnProductName = $name AND $columnQuantityTag = $qtyTag'));
  }

  Future<int> update(Cart item) async {
    Database db = await instance.database;
    String productName = item.toMap()['productName'];

    String qtyTag = item.toMap()['qtyTag'];
    return await db.update(table, item.toMap(),
        where: '$columnProductName = ? AND $columnQuantityTag = ?',
        whereArgs: [productName, qtyTag]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String name, String qtyTag) async {
    Database db = await instance.database;
    return await db.delete(table,
        where: '$columnProductName = ? AND $columnQuantityTag = ?',
        whereArgs: [name, qtyTag]);
  }
}
