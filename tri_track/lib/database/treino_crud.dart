import 'package:tri_track/database/database.dart';
import 'package:tri_track/models/treino.dart';

class TreinoCrud {
  static final createTableDDL = '''
    CREATE TABLE treino (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo text not null,
      distanciaKm real not null,
      duracaoMinutos integer not null,
      dataCriacao text not null,
      observacao text
    )
 ''';

 static Future<int> insert(Treino treino) async {
    return await (await AppDatabase.instance.database).insert(
      'treino',
      treino.toMap(),
    );
 }

 static Future<List<Treino>> listAll() async {
    return ((await (await AppDatabase.instance.database).query(
      'treino',
      orderBy: 'id DESC',
    )).map((map) => Treino.fromMap(map))).toList();
  }

  static Future<List<Treino>> listByTipo(String tipo) async {
    return ((await (await AppDatabase.instance.database).query(
      'treino',
      where: 'tipo = ?',
      whereArgs: [tipo],
      orderBy: 'id DESC',
    )).map((map) => Treino.fromMap(map))).toList();
  }

  static Future<int> delete(int id) async {
   return await (await AppDatabase.instance.database).delete(
      'treino',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<Map<String, dynamic>> estatisticasPorTipo(String tipo) async {
    final result = await (await AppDatabase.instance.database).rawQuery(''' 
      SELECT 
        count(*) as total,
        sum(distanciaKm) as totalKm,
        sum(distanciaMinutos) as distanciaMinutos,
        avg(distanciaKm) as mediaKm
      from treino
      where tipo = ?
    ''',
    [tipo]);
    return result.first;
  }
}