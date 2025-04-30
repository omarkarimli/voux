// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  ClothingItemDao? _clothingItemDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `ClothingItemFloorModel` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `imagePath` TEXT NOT NULL, `googleResults` TEXT NOT NULL, `clothingItemModel` TEXT NOT NULL, `optionalAnalysisResult` TEXT NOT NULL, `isSelected` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  ClothingItemDao get clothingItemDao {
    return _clothingItemDaoInstance ??=
        _$ClothingItemDao(database, changeListener);
  }
}

class _$ClothingItemDao extends ClothingItemDao {
  _$ClothingItemDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _clothingItemFloorModelInsertionAdapter = InsertionAdapter(
            database,
            'ClothingItemFloorModel',
            (ClothingItemFloorModel item) => <String, Object?>{
                  'id': item.id,
                  'imagePath': item.imagePath,
                  'googleResults':
                      _googleResultsConverter.encode(item.googleResults),
                  'clothingItemModel': _clothingItemModelConverter
                      .encode(item.clothingItemModel),
                  'optionalAnalysisResult': _optionalAnalysisResultConverter
                      .encode(item.optionalAnalysisResult),
                  'isSelected': item.isSelected ? 1 : 0
                },
            changeListener),
        _clothingItemFloorModelUpdateAdapter = UpdateAdapter(
            database,
            'ClothingItemFloorModel',
            ['id'],
            (ClothingItemFloorModel item) => <String, Object?>{
                  'id': item.id,
                  'imagePath': item.imagePath,
                  'googleResults':
                      _googleResultsConverter.encode(item.googleResults),
                  'clothingItemModel': _clothingItemModelConverter
                      .encode(item.clothingItemModel),
                  'optionalAnalysisResult': _optionalAnalysisResultConverter
                      .encode(item.optionalAnalysisResult),
                  'isSelected': item.isSelected ? 1 : 0
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<ClothingItemFloorModel>
      _clothingItemFloorModelInsertionAdapter;

  final UpdateAdapter<ClothingItemFloorModel>
      _clothingItemFloorModelUpdateAdapter;

  @override
  Future<List<ClothingItemFloorModel>> getAllClothingItemFloorModels() async {
    return _queryAdapter.queryList('SELECT * FROM ClothingItemFloorModel',
        mapper: (Map<String, Object?> row) => ClothingItemFloorModel(
            row['id'] as int?,
            row['imagePath'] as String,
            _googleResultsConverter.decode(row['googleResults'] as String),
            _clothingItemModelConverter
                .decode(row['clothingItemModel'] as String),
            _optionalAnalysisResultConverter
                .decode(row['optionalAnalysisResult'] as String)));
  }

  @override
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelById(int id) {
    return _queryAdapter.queryStream(
        'SELECT * FROM ClothingItemFloorModel WHERE id = ?1',
        mapper: (Map<String, Object?> row) => ClothingItemFloorModel(
            row['id'] as int?,
            row['imagePath'] as String,
            _googleResultsConverter.decode(row['googleResults'] as String),
            _clothingItemModelConverter
                .decode(row['clothingItemModel'] as String),
            _optionalAnalysisResultConverter
                .decode(row['optionalAnalysisResult'] as String)),
        arguments: [id],
        queryableName: 'ClothingItemFloorModel',
        isView: false);
  }

  @override
  Stream<ClothingItemFloorModel?> getClothingItemFloorModelByClothingItemModel(
      ClothingItemModel clothingItemModel) {
    return _queryAdapter.queryStream(
        'SELECT * FROM ClothingItemFloorModel WHERE clothingItemModel = ?1',
        mapper: (Map<String, Object?> row) => ClothingItemFloorModel(
            row['id'] as int?,
            row['imagePath'] as String,
            _googleResultsConverter.decode(row['googleResults'] as String),
            _clothingItemModelConverter
                .decode(row['clothingItemModel'] as String),
            _optionalAnalysisResultConverter
                .decode(row['optionalAnalysisResult'] as String)),
        arguments: [_clothingItemModelConverter.encode(clothingItemModel)],
        queryableName: 'ClothingItemFloorModel',
        isView: false);
  }

  @override
  Future<void> deleteClothingItemFloorModelById(int id) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ClothingItemFloorModel WHERE id = ?1',
        arguments: [id]);
  }

  @override
  Future<void> deleteClothingItemFloorModelByClothingItemModel(
      ClothingItemModel clothingItemModel) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM ClothingItemFloorModel WHERE clothingItemModel = ?1',
        arguments: [_clothingItemModelConverter.encode(clothingItemModel)]);
  }

  @override
  Future<void> deleteAllClothingItemFloorModels() async {
    await _queryAdapter.queryNoReturn('DELETE FROM ClothingItemFloorModel');
  }

  @override
  Future<void> insertClothingItemFloorModel(
      ClothingItemFloorModel clothingItemModel) async {
    await _clothingItemFloorModelInsertionAdapter.insert(
        clothingItemModel, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateClothingItemFloorModel(
      ClothingItemFloorModel clothingItemModel) async {
    await _clothingItemFloorModelUpdateAdapter.update(
        clothingItemModel, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _clothingItemModelConverter = ClothingItemModelConverter();
final _optionalAnalysisResultConverter = OptionalAnalysisResultConverter();
final _googleResultsConverter = GoogleResultsConverter();
