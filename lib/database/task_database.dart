// import 'dart:async';
// import 'package:sqflite/sqflite.dart';

// class TaskSyncDatabase {
//   final Database _database;

//   late StreamController<List<Map<String, dynamic>>> _streamController;
//   Timer? _timer;

//   Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

//   TaskSyncDatabase(this._database) {
//     _streamController =
//         StreamController<List<Map<String, dynamic>>>.broadcast();
//     _startListeningToChanges();
//   }

//   Future<void> create(Map<String, dynamic> data) async {
//     await _database.insert('sync_task', data);
//   }

//   Future<List<Map<String, dynamic>>> getTasks() async {
//     final List<Map<String, dynamic>> tasks = await _database.query('tasks');
//     return tasks;
//   }


//   // Future<List<Map<String, dynamic>>> read() async {
//   //   return _database.query(
//   //     'sync_task',
//   //     orderBy: 'id',
//   //   );
//   // }
//   Future<List<Map<String, dynamic>>> read() async {
//   return _database.query(
//     'sync_task',
//     where: 'is_sync = ?',
//     whereArgs: ['false'],
//     orderBy: 'id',
//   );
// }


//   Future<void> update(int id, Map<String, dynamic> data) async {
//     await _database.update(
//       'sync_task',
//       data,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   Future<void> delete(int id) async {
//     await _database.delete(
//       'sync_task',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   void _startListeningToChanges() {
//     _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
//       _refreshStream();
//     });
//   }

//   Future<void> _refreshStream() async {
//     final result = await read();
//  print('Data fetched from database: $result');
//     if (!_streamController.isClosed) {
//       _streamController.add(result);
//     }
//   }

//   void dispose() {
//     _timer!.cancel();
//     _streamController.close();
//   }
// }
import 'dart:async';

import 'package:coldxpress/export.dart'; 
import 'package:sqflite/sqflite.dart'; // For database access
class TaskSyncDatabase {
  final Database _database;

  late StreamController<List<Map<String, dynamic>>> _streamController;
  Timer? _timer;

  Stream<List<Map<String, dynamic>>> get stream => _streamController.stream;

  TaskSyncDatabase(this._database) {
    _streamController =
        StreamController<List<Map<String, dynamic>>>.broadcast();
    _startListeningToChanges();
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _database.insert('sync_task', data);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final List<Map<String, dynamic>> tasks = await _database.query('tasks');
    return tasks;
  }

  // Fetch tasks that need syncing (is_sync = false)
  Future<List<Map<String, dynamic>>> readForSync() async {
    return _database.query(
      'sync_task',
      where: 'is_sync = ?',
      whereArgs: ['false'],
      orderBy: 'id',
    );
  }

  // Fetch tasks for view (is_sync = true)
  Future<List<Map<String, dynamic>>> readForView() async {
    return _database.query(
      'sync_task',
      where: 'is_sync = ?',
      whereArgs: ['true'],
      orderBy: 'id',
    );
  }

  Future<void> update(int id, Map<String, dynamic> data) async {
    await _database.update(
      'sync_task',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    await _database.delete(
      'sync_task',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  void _startListeningToChanges() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      _refreshStream();  // Fetch tasks for viewing periodically
    });
  }

Future<void> _refreshStream() async {
  // Fetch tasks that need syncing (is_sync = false)
  final syncResult = await readForSync();

  // Fetch tasks that are synced (is_sync = true) for viewing
  final viewResult = await readForView();

  // Combine the two lists of results
  final result = [...syncResult, ...viewResult];

  print('Data fetched from database: $result');

  if (!_streamController.isClosed) {
    _streamController.add(result);
  }
}


  void dispose() {
    _timer!.cancel();
    _streamController.close();
  }
}
