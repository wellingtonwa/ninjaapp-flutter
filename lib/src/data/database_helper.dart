import 'dart:io';

import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'package:sqflite_migration/src/migrator.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  DatabaseHelper.internal();

  initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "ninjapp.db");

    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;

    final initialScript = [
      '''
            CREATE TABLE config (
              id INTEGER PRIMARY KEY,
              postgres_url TEXT,
              postgres_user TEXT,
              postgres_password TEXT
            )
          '''
    ];

    final migrationScripts = [
      '''
        ALTER TABLE config ADD COLUMN task_folder TEXT;
      ''',
      '''
        ALTER TABLE config ADD COLUMN bitrix_url TEXT;
      ''',
      '''
        ALTER TABLE config ADD COLUMN backup_folder TEXT;
      ''',
      '''
        ALTER TABLE config ADD COLUMN postgres_container BOOLEAN;
        ALTER TABLE config ADD COLUMN postgres_container_name TEXT;
      ''',
      '''
        ALTER TABLE config ADD COLUMN postgres_port TEXT;
      ''',
      '''
        ALTER TABLE config ADD COLUMN bitrix_workgroup TEXT;
      '''
    ];

    final config = MigrationConfig(
        initializationScript: initialScript,
        migrationScripts: migrationScripts);

    final migrator = Migrator(config);
    _database = await databaseFactory.openDatabase(path,
        options: OpenDatabaseOptions(
            version: config.migrationScripts.length + 1,
            onCreate: migrator.executeInitialization,
            onUpgrade: migrator.executeMigration));
    return _database;
  }
}
