import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path_provider/path_provider.dart';

final String tableMemes = 'memes';
final String columnId = '_id';
final String columnPath = 'path';

class Meme {
  int id;
  String path;

  Meme(String myPath){
    id = null;
    path = myPath ;
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnPath: path,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }



  Meme.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    path = map[columnPath];
  }
}

class MemesProvider {
  Database db;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + '/demo.db';
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
create table $tableMemes ( 
  $columnId integer primary key autoincrement, 
  $columnPath text not null UNIQUE )
''');
        });
  }

  Future<Meme> insert(Meme meme) async {
    meme.id = await db.insert(tableMemes, meme.toMap());
    return meme;
  }

  Future<Meme> getMeme(int id) async {
    List<Map> maps = await db.query(tableMemes,
        columns: [columnId, columnPath],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Meme.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Meme>> getAllMemes() async {
    List<Map> maps = await db.query(tableMemes,
        columns: [columnId, columnPath],);

    if (maps.length > 0) {
      List<Meme> temp= new List();
      for(Map m in maps) temp.add(Meme.fromMap(m)) ;
      return temp ;
    }
    return null;
  }


  Future<int> delete(int id) async {
    return await db.delete(tableMemes, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Meme meme) async {
    return await db.update(tableMemes, meme.toMap(),
        where: '$columnId = ?', whereArgs: [meme.id]);
  }

  Future close() async => db.close();
}