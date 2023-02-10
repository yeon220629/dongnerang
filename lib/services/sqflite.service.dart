import 'package:dongnerang/models/space.model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SpaceDBHelper {
  static final SpaceDBHelper instance = SpaceDBHelper._create();

  late String databasePath;
  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDB();
  }

  // private constructor
  SpaceDBHelper._create() {
    print("create private SpaceDBHelper constructor");
  }

  // 데이터베이스 생성
  Future<Database> _initDB() async {
    databasePath = await getDatabasesPath();
    String path = join(databasePath, 'spacedatabase.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS spaces (
            uid TEXT PRIMARY KEY,
            gu TEXT NOT NULL,
            spaceName TEXT NOT NULL,
            spaceImage TEXT,
            address TEXT,
            category TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            detailInfo TEXT,
            pageLink TEXT,
            phoneNum TEXT,
            svcName TEXT,
            svcStat TEXT,
            svcTimeMin TEXT,
            svcTimeMax TEXT,
            payInfo TEXT,
            useTarget TEXT)
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) => {},
    );
  }

  // 데이터 추가
  Future<void> insertSpace(Space space) async {
    Database db = await instance.database;

    int insertNum = await db.insert(
      'spaces', // table name
      space.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("insertSpace >>> $insertNum >>> $space");
  }

  // 전체 데이터 삭제
  Future<void> deleteDataAll() async {
    var db = await instance.database;
    db.rawQuery('DELETE FROM spaces');
  }

  // 자치구(gu)로 리스트 조회
  Future<List<Space>> getSpaceListByGu(String gu) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM spaces WHERE gu=?', [gu]);

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return Space.fromMap(maps[i]);
    });
  }

  // 전체 리스트 조회
  Future<List<Map<String, dynamic>>> getAllSpaceList() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('SELECT * FROM spaces', null);

    return maps;
  }

  // 업데이트 일자 구하기
  Future<void> getOne() async {
    Database db = await instance.database;
    var one = await db.rawQuery('SELECT * FROM spaces LIMIT 1');

    print("one >>> $one");
    // return one;
  }
}
