import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class BancoCombustivel {
  static const _nomeArquivo = 'combustivel.db';
  static const _versao = 1;

  // Guarda a abertura para reutilizar a mesma conexão.
  static Future<Database>? _conexao;

  static Future<Database> obter() {
    return _conexao ??= _abrir();
  }

  static Future<Database> _abrir() async {
    try {
      final pasta = await getDatabasesPath();

      return await openDatabase(
        p.join(pasta, _nomeArquivo),
        version: _versao,
        // Executado apenas quando o banco ainda não existe.
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE veiculo (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              tipo TEXT NOT NULL,
              marca TEXT NOT NULL,
              modelo TEXT NOT NULL,
              ano INTEGER NOT NULL,
              cilindrada INTEGER NOT NULL
            )
          ''');
          // veiculo_id liga cada abastecimento ao seu veículo.
          await db.execute('''
            CREATE TABLE abastecimentos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              veiculo_id INTEGER NOT NULL,
              combustivel TEXT NOT NULL,
              preco_litro REAL NOT NULL,
              quilometragem REAL NOT NULL,
              litros REAL NOT NULL,
              data_hora TEXT NOT NULL
            )
          ''');
        },
      );
    } catch (erro) {
      // Permite uma nova tentativa na próxima chamada de obter().
      _conexao = null;
      rethrow;
    }
  }
}
