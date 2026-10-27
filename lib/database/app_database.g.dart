// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BaggageEventsTable extends BaggageEvents
    with TableInfo<$BaggageEventsTable, BaggageEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaggageEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baggageIdMeta = const VerificationMeta(
    'baggageId',
  );
  @override
  late final GeneratedColumn<String> baggageId = GeneratedColumn<String>(
    'baggage_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, baggageId, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'baggage_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaggageEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('baggage_id')) {
      context.handle(
        _baggageIdMeta,
        baggageId.isAcceptableOrUnknown(data['baggage_id']!, _baggageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_baggageIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BaggageEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaggageEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baggageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baggage_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BaggageEventsTable createAlias(String alias) {
    return $BaggageEventsTable(attachedDatabase, alias);
  }
}

class BaggageEventRow extends DataClass implements Insertable<BaggageEventRow> {
  final String id;
  final String baggageId;
  final String type;
  final DateTime createdAt;
  const BaggageEventRow({
    required this.id,
    required this.baggageId,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['baggage_id'] = Variable<String>(baggageId);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BaggageEventsCompanion toCompanion(bool nullToAbsent) {
    return BaggageEventsCompanion(
      id: Value(id),
      baggageId: Value(baggageId),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory BaggageEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaggageEventRow(
      id: serializer.fromJson<String>(json['id']),
      baggageId: serializer.fromJson<String>(json['baggageId']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baggageId': serializer.toJson<String>(baggageId),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BaggageEventRow copyWith({
    String? id,
    String? baggageId,
    String? type,
    DateTime? createdAt,
  }) => BaggageEventRow(
    id: id ?? this.id,
    baggageId: baggageId ?? this.baggageId,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  BaggageEventRow copyWithCompanion(BaggageEventsCompanion data) {
    return BaggageEventRow(
      id: data.id.present ? data.id.value : this.id,
      baggageId: data.baggageId.present ? data.baggageId.value : this.baggageId,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaggageEventRow(')
          ..write('id: $id, ')
          ..write('baggageId: $baggageId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, baggageId, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaggageEventRow &&
          other.id == this.id &&
          other.baggageId == this.baggageId &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class BaggageEventsCompanion extends UpdateCompanion<BaggageEventRow> {
  final Value<String> id;
  final Value<String> baggageId;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BaggageEventsCompanion({
    this.id = const Value.absent(),
    this.baggageId = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BaggageEventsCompanion.insert({
    required String id,
    required String baggageId,
    required String type,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baggageId = Value(baggageId),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<BaggageEventRow> custom({
    Expression<String>? id,
    Expression<String>? baggageId,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baggageId != null) 'baggage_id': baggageId,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BaggageEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? baggageId,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BaggageEventsCompanion(
      id: id ?? this.id,
      baggageId: baggageId ?? this.baggageId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baggageId.present) {
      map['baggage_id'] = Variable<String>(baggageId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaggageEventsCompanion(')
          ..write('id: $id, ')
          ..write('baggageId: $baggageId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BaggageEventsTable baggageEvents = $BaggageEventsTable(this);
  late final Index idxBaggageEventsBaggageId = Index(
    'idx_baggage_events_baggage_id',
    'CREATE INDEX idx_baggage_events_baggage_id ON baggage_events (baggage_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    baggageEvents,
    idxBaggageEventsBaggageId,
  ];
}

typedef $$BaggageEventsTableCreateCompanionBuilder =
    BaggageEventsCompanion Function({
      required String id,
      required String baggageId,
      required String type,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BaggageEventsTableUpdateCompanionBuilder =
    BaggageEventsCompanion Function({
      Value<String> id,
      Value<String> baggageId,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BaggageEventsTableFilterComposer
    extends Composer<_$AppDatabase, $BaggageEventsTable> {
  $$BaggageEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baggageId => $composableBuilder(
    column: $table.baggageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaggageEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $BaggageEventsTable> {
  $$BaggageEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baggageId => $composableBuilder(
    column: $table.baggageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaggageEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BaggageEventsTable> {
  $$BaggageEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baggageId =>
      $composableBuilder(column: $table.baggageId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BaggageEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BaggageEventsTable,
          BaggageEventRow,
          $$BaggageEventsTableFilterComposer,
          $$BaggageEventsTableOrderingComposer,
          $$BaggageEventsTableAnnotationComposer,
          $$BaggageEventsTableCreateCompanionBuilder,
          $$BaggageEventsTableUpdateCompanionBuilder,
          (
            BaggageEventRow,
            BaseReferences<_$AppDatabase, $BaggageEventsTable, BaggageEventRow>,
          ),
          BaggageEventRow,
          PrefetchHooks Function()
        > {
  $$BaggageEventsTableTableManager(_$AppDatabase db, $BaggageEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaggageEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BaggageEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BaggageEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baggageId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BaggageEventsCompanion(
                id: id,
                baggageId: baggageId,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baggageId,
                required String type,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BaggageEventsCompanion.insert(
                id: id,
                baggageId: baggageId,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaggageEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BaggageEventsTable,
      BaggageEventRow,
      $$BaggageEventsTableFilterComposer,
      $$BaggageEventsTableOrderingComposer,
      $$BaggageEventsTableAnnotationComposer,
      $$BaggageEventsTableCreateCompanionBuilder,
      $$BaggageEventsTableUpdateCompanionBuilder,
      (
        BaggageEventRow,
        BaseReferences<_$AppDatabase, $BaggageEventsTable, BaggageEventRow>,
      ),
      BaggageEventRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BaggageEventsTableTableManager get baggageEvents =>
      $$BaggageEventsTableTableManager(_db, _db.baggageEvents);
}
