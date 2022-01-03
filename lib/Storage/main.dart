import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

class data {
  final int key;
  final int value;
  data({required this.key,required this.value});
  Map<String, dynamic> toMap() {
    return {'key': key,'value': value,};
  }
  @override
  String toString() {
    return 'data{key: $key, value: $value,}';
  }
}

class dataio {
  static get(int key_) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database_ = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(key INTEGER PRIMARY KEY, value INTEGER)',
        );
      },
      version: 1,
    );
    Future<int> dataget(int key) async {
      final Database db = await database_;
      final List<Map<String, dynamic>> maps = await db.query('kv');
      for (int i = 0; i < maps.length; i++){
        if (maps[i]['key'] == key) return maps[i]['value'];
      }
      return -1;
    }
    return await dataget(key_);
  }

  static void add(int key_, int value_) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database_ = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(key INTEGER PRIMARY KEY, value INTEGER)',
        );
      },
      version: 1,
    );
    Future<void> datainsert(data info) async {
      final Database db = await database_;
      await db.insert(
        'kv',
        info.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    var fido = data(key: key_, value: value_);
    await datainsert(fido);
  }

  static void dataupdate(int key_, int value_) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database_ = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(key INTEGER PRIMARY KEY, value INTEGER)',
        );
      },
      version: 1,
    );
    Future<void> dataupdate(data info) async {
      final db = await database_;
      await db.update(
        'kv',
        info.toMap(),
        where: "key = ?",
        whereArgs: [info.key],
      );
    }
    var fido = data(key: key_, value: value_);
    await dataupdate(fido);
  }

  static void dataremove(int key_) async {
    WidgetsFlutterBinding.ensureInitialized();
    final database_ = openDatabase(
      join(await getDatabasesPath(), 'database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(key INTEGER PRIMARY KEY, value INTEGER)',
        );
      },
      version: 1,
    );
    Future<void> datadelete(int key) async {
      final db = await database_;
      await db.delete(
        'kv',
        where: "key = ?",
        whereArgs: [key],
      );
    }
    await datadelete(key_);
  }
}