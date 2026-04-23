import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'duitku.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Profil Table
    await db.execute('''
      CREATE TABLE profiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT DEFAULT '',
        currency TEXT DEFAULT 'IDR',
        avatarType TEXT NOT NULL DEFAULT 'initials',
        avatarValue TEXT NOT NULL DEFAULT '',
        balance REAL NOT NULL DEFAULT 0.0,
        isCloudSynced INTEGER NOT NULL DEFAULT 0,
        pinHash TEXT
      )
    ''');

    // Category Table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        profileId TEXT NOT NULL,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        colorValue INTEGER NOT NULL,
        isDefault INTEGER NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');

    // Transaction Table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        profileId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        receiptUrl TEXT,
        isRecurring INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        syncStatus INTEGER NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Budget Table
    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        profileId TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        amountLimit REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        FOREIGN KEY (profileId) REFERENCES profiles (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
    
    // Seed default categories behavior should be called externally when creating a profile
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute("ALTER TABLE profiles ADD COLUMN email TEXT DEFAULT ''");
      await db.execute("ALTER TABLE profiles ADD COLUMN currency TEXT DEFAULT 'IDR'");
    }
  }
}
