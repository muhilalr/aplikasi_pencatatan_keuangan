import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_flutter/models/transaction_with_category.dart';
import 'category.dart';
import 'transaction.dart';

part 'database.g.dart';

// class TodoItems extends Table {
//   IntColumn get id => integer().autoIncrement()();
//   TextColumn get title => text().withLength(min: 6, max: 32)();
//   TextColumn get content => text().named('body')();
//   DateTimeColumn get createdAt => dateTime().nullable()();
// }

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD Category
  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((t) => t.type.equals(type))).get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((t) => t.id.equals(id))).go();
  }

  // Transaction
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
    DateTime date,
  ) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])..where(transactions.transaction_date.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  Future updateTransactionRepo(
    int id,
    int amount,
    int categoryId,
    DateTime transactionDate,
    String nameDetail,
  ) async {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        name: Value(nameDetail),
        category_id: Value(categoryId),
        transaction_date: Value(transactionDate),
        amount: Value(amount),
      ),
    );
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'my_database',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}
