import 'package:dongnerang/models/space.model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SpaceDBHelper {
  late Database _database;

  Future<Database?> get database async {
    _database = await initDB();
    return _database;
  }

  // 데이터베이스 생성
  initDB() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, 'space_database.db');

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
            latitude TEXT NOT NULL,
            longitude TEXT NOT NULL,
            detailInfo TEXT,
            pageLink TEXT,
            phoneNum TEXT,
            updated TEXT,
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
    final db = await database;

    await db?.insert(
      'spaces', // table name
      {
        'uid': space.uid,
        'gu': space.gu,
        'spaceName': space.spaceName,
        'spaceImage': space.spaceImage ?? '',
        'address': space.address ?? '',
        'category': space.category,
        'latitude': space.location['latitude'].toString(),
        'longitude': space.location['longitude'].toString(),
        'detailInfo': space.detailInfo ?? '',
        'pageLink': space.pageLink ?? '',
        'phoneNum': space.phoneNum ?? '',
        'updated': space.updated ?? '',
        'svcName': space.svcName ?? '',
        'svcStat': space.svcStat ?? '',
        'svcTimeMin': space.svcTimeMin ?? '',
        'svcTimeMax': space.svcTimeMax ?? '',
        'payInfo': space.payInfo ?? '',
        'useTarget': space.useTarget ?? ''
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 자치구(gu)로 리스트 조회
  Future<List<Space>> getSpaceListByGu(String gu) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db!.rawQuery('SELECT * FROM spaces WHERE gu=?', [gu]);

    if (maps.isEmpty) return [];

    return List.generate(maps.length, (i) {
      return Space(
          uid: maps[i]['uid'],
          gu: maps[i]['gu'],
          spaceName: maps[i]['spaceName'],
          spaceImage: maps[i]['spaceImage'],
          address: maps[i]['address'],
          category: maps[i]['category'],
          location: {
            'latitude': double.parse(maps[i]['latitude']),
            'longitude': double.parse(maps[i]['longitude'])
          },
          detailInfo: maps[i]['detailInfo'],
          pageLink: maps[i]['pageLink'],
          phoneNum: maps[i]['phoneNum'],
          updated: maps[i]['updated'],
          svcName: maps[i]['svcName'],
          svcStat: maps[i]['svcStat'],
          svcTimeMin: maps[i]['svcTimeMin'],
          svcTimeMax: maps[i]['svcTimeMax'],
          payInfo: maps[i]['payInfo'],
          useTarget: maps[i]['useTarget']);
    });
  }
}
