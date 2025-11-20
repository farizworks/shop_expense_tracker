import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create businesses table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBusinesses} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        place TEXT NOT NULL,
        category TEXT NOT NULL,
        vat_number TEXT,
        vat_expiry_date TEXT,
        vat_image_path TEXT,
        license_number TEXT,
        license_expiry_date TEXT,
        license_image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create daily_entries table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDailyEntries} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        entry_date TEXT NOT NULL,
        total_sale REAL NOT NULL DEFAULT 0,
        bank_amount REAL NOT NULL DEFAULT 0,
        cash_amount REAL NOT NULL DEFAULT 0,
        shop_expense REAL NOT NULL DEFAULT 0,
        misc_expense REAL NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (business_id) REFERENCES ${AppConstants.tableBusinesses} (id) ON DELETE CASCADE,
        UNIQUE(business_id, entry_date)
      )
    ''');

    // Create employees table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableEmployees} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        business_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        joining_date TEXT NOT NULL,
        visa_expiry_date TEXT,
        phone TEXT,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (business_id) REFERENCES ${AppConstants.tableBusinesses} (id) ON DELETE CASCADE
      )
    ''');

    // Create expense_items table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableExpenseItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        daily_entry_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (daily_entry_id) REFERENCES ${AppConstants.tableDailyEntries} (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_daily_entries_business_date
      ON ${AppConstants.tableDailyEntries} (business_id, entry_date)
    ''');

    await db.execute('''
      CREATE INDEX idx_employees_business
      ON ${AppConstants.tableEmployees} (business_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_expense_items_daily_entry
      ON ${AppConstants.tableExpenseItems} (daily_entry_id)
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here in future versions
    if (oldVersion < newVersion) {
      // Add migration logic here when needed
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
