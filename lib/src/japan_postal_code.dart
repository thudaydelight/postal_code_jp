import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class JapanPostCode  {
  JapanPostCode._(this._path);
  final dynamic _path;
  static late Completer<JapanPostCode> _completer;


  static Future<JapanPostCode> getInstance() async {
      _completer = Completer<JapanPostCode>();
      try {
        final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, 'zip.db');

// Check if the database exists
        final exists = await databaseExists(path);

        if (!exists) {
          // Should happen only the first time you launch your application
          if (kDebugMode) {
            print('Creating new copy from asset');
          }

          // Make sure the parent directory exists
          try {
            await Directory(dirname(path)).create(recursive: true);
          } catch (_) {}
          // Copy from asset
          final ByteData data = await rootBundle.load(join('database', 'zip.db'));
          final List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

          // Write and flush the bytes written
          await File(path).writeAsBytes(bytes, flush: true);
        } else {
          if (kDebugMode) {
            print('Opening existing database');
          }
        }
        _completer.complete(JapanPostCode._(path));
      } on Exception catch (e){
        _completer.completeError(e);
        final Future<JapanPostCode> japanPostalCode = _completer.future;
        return japanPostalCode;
      }
    return _completer.future;
  }

  Future<List<Map>> getJapanPostalCode(String code) async{
    final Database database = await openDatabase(_path);
    final List<Map> list = await database.rawQuery('SELECT * FROM address where code = "$code"');
    return list;
  }

}
