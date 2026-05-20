import 'dart:convert';
import 'dart:math';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../../errors/exceptions/database/database_exception.dart' as ex;
import '../../../utils/talker/talker.dart';
import '../secure_storage/secure_storage_config.dart';
import '../secure_storage/secure_storage_services.dart';
import 'sqlite_config.dart';

final sqliteServicesProvider = Provider<SQLiteServices>((ref) {
  return SQLiteServicesImpl(
    secureStorage: SecureStorageServicesImpl(),
  );
});

const int _dbVersion = 3;

abstract class SQLiteServices {
  String dayKey(DateTime date);
  Database get db;
  Future<void> initDatabase();
}

class SQLiteServicesImpl implements SQLiteServices {
  final SecureStorageServices secureStorage;

  SQLiteServicesImpl({
    required this.secureStorage,
  }); 

  Database? _database;


  @override
  Database get db {
    if (_database == null) {
      throw ex.DatabaseException(
        type: ex.DatabaseExceptionType.read,
        message: 'The database is not initialized'
      );
    }
    return _database!;
  }

  @override
  Future<void> initDatabase() async {
    /// Will open db if it is not opened
    if (_database != null && _database!.isOpen) return;

    final psw = await _getOrCreateDbPassword();

    _database = await _openDB(psw);

    talker.debug('Opened database: ${_database?.database.toString()}');
  }

  Future<Database?> _openDB(String password) async {
    try {
      return await openDatabase(
        'sawmio.db',
        password: password,
        version: _dbVersion,
        onCreate: (db, version) async {
           // Settings table
          await db.execute('''
            CREATE TABLE ${SQLiteConfig.settingsTableName} (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              ${SQLiteConfig.languageCodeKey} TEXT,
              ${SQLiteConfig.countryCodeKey} TEXT,
              ${SQLiteConfig.themeModeKey} TEXT NOT NULL,
              ${SQLiteConfig.notifPrayersKey} INTEGER NOT NULL DEFAULT 0,
              ${SQLiteConfig.notifMorningAdhkarKey} INTEGER NOT NULL DEFAULT 0,
              ${SQLiteConfig.notifEveningAdhkarKey} INTEGER NOT NULL DEFAULT 0,
              ${SQLiteConfig.notifDailyAyahKey} INTEGER NOT NULL DEFAULT 0,
              ${SQLiteConfig.favoriteReciterKey} TEXT
            );
          ''');

          talker.debug('Created All tables for new app database');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute(
              'ALTER TABLE ${SQLiteConfig.settingsTableName} '
              'ADD COLUMN ${SQLiteConfig.notifPrayersKey} INTEGER NOT NULL DEFAULT 0;',
            );
            await db.execute(
              'ALTER TABLE ${SQLiteConfig.settingsTableName} '
              'ADD COLUMN ${SQLiteConfig.notifMorningAdhkarKey} INTEGER NOT NULL DEFAULT 0;',
            );
            await db.execute(
              'ALTER TABLE ${SQLiteConfig.settingsTableName} '
              'ADD COLUMN ${SQLiteConfig.notifEveningAdhkarKey} INTEGER NOT NULL DEFAULT 0;',
            );
            await db.execute(
              'ALTER TABLE ${SQLiteConfig.settingsTableName} '
              'ADD COLUMN ${SQLiteConfig.notifDailyAyahKey} INTEGER NOT NULL DEFAULT 0;',
            );
          }
          if (oldVersion < 3) {
            await db.execute(
              'ALTER TABLE ${SQLiteConfig.settingsTableName} '
              'ADD COLUMN ${SQLiteConfig.favoriteReciterKey} TEXT;',
            );
          }
        },
        onOpen: (db) async {
          await db.rawQuery('PRAGMA cipher_version;');
        },
      );
    } catch (e) {
      throw ex.DatabaseException(
        message: 'Error when we try to open database',
        type: ex.DatabaseExceptionType.read
      );
    }
  }

  Future<String> _getOrCreateDbPassword() async {
    final keyName = SecureStorageConfig.sqfliteDbPasswordKey;
    final existingKey = await secureStorage.readData(keyName);
    talker.debug('Find existing DB key');

    if (existingKey != null) {
      return existingKey;
    }

    final password = _generateDbKey();
    talker.debug('Generated new DB key');

    await secureStorage.writeData(keyName, password);
    talker.debug('Saved new DB key into secure storage');

    return password;
  }

  String _generateDbKey() {
    /// 32 bytes → AES-256
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64UrlEncode(bytes);
    return key;
  }

  @override
  String dayKey(DateTime date) {
    /// -- YYYY-MM-DD
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
