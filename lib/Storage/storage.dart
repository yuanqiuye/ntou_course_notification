import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';

extension stringToList on String {
  List<int> tolist() {
    return [for (dynamic dy in json.decode(this)) dy as int];
  }
}

extension listToString on List {
  String toStr() {
    return json.encode(this).toString();
  }
}

class Data {
  final List<int> key;
  final List<int> value;
  Data({required this.key, required this.value});
  Map<String, String> toMap() {
    return {
      'key': key.toStr(),
      'value': value.toStr(),
    };
  }
}

class dataio {
  Database? database_ = null;
  init() async {
    WidgetsFlutterBinding.ensureInitialized();
    database_ = await openDatabase(
      join(await getDatabasesPath(), 'Nicedatabase.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE data(key TEXT UNIQUE,value TEXT)',
        );
      },
      version: 1,
    );
  }

  waitUntilDone() async {
    final completer = Completer();
    if (database_ == null) {
      await Duration(milliseconds: 200);
      return waitUntilDone();
    } else {
      completer.complete();
    }
    return completer.future;
  }

  get(List<int> _key) async {
    Future<List<int>?> dataget(String key) async {
      final Database db = database_!;
      final List<Map<String, dynamic>> maps = await db.query('data');
      for (int i = 0; i < maps.length; i++) {
        if (maps[i]['key'] == key) return maps[i]['value'].toString().tolist();
      }
      return null;
    }

    return await dataget(_key.toStr());
  }

  add(List<int> key_, List<int> value_) async {
    Future<void> datainsert(Data info) async {
      final Database db = database_!;
      await db.insert(
        'data',
        info.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    var fido = Data(key: key_, value: value_);
    await datainsert(fido);
  }

  dataupdate(List<int> key_, List<int> value_) async {
    Future<void> dataupdate(Data info) async {
      final db = database_!;
      await db.update(
        'data',
        info.toMap(),
        where: "key = ?",
        whereArgs: [info.key],
      );
    }

    var fido = Data(key: key_, value: value_);
    await dataupdate(fido);
  }

  dataremove(List<int> key_) async {
    Future<void> datadelete(String key) async {
      final db = database_!;
      await db.delete(
        'data',
        where: "key = ?",
        whereArgs: [key],
      );
    }

    await datadelete(key_.toStr());
  }
}

void main() async {
  dataio db = dataio();
  await db.init();
  await db.add([3, 10], [17, 30]);
  var ans = await db.get([3, 10]);
  print(ans);
}
