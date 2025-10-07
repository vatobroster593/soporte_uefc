import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'soporte.db');

    return await openDatabase(
      path,
      version: 2, // Cambiar versión
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE tickets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          numero_ticket TEXT,
          cedula_confirmacion TEXT,
          nombre TEXT,
          grado TEXT,
          cargo TEXT,
          tipo_problema TEXT,
          problema TEXT,
          solucion TEXT,
          fecha TEXT,
          confirmado INTEGER,
          foto_antes TEXT,
          foto_despues TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tickets ADD COLUMN numero_ticket TEXT');
          await db.execute('ALTER TABLE tickets ADD COLUMN cedula_confirmacion TEXT');
          await db.execute('ALTER TABLE tickets ADD COLUMN foto_antes TEXT');
          await db.execute('ALTER TABLE tickets ADD COLUMN foto_despues TEXT');
        }
      },
    );
  }

  static Future<void> guardarTicket(Map<String, dynamic> ticket) async {
    final db = await database;
    await db.insert('tickets', ticket);
  }

  static Future<List<Map<String, dynamic>>> obtenerTickets() async {
    final db = await database;
    return await db.query('tickets', orderBy: 'id DESC');
  }

  // Eliminar un ticket específico
  static Future<void> eliminarTicket(int id) async {
    final db = await database;
    await db.delete(
      'tickets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Eliminar todos los tickets (para limpiar pruebas)
  static Future<void> eliminarTodosTickets() async {
    final db = await database;
    await db.delete('tickets');
  }

// Obtener cantidad de tickets
  static Future<int> contarTickets() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tickets');
    return result.first['count'] as int;
  }

  // Generar número de ticket con formato TCK-C6-TICS-XXX
  static Future<String> generarNumeroTicket() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM tickets');
    int totalTickets = result.first['count'] as int;

    // Incrementar para el nuevo ticket
    int numeroConsecutivo = totalTickets + 1;

    // Formato: TCK-C6-TICS-XXX (con 3 dígitos mínimo)
    String numeroFormateado = numeroConsecutivo.toString().padLeft(3, '0');

    return 'TCK-C6-TICS-$numeroFormateado';
  }

}