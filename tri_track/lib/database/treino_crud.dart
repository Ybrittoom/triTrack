import 'package:tri_track/database/database.dart';
import 'package:tri_track/models/treino.dart';

class TreinoCrud {
  // CORRIGIDO: Nomes das colunas idênticos aos atributos do modelo Treino
  static final createTableDDL = '''
    CREATE TABLE treino (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo text not null,
      distancia real not null,
      duracao integer not null,
      data text not null,
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

  // CORRIGIDO: Modificado de 'distanciaKm'/'duracaoMinutos' para 'distancia'/'duracao'
  static Future<Map<String, dynamic>> estatisticasPorTipo(String tipo) async {
    final db = await AppDatabase.instance.database;
    
    // Normaliza para lidar com a correção do til de "Natação"
    final tipoBusca = tipo.contains('Nata') ? 'Natação' : tipo;

    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(distancia) as km,
        SUM(duracao) as tempo
      FROM treino 
      WHERE tipo = ? OR tipo = 'Nataçao'
    ''', [tipoBusca]);

    if (result.isEmpty || result.first['total'] == 0) {
      return {'total': 0, 'km': '0.00', 'tempo': '0min', 'media': '0.00'};
    }

    final total = result.first['total'] as int;
    final km = (result.first['km'] as num?)?.toDouble() ?? 0.0;
    final tempo = (result.first['tempo'] as num?)?.toInt() ?? 0;
    final media = total > 0 ? km / total : 0.0;

    // Formata o tempo de forma elegante usando o seu TreinoService
    final h = tempo ~/ 60;
    final m = tempo % 60;
    final tempoFormatado = h == 0 ? '${m}min' : '${h}h${m.toString().padLeft(2, '0')}';

    return {
      'total': total,
      'km': km.toStringAsFixed(2),
      'tempo': tempoFormatado,
      'media': media.toStringAsFixed(2),
    };
  }
}