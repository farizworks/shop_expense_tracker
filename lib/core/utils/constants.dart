class AppConstants {
  // App Info
  static const String appName = 'Shop Expense Tracker';
  static const String appVersion = '1.0.0';

  // Business Limits
  static const int maxBusinessCount = 5;

  // Shared Preferences Keys
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';

  // Database
  static const String databaseName = 'shop_tracker.db';
  static const int databaseVersion = 2; // Updated for expense items table

  // Table Names
  static const String tableBusinesses = 'businesses';
  static const String tableDailyEntries = 'daily_entries';
  static const String tableEmployees = 'employees';
  static const String tableExpenseItems = 'expense_items';

  // Date Formats
  static const String dateFormatDisplay = 'dd MMM yyyy';
  static const String dateFormatDatabase = 'yyyy-MM-dd';
  static const String dateTimeFormatDisplay = 'dd MMM yyyy, hh:mm a';

  // Validation Messages
  static const String errorEmptyField = 'This field cannot be empty';
  static const String errorInvalidNumber = 'Please enter a valid number';
  static const String errorMaxBusinessReached = 'Maximum 5 businesses allowed';

  // Business Categories
  static const List<String> businessCategories = [
    'Retail',
    'Restaurant',
    'Grocery',
    'Electronics',
    'Clothing',
    'Services',
    'Other',
  ];
}
