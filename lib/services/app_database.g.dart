// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AuthStoreTable extends AuthStore
    with TableInfo<$AuthStoreTable, AuthStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuthStoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _selectedLocationIdMeta =
      const VerificationMeta('selectedLocationId');
  @override
  late final GeneratedColumn<String> selectedLocationId =
      GeneratedColumn<String>(
        'selected_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _companyLogoMeta = const VerificationMeta(
    'companyLogo',
  );
  @override
  late final GeneratedColumn<Uint8List> companyLogo =
      GeneratedColumn<Uint8List>(
        'company_logo',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    token,
    accountId,
    selectedLocationId,
    companyLogo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auth_store';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuthStoreData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('selected_location_id')) {
      context.handle(
        _selectedLocationIdMeta,
        selectedLocationId.isAcceptableOrUnknown(
          data['selected_location_id']!,
          _selectedLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('company_logo')) {
      context.handle(
        _companyLogoMeta,
        companyLogo.isAcceptableOrUnknown(
          data['company_logo']!,
          _companyLogoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuthStoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuthStoreData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      ),
      selectedLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}selected_location_id'],
      ),
      companyLogo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}company_logo'],
      ),
    );
  }

  @override
  $AuthStoreTable createAlias(String alias) {
    return $AuthStoreTable(attachedDatabase, alias);
  }
}

class AuthStoreData extends DataClass implements Insertable<AuthStoreData> {
  final int id;
  final String? token;
  final String? accountId;
  final String? selectedLocationId;
  final Uint8List? companyLogo;
  const AuthStoreData({
    required this.id,
    this.token,
    this.accountId,
    this.selectedLocationId,
    this.companyLogo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    if (!nullToAbsent || selectedLocationId != null) {
      map['selected_location_id'] = Variable<String>(selectedLocationId);
    }
    if (!nullToAbsent || companyLogo != null) {
      map['company_logo'] = Variable<Uint8List>(companyLogo);
    }
    return map;
  }

  AuthStoreCompanion toCompanion(bool nullToAbsent) {
    return AuthStoreCompanion(
      id: Value(id),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      selectedLocationId: selectedLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedLocationId),
      companyLogo: companyLogo == null && nullToAbsent
          ? const Value.absent()
          : Value(companyLogo),
    );
  }

  factory AuthStoreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuthStoreData(
      id: serializer.fromJson<int>(json['id']),
      token: serializer.fromJson<String?>(json['token']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      selectedLocationId: serializer.fromJson<String?>(
        json['selectedLocationId'],
      ),
      companyLogo: serializer.fromJson<Uint8List?>(json['companyLogo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'token': serializer.toJson<String?>(token),
      'accountId': serializer.toJson<String?>(accountId),
      'selectedLocationId': serializer.toJson<String?>(selectedLocationId),
      'companyLogo': serializer.toJson<Uint8List?>(companyLogo),
    };
  }

  AuthStoreData copyWith({
    int? id,
    Value<String?> token = const Value.absent(),
    Value<String?> accountId = const Value.absent(),
    Value<String?> selectedLocationId = const Value.absent(),
    Value<Uint8List?> companyLogo = const Value.absent(),
  }) => AuthStoreData(
    id: id ?? this.id,
    token: token.present ? token.value : this.token,
    accountId: accountId.present ? accountId.value : this.accountId,
    selectedLocationId: selectedLocationId.present
        ? selectedLocationId.value
        : this.selectedLocationId,
    companyLogo: companyLogo.present ? companyLogo.value : this.companyLogo,
  );
  AuthStoreData copyWithCompanion(AuthStoreCompanion data) {
    return AuthStoreData(
      id: data.id.present ? data.id.value : this.id,
      token: data.token.present ? data.token.value : this.token,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      selectedLocationId: data.selectedLocationId.present
          ? data.selectedLocationId.value
          : this.selectedLocationId,
      companyLogo: data.companyLogo.present
          ? data.companyLogo.value
          : this.companyLogo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuthStoreData(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('accountId: $accountId, ')
          ..write('selectedLocationId: $selectedLocationId, ')
          ..write('companyLogo: $companyLogo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    token,
    accountId,
    selectedLocationId,
    $driftBlobEquality.hash(companyLogo),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuthStoreData &&
          other.id == this.id &&
          other.token == this.token &&
          other.accountId == this.accountId &&
          other.selectedLocationId == this.selectedLocationId &&
          $driftBlobEquality.equals(other.companyLogo, this.companyLogo));
}

class AuthStoreCompanion extends UpdateCompanion<AuthStoreData> {
  final Value<int> id;
  final Value<String?> token;
  final Value<String?> accountId;
  final Value<String?> selectedLocationId;
  final Value<Uint8List?> companyLogo;
  const AuthStoreCompanion({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.accountId = const Value.absent(),
    this.selectedLocationId = const Value.absent(),
    this.companyLogo = const Value.absent(),
  });
  AuthStoreCompanion.insert({
    this.id = const Value.absent(),
    this.token = const Value.absent(),
    this.accountId = const Value.absent(),
    this.selectedLocationId = const Value.absent(),
    this.companyLogo = const Value.absent(),
  });
  static Insertable<AuthStoreData> custom({
    Expression<int>? id,
    Expression<String>? token,
    Expression<String>? accountId,
    Expression<String>? selectedLocationId,
    Expression<Uint8List>? companyLogo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (token != null) 'token': token,
      if (accountId != null) 'account_id': accountId,
      if (selectedLocationId != null)
        'selected_location_id': selectedLocationId,
      if (companyLogo != null) 'company_logo': companyLogo,
    });
  }

  AuthStoreCompanion copyWith({
    Value<int>? id,
    Value<String?>? token,
    Value<String?>? accountId,
    Value<String?>? selectedLocationId,
    Value<Uint8List?>? companyLogo,
  }) {
    return AuthStoreCompanion(
      id: id ?? this.id,
      token: token ?? this.token,
      accountId: accountId ?? this.accountId,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      companyLogo: companyLogo ?? this.companyLogo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (selectedLocationId.present) {
      map['selected_location_id'] = Variable<String>(selectedLocationId.value);
    }
    if (companyLogo.present) {
      map['company_logo'] = Variable<Uint8List>(companyLogo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuthStoreCompanion(')
          ..write('id: $id, ')
          ..write('token: $token, ')
          ..write('accountId: $accountId, ')
          ..write('selectedLocationId: $selectedLocationId, ')
          ..write('companyLogo: $companyLogo')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, Location> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subsidiaryIdMeta = const VerificationMeta(
    'subsidiaryId',
  );
  @override
  late final GeneratedColumn<String> subsidiaryId = GeneratedColumn<String>(
    'subsidiary_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subsidiaryNameMeta = const VerificationMeta(
    'subsidiaryName',
  );
  @override
  late final GeneratedColumn<String> subsidiaryName = GeneratedColumn<String>(
    'subsidiary_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    subsidiaryId,
    subsidiaryName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Location> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subsidiary_id')) {
      context.handle(
        _subsidiaryIdMeta,
        subsidiaryId.isAcceptableOrUnknown(
          data['subsidiary_id']!,
          _subsidiaryIdMeta,
        ),
      );
    }
    if (data.containsKey('subsidiary_name')) {
      context.handle(
        _subsidiaryNameMeta,
        subsidiaryName.isAcceptableOrUnknown(
          data['subsidiary_name']!,
          _subsidiaryNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Location map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Location(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      subsidiaryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subsidiary_id'],
      ),
      subsidiaryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subsidiary_name'],
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class Location extends DataClass implements Insertable<Location> {
  final String id;
  final String name;
  final String? subsidiaryId;
  final String? subsidiaryName;
  const Location({
    required this.id,
    required this.name,
    this.subsidiaryId,
    this.subsidiaryName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || subsidiaryId != null) {
      map['subsidiary_id'] = Variable<String>(subsidiaryId);
    }
    if (!nullToAbsent || subsidiaryName != null) {
      map['subsidiary_name'] = Variable<String>(subsidiaryName);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      subsidiaryId: subsidiaryId == null && nullToAbsent
          ? const Value.absent()
          : Value(subsidiaryId),
      subsidiaryName: subsidiaryName == null && nullToAbsent
          ? const Value.absent()
          : Value(subsidiaryName),
    );
  }

  factory Location.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Location(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      subsidiaryId: serializer.fromJson<String?>(json['subsidiaryId']),
      subsidiaryName: serializer.fromJson<String?>(json['subsidiaryName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'subsidiaryId': serializer.toJson<String?>(subsidiaryId),
      'subsidiaryName': serializer.toJson<String?>(subsidiaryName),
    };
  }

  Location copyWith({
    String? id,
    String? name,
    Value<String?> subsidiaryId = const Value.absent(),
    Value<String?> subsidiaryName = const Value.absent(),
  }) => Location(
    id: id ?? this.id,
    name: name ?? this.name,
    subsidiaryId: subsidiaryId.present ? subsidiaryId.value : this.subsidiaryId,
    subsidiaryName: subsidiaryName.present
        ? subsidiaryName.value
        : this.subsidiaryName,
  );
  Location copyWithCompanion(LocationsCompanion data) {
    return Location(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      subsidiaryId: data.subsidiaryId.present
          ? data.subsidiaryId.value
          : this.subsidiaryId,
      subsidiaryName: data.subsidiaryName.present
          ? data.subsidiaryName.value
          : this.subsidiaryName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Location(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subsidiaryId: $subsidiaryId, ')
          ..write('subsidiaryName: $subsidiaryName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, subsidiaryId, subsidiaryName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Location &&
          other.id == this.id &&
          other.name == this.name &&
          other.subsidiaryId == this.subsidiaryId &&
          other.subsidiaryName == this.subsidiaryName);
}

class LocationsCompanion extends UpdateCompanion<Location> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> subsidiaryId;
  final Value<String?> subsidiaryName;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.subsidiaryId = const Value.absent(),
    this.subsidiaryName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String name,
    this.subsidiaryId = const Value.absent(),
    this.subsidiaryName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Location> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? subsidiaryId,
    Expression<String>? subsidiaryName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (subsidiaryId != null) 'subsidiary_id': subsidiaryId,
      if (subsidiaryName != null) 'subsidiary_name': subsidiaryName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? subsidiaryId,
    Value<String?>? subsidiaryName,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      subsidiaryId: subsidiaryId ?? this.subsidiaryId,
      subsidiaryName: subsidiaryName ?? this.subsidiaryName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subsidiaryId.present) {
      map['subsidiary_id'] = Variable<String>(subsidiaryId.value);
    }
    if (subsidiaryName.present) {
      map['subsidiary_name'] = Variable<String>(subsidiaryName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('subsidiaryId: $subsidiaryId, ')
          ..write('subsidiaryName: $subsidiaryName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdjustmentAccountsTable extends AdjustmentAccounts
    with TableInfo<$AdjustmentAccountsTable, AdjustmentAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdjustmentAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adjustment_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdjustmentAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdjustmentAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdjustmentAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $AdjustmentAccountsTable createAlias(String alias) {
    return $AdjustmentAccountsTable(attachedDatabase, alias);
  }
}

class AdjustmentAccount extends DataClass
    implements Insertable<AdjustmentAccount> {
  final String id;
  final String name;
  const AdjustmentAccount({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  AdjustmentAccountsCompanion toCompanion(bool nullToAbsent) {
    return AdjustmentAccountsCompanion(id: Value(id), name: Value(name));
  }

  factory AdjustmentAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdjustmentAccount(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  AdjustmentAccount copyWith({String? id, String? name}) =>
      AdjustmentAccount(id: id ?? this.id, name: name ?? this.name);
  AdjustmentAccount copyWithCompanion(AdjustmentAccountsCompanion data) {
    return AdjustmentAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentAccount(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdjustmentAccount &&
          other.id == this.id &&
          other.name == this.name);
}

class AdjustmentAccountsCompanion extends UpdateCompanion<AdjustmentAccount> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const AdjustmentAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdjustmentAccountsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<AdjustmentAccount> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdjustmentAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return AdjustmentAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdjustmentAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upcMeta = const VerificationMeta('upc');
  @override
  late final GeneratedColumn<String> upc = GeneratedColumn<String>(
    'upc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLotItemMeta = const VerificationMeta(
    'isLotItem',
  );
  @override
  late final GeneratedColumn<bool> isLotItem = GeneratedColumn<bool>(
    'is_lot_item',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_lot_item" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSerialItemMeta = const VerificationMeta(
    'isSerialItem',
  );
  @override
  late final GeneratedColumn<bool> isSerialItem = GeneratedColumn<bool>(
    'is_serial_item',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_serial_item" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locationId,
    name,
    upc,
    isLotItem,
    isSerialItem,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('upc')) {
      context.handle(
        _upcMeta,
        upc.isAcceptableOrUnknown(data['upc']!, _upcMeta),
      );
    } else if (isInserting) {
      context.missing(_upcMeta);
    }
    if (data.containsKey('is_lot_item')) {
      context.handle(
        _isLotItemMeta,
        isLotItem.isAcceptableOrUnknown(data['is_lot_item']!, _isLotItemMeta),
      );
    }
    if (data.containsKey('is_serial_item')) {
      context.handle(
        _isSerialItemMeta,
        isSerialItem.isAcceptableOrUnknown(
          data['is_serial_item']!,
          _isSerialItemMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, locationId};
  @override
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      upc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upc'],
      )!,
      isLotItem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lot_item'],
      )!,
      isSerialItem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_serial_item'],
      )!,
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  final String id;
  final String locationId;
  final String name;
  final String upc;
  final bool isLotItem;
  final bool isSerialItem;
  const CatalogItem({
    required this.id,
    required this.locationId,
    required this.name,
    required this.upc,
    required this.isLotItem,
    required this.isSerialItem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['location_id'] = Variable<String>(locationId);
    map['name'] = Variable<String>(name);
    map['upc'] = Variable<String>(upc);
    map['is_lot_item'] = Variable<bool>(isLotItem);
    map['is_serial_item'] = Variable<bool>(isSerialItem);
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      locationId: Value(locationId),
      name: Value(name),
      upc: Value(upc),
      isLotItem: Value(isLotItem),
      isSerialItem: Value(isSerialItem),
    );
  }

  factory CatalogItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      id: serializer.fromJson<String>(json['id']),
      locationId: serializer.fromJson<String>(json['locationId']),
      name: serializer.fromJson<String>(json['name']),
      upc: serializer.fromJson<String>(json['upc']),
      isLotItem: serializer.fromJson<bool>(json['isLotItem']),
      isSerialItem: serializer.fromJson<bool>(json['isSerialItem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'locationId': serializer.toJson<String>(locationId),
      'name': serializer.toJson<String>(name),
      'upc': serializer.toJson<String>(upc),
      'isLotItem': serializer.toJson<bool>(isLotItem),
      'isSerialItem': serializer.toJson<bool>(isSerialItem),
    };
  }

  CatalogItem copyWith({
    String? id,
    String? locationId,
    String? name,
    String? upc,
    bool? isLotItem,
    bool? isSerialItem,
  }) => CatalogItem(
    id: id ?? this.id,
    locationId: locationId ?? this.locationId,
    name: name ?? this.name,
    upc: upc ?? this.upc,
    isLotItem: isLotItem ?? this.isLotItem,
    isSerialItem: isSerialItem ?? this.isSerialItem,
  );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      id: data.id.present ? data.id.value : this.id,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      name: data.name.present ? data.name.value : this.name,
      upc: data.upc.present ? data.upc.value : this.upc,
      isLotItem: data.isLotItem.present ? data.isLotItem.value : this.isLotItem,
      isSerialItem: data.isSerialItem.present
          ? data.isSerialItem.value
          : this.isSerialItem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('upc: $upc, ')
          ..write('isLotItem: $isLotItem, ')
          ..write('isSerialItem: $isSerialItem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationId, name, upc, isLotItem, isSerialItem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.id == this.id &&
          other.locationId == this.locationId &&
          other.name == this.name &&
          other.upc == this.upc &&
          other.isLotItem == this.isLotItem &&
          other.isSerialItem == this.isSerialItem);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<String> id;
  final Value<String> locationId;
  final Value<String> name;
  final Value<String> upc;
  final Value<bool> isLotItem;
  final Value<bool> isSerialItem;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.locationId = const Value.absent(),
    this.name = const Value.absent(),
    this.upc = const Value.absent(),
    this.isLotItem = const Value.absent(),
    this.isSerialItem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String id,
    required String locationId,
    required String name,
    required String upc,
    this.isLotItem = const Value.absent(),
    this.isSerialItem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       locationId = Value(locationId),
       name = Value(name),
       upc = Value(upc);
  static Insertable<CatalogItem> custom({
    Expression<String>? id,
    Expression<String>? locationId,
    Expression<String>? name,
    Expression<String>? upc,
    Expression<bool>? isLotItem,
    Expression<bool>? isSerialItem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationId != null) 'location_id': locationId,
      if (name != null) 'name': name,
      if (upc != null) 'upc': upc,
      if (isLotItem != null) 'is_lot_item': isLotItem,
      if (isSerialItem != null) 'is_serial_item': isSerialItem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? locationId,
    Value<String>? name,
    Value<String>? upc,
    Value<bool>? isLotItem,
    Value<bool>? isSerialItem,
    Value<int>? rowid,
  }) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      upc: upc ?? this.upc,
      isLotItem: isLotItem ?? this.isLotItem,
      isSerialItem: isSerialItem ?? this.isSerialItem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (upc.present) {
      map['upc'] = Variable<String>(upc.value);
    }
    if (isLotItem.present) {
      map['is_lot_item'] = Variable<bool>(isLotItem.value);
    }
    if (isSerialItem.present) {
      map['is_serial_item'] = Variable<bool>(isSerialItem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('upc: $upc, ')
          ..write('isLotItem: $isLotItem, ')
          ..write('isSerialItem: $isSerialItem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CountSessionsTable extends CountSessions
    with TableInfo<$CountSessionsTable, DbSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CountSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
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
  List<GeneratedColumn> get $columns => [
    id,
    locationId,
    locationName,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'count_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
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
  DbSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      )!,
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CountSessionsTable createAlias(String alias) {
    return $CountSessionsTable(attachedDatabase, alias);
  }
}

class DbSession extends DataClass implements Insertable<DbSession> {
  final String id;
  final String locationId;
  final String locationName;
  final String status;
  final DateTime createdAt;
  const DbSession({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['location_id'] = Variable<String>(locationId);
    map['location_name'] = Variable<String>(locationName);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CountSessionsCompanion toCompanion(bool nullToAbsent) {
    return CountSessionsCompanion(
      id: Value(id),
      locationId: Value(locationId),
      locationName: Value(locationName),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DbSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbSession(
      id: serializer.fromJson<String>(json['id']),
      locationId: serializer.fromJson<String>(json['locationId']),
      locationName: serializer.fromJson<String>(json['locationName']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'locationId': serializer.toJson<String>(locationId),
      'locationName': serializer.toJson<String>(locationName),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DbSession copyWith({
    String? id,
    String? locationId,
    String? locationName,
    String? status,
    DateTime? createdAt,
  }) => DbSession(
    id: id ?? this.id,
    locationId: locationId ?? this.locationId,
    locationName: locationName ?? this.locationName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DbSession copyWithCompanion(CountSessionsCompanion data) {
    return DbSession(
      id: data.id.present ? data.id.value : this.id,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbSession(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationId, locationName, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbSession &&
          other.id == this.id &&
          other.locationId == this.locationId &&
          other.locationName == this.locationName &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class CountSessionsCompanion extends UpdateCompanion<DbSession> {
  final Value<String> id;
  final Value<String> locationId;
  final Value<String> locationName;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CountSessionsCompanion({
    this.id = const Value.absent(),
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CountSessionsCompanion.insert({
    required String id,
    required String locationId,
    required String locationName,
    required String status,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       locationId = Value(locationId),
       locationName = Value(locationName),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<DbSession> custom({
    Expression<String>? id,
    Expression<String>? locationId,
    Expression<String>? locationName,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationId != null) 'location_id': locationId,
      if (locationName != null) 'location_name': locationName,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CountSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? locationId,
    Value<String>? locationName,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CountSessionsCompanion(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      status: status ?? this.status,
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
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
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
    return (StringBuffer('CountSessionsCompanion(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScannedItemsTable extends ScannedItems
    with TableInfo<$ScannedItemsTable, DbScannedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScannedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _upcMeta = const VerificationMeta('upc');
  @override
  late final GeneratedColumn<String> upc = GeneratedColumn<String>(
    'upc',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<int> qty = GeneratedColumn<int>(
    'qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLotItemMeta = const VerificationMeta(
    'isLotItem',
  );
  @override
  late final GeneratedColumn<bool> isLotItem = GeneratedColumn<bool>(
    'is_lot_item',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_lot_item" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSerialItemMeta = const VerificationMeta(
    'isSerialItem',
  );
  @override
  late final GeneratedColumn<bool> isSerialItem = GeneratedColumn<bool>(
    'is_serial_item',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_serial_item" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lotSerialDataMeta = const VerificationMeta(
    'lotSerialData',
  );
  @override
  late final GeneratedColumn<String> lotSerialData = GeneratedColumn<String>(
    'lot_serial_data',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    rowId,
    sessionId,
    itemId,
    upc,
    name,
    qty,
    isLotItem,
    isSerialItem,
    lotSerialData,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scanned_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<DbScannedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('upc')) {
      context.handle(
        _upcMeta,
        upc.isAcceptableOrUnknown(data['upc']!, _upcMeta),
      );
    } else if (isInserting) {
      context.missing(_upcMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
        _qtyMeta,
        qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta),
      );
    } else if (isInserting) {
      context.missing(_qtyMeta);
    }
    if (data.containsKey('is_lot_item')) {
      context.handle(
        _isLotItemMeta,
        isLotItem.isAcceptableOrUnknown(data['is_lot_item']!, _isLotItemMeta),
      );
    }
    if (data.containsKey('is_serial_item')) {
      context.handle(
        _isSerialItemMeta,
        isSerialItem.isAcceptableOrUnknown(
          data['is_serial_item']!,
          _isSerialItemMeta,
        ),
      );
    }
    if (data.containsKey('lot_serial_data')) {
      context.handle(
        _lotSerialDataMeta,
        lotSerialData.isAcceptableOrUnknown(
          data['lot_serial_data']!,
          _lotSerialDataMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {rowId};
  @override
  DbScannedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DbScannedItem(
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      upc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upc'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      qty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}qty'],
      )!,
      isLotItem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_lot_item'],
      )!,
      isSerialItem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_serial_item'],
      )!,
      lotSerialData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lot_serial_data'],
      ),
    );
  }

  @override
  $ScannedItemsTable createAlias(String alias) {
    return $ScannedItemsTable(attachedDatabase, alias);
  }
}

class DbScannedItem extends DataClass implements Insertable<DbScannedItem> {
  final int rowId;
  final String sessionId;
  final String itemId;
  final String upc;
  final String name;
  final int qty;
  final bool isLotItem;
  final bool isSerialItem;
  final String? lotSerialData;
  const DbScannedItem({
    required this.rowId,
    required this.sessionId,
    required this.itemId,
    required this.upc,
    required this.name,
    required this.qty,
    required this.isLotItem,
    required this.isSerialItem,
    this.lotSerialData,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['row_id'] = Variable<int>(rowId);
    map['session_id'] = Variable<String>(sessionId);
    map['item_id'] = Variable<String>(itemId);
    map['upc'] = Variable<String>(upc);
    map['name'] = Variable<String>(name);
    map['qty'] = Variable<int>(qty);
    map['is_lot_item'] = Variable<bool>(isLotItem);
    map['is_serial_item'] = Variable<bool>(isSerialItem);
    if (!nullToAbsent || lotSerialData != null) {
      map['lot_serial_data'] = Variable<String>(lotSerialData);
    }
    return map;
  }

  ScannedItemsCompanion toCompanion(bool nullToAbsent) {
    return ScannedItemsCompanion(
      rowId: Value(rowId),
      sessionId: Value(sessionId),
      itemId: Value(itemId),
      upc: Value(upc),
      name: Value(name),
      qty: Value(qty),
      isLotItem: Value(isLotItem),
      isSerialItem: Value(isSerialItem),
      lotSerialData: lotSerialData == null && nullToAbsent
          ? const Value.absent()
          : Value(lotSerialData),
    );
  }

  factory DbScannedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DbScannedItem(
      rowId: serializer.fromJson<int>(json['rowId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      upc: serializer.fromJson<String>(json['upc']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<int>(json['qty']),
      isLotItem: serializer.fromJson<bool>(json['isLotItem']),
      isSerialItem: serializer.fromJson<bool>(json['isSerialItem']),
      lotSerialData: serializer.fromJson<String?>(json['lotSerialData']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'rowId': serializer.toJson<int>(rowId),
      'sessionId': serializer.toJson<String>(sessionId),
      'itemId': serializer.toJson<String>(itemId),
      'upc': serializer.toJson<String>(upc),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<int>(qty),
      'isLotItem': serializer.toJson<bool>(isLotItem),
      'isSerialItem': serializer.toJson<bool>(isSerialItem),
      'lotSerialData': serializer.toJson<String?>(lotSerialData),
    };
  }

  DbScannedItem copyWith({
    int? rowId,
    String? sessionId,
    String? itemId,
    String? upc,
    String? name,
    int? qty,
    bool? isLotItem,
    bool? isSerialItem,
    Value<String?> lotSerialData = const Value.absent(),
  }) => DbScannedItem(
    rowId: rowId ?? this.rowId,
    sessionId: sessionId ?? this.sessionId,
    itemId: itemId ?? this.itemId,
    upc: upc ?? this.upc,
    name: name ?? this.name,
    qty: qty ?? this.qty,
    isLotItem: isLotItem ?? this.isLotItem,
    isSerialItem: isSerialItem ?? this.isSerialItem,
    lotSerialData: lotSerialData.present
        ? lotSerialData.value
        : this.lotSerialData,
  );
  DbScannedItem copyWithCompanion(ScannedItemsCompanion data) {
    return DbScannedItem(
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      upc: data.upc.present ? data.upc.value : this.upc,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      isLotItem: data.isLotItem.present ? data.isLotItem.value : this.isLotItem,
      isSerialItem: data.isSerialItem.present
          ? data.isSerialItem.value
          : this.isSerialItem,
      lotSerialData: data.lotSerialData.present
          ? data.lotSerialData.value
          : this.lotSerialData,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DbScannedItem(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('upc: $upc, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('isLotItem: $isLotItem, ')
          ..write('isSerialItem: $isSerialItem, ')
          ..write('lotSerialData: $lotSerialData')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    rowId,
    sessionId,
    itemId,
    upc,
    name,
    qty,
    isLotItem,
    isSerialItem,
    lotSerialData,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DbScannedItem &&
          other.rowId == this.rowId &&
          other.sessionId == this.sessionId &&
          other.itemId == this.itemId &&
          other.upc == this.upc &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.isLotItem == this.isLotItem &&
          other.isSerialItem == this.isSerialItem &&
          other.lotSerialData == this.lotSerialData);
}

class ScannedItemsCompanion extends UpdateCompanion<DbScannedItem> {
  final Value<int> rowId;
  final Value<String> sessionId;
  final Value<String> itemId;
  final Value<String> upc;
  final Value<String> name;
  final Value<int> qty;
  final Value<bool> isLotItem;
  final Value<bool> isSerialItem;
  final Value<String?> lotSerialData;
  const ScannedItemsCompanion({
    this.rowId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.upc = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.isLotItem = const Value.absent(),
    this.isSerialItem = const Value.absent(),
    this.lotSerialData = const Value.absent(),
  });
  ScannedItemsCompanion.insert({
    this.rowId = const Value.absent(),
    required String sessionId,
    required String itemId,
    required String upc,
    required String name,
    required int qty,
    this.isLotItem = const Value.absent(),
    this.isSerialItem = const Value.absent(),
    this.lotSerialData = const Value.absent(),
  }) : sessionId = Value(sessionId),
       itemId = Value(itemId),
       upc = Value(upc),
       name = Value(name),
       qty = Value(qty);
  static Insertable<DbScannedItem> custom({
    Expression<int>? rowId,
    Expression<String>? sessionId,
    Expression<String>? itemId,
    Expression<String>? upc,
    Expression<String>? name,
    Expression<int>? qty,
    Expression<bool>? isLotItem,
    Expression<bool>? isSerialItem,
    Expression<String>? lotSerialData,
  }) {
    return RawValuesInsertable({
      if (rowId != null) 'row_id': rowId,
      if (sessionId != null) 'session_id': sessionId,
      if (itemId != null) 'item_id': itemId,
      if (upc != null) 'upc': upc,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (isLotItem != null) 'is_lot_item': isLotItem,
      if (isSerialItem != null) 'is_serial_item': isSerialItem,
      if (lotSerialData != null) 'lot_serial_data': lotSerialData,
    });
  }

  ScannedItemsCompanion copyWith({
    Value<int>? rowId,
    Value<String>? sessionId,
    Value<String>? itemId,
    Value<String>? upc,
    Value<String>? name,
    Value<int>? qty,
    Value<bool>? isLotItem,
    Value<bool>? isSerialItem,
    Value<String?>? lotSerialData,
  }) {
    return ScannedItemsCompanion(
      rowId: rowId ?? this.rowId,
      sessionId: sessionId ?? this.sessionId,
      itemId: itemId ?? this.itemId,
      upc: upc ?? this.upc,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      isLotItem: isLotItem ?? this.isLotItem,
      isSerialItem: isSerialItem ?? this.isSerialItem,
      lotSerialData: lotSerialData ?? this.lotSerialData,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (upc.present) {
      map['upc'] = Variable<String>(upc.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<int>(qty.value);
    }
    if (isLotItem.present) {
      map['is_lot_item'] = Variable<bool>(isLotItem.value);
    }
    if (isSerialItem.present) {
      map['is_serial_item'] = Variable<bool>(isSerialItem.value);
    }
    if (lotSerialData.present) {
      map['lot_serial_data'] = Variable<String>(lotSerialData.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScannedItemsCompanion(')
          ..write('rowId: $rowId, ')
          ..write('sessionId: $sessionId, ')
          ..write('itemId: $itemId, ')
          ..write('upc: $upc, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('isLotItem: $isLotItem, ')
          ..write('isSerialItem: $isSerialItem, ')
          ..write('lotSerialData: $lotSerialData')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AuthStoreTable authStore = $AuthStoreTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $AdjustmentAccountsTable adjustmentAccounts =
      $AdjustmentAccountsTable(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $CountSessionsTable countSessions = $CountSessionsTable(this);
  late final $ScannedItemsTable scannedItems = $ScannedItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    authStore,
    locations,
    adjustmentAccounts,
    catalogItems,
    countSessions,
    scannedItems,
  ];
}

typedef $$AuthStoreTableCreateCompanionBuilder =
    AuthStoreCompanion Function({
      Value<int> id,
      Value<String?> token,
      Value<String?> accountId,
      Value<String?> selectedLocationId,
      Value<Uint8List?> companyLogo,
    });
typedef $$AuthStoreTableUpdateCompanionBuilder =
    AuthStoreCompanion Function({
      Value<int> id,
      Value<String?> token,
      Value<String?> accountId,
      Value<String?> selectedLocationId,
      Value<Uint8List?> companyLogo,
    });

class $$AuthStoreTableFilterComposer
    extends Composer<_$AppDatabase, $AuthStoreTable> {
  $$AuthStoreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get selectedLocationId => $composableBuilder(
    column: $table.selectedLocationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get companyLogo => $composableBuilder(
    column: $table.companyLogo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuthStoreTableOrderingComposer
    extends Composer<_$AppDatabase, $AuthStoreTable> {
  $$AuthStoreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get selectedLocationId => $composableBuilder(
    column: $table.selectedLocationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get companyLogo => $composableBuilder(
    column: $table.companyLogo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuthStoreTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuthStoreTable> {
  $$AuthStoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get selectedLocationId => $composableBuilder(
    column: $table.selectedLocationId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get companyLogo => $composableBuilder(
    column: $table.companyLogo,
    builder: (column) => column,
  );
}

class $$AuthStoreTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuthStoreTable,
          AuthStoreData,
          $$AuthStoreTableFilterComposer,
          $$AuthStoreTableOrderingComposer,
          $$AuthStoreTableAnnotationComposer,
          $$AuthStoreTableCreateCompanionBuilder,
          $$AuthStoreTableUpdateCompanionBuilder,
          (
            AuthStoreData,
            BaseReferences<_$AppDatabase, $AuthStoreTable, AuthStoreData>,
          ),
          AuthStoreData,
          PrefetchHooks Function()
        > {
  $$AuthStoreTableTableManager(_$AppDatabase db, $AuthStoreTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuthStoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuthStoreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuthStoreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> selectedLocationId = const Value.absent(),
                Value<Uint8List?> companyLogo = const Value.absent(),
              }) => AuthStoreCompanion(
                id: id,
                token: token,
                accountId: accountId,
                selectedLocationId: selectedLocationId,
                companyLogo: companyLogo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<String?> accountId = const Value.absent(),
                Value<String?> selectedLocationId = const Value.absent(),
                Value<Uint8List?> companyLogo = const Value.absent(),
              }) => AuthStoreCompanion.insert(
                id: id,
                token: token,
                accountId: accountId,
                selectedLocationId: selectedLocationId,
                companyLogo: companyLogo,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuthStoreTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuthStoreTable,
      AuthStoreData,
      $$AuthStoreTableFilterComposer,
      $$AuthStoreTableOrderingComposer,
      $$AuthStoreTableAnnotationComposer,
      $$AuthStoreTableCreateCompanionBuilder,
      $$AuthStoreTableUpdateCompanionBuilder,
      (
        AuthStoreData,
        BaseReferences<_$AppDatabase, $AuthStoreTable, AuthStoreData>,
      ),
      AuthStoreData,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String id,
      required String name,
      Value<String?> subsidiaryId,
      Value<String?> subsidiaryName,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> subsidiaryId,
      Value<String?> subsidiaryName,
      Value<int> rowid,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subsidiaryId => $composableBuilder(
    column: $table.subsidiaryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subsidiaryName => $composableBuilder(
    column: $table.subsidiaryName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subsidiaryId => $composableBuilder(
    column: $table.subsidiaryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subsidiaryName => $composableBuilder(
    column: $table.subsidiaryName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get subsidiaryId => $composableBuilder(
    column: $table.subsidiaryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subsidiaryName => $composableBuilder(
    column: $table.subsidiaryName,
    builder: (column) => column,
  );
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          Location,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
          Location,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> subsidiaryId = const Value.absent(),
                Value<String?> subsidiaryName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                name: name,
                subsidiaryId: subsidiaryId,
                subsidiaryName: subsidiaryName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> subsidiaryId = const Value.absent(),
                Value<String?> subsidiaryName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                name: name,
                subsidiaryId: subsidiaryId,
                subsidiaryName: subsidiaryName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      Location,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (Location, BaseReferences<_$AppDatabase, $LocationsTable, Location>),
      Location,
      PrefetchHooks Function()
    >;
typedef $$AdjustmentAccountsTableCreateCompanionBuilder =
    AdjustmentAccountsCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$AdjustmentAccountsTableUpdateCompanionBuilder =
    AdjustmentAccountsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

class $$AdjustmentAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AdjustmentAccountsTable> {
  $$AdjustmentAccountsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdjustmentAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdjustmentAccountsTable> {
  $$AdjustmentAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdjustmentAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdjustmentAccountsTable> {
  $$AdjustmentAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$AdjustmentAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdjustmentAccountsTable,
          AdjustmentAccount,
          $$AdjustmentAccountsTableFilterComposer,
          $$AdjustmentAccountsTableOrderingComposer,
          $$AdjustmentAccountsTableAnnotationComposer,
          $$AdjustmentAccountsTableCreateCompanionBuilder,
          $$AdjustmentAccountsTableUpdateCompanionBuilder,
          (
            AdjustmentAccount,
            BaseReferences<
              _$AppDatabase,
              $AdjustmentAccountsTable,
              AdjustmentAccount
            >,
          ),
          AdjustmentAccount,
          PrefetchHooks Function()
        > {
  $$AdjustmentAccountsTableTableManager(
    _$AppDatabase db,
    $AdjustmentAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdjustmentAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdjustmentAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdjustmentAccountsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  AdjustmentAccountsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => AdjustmentAccountsCompanion.insert(
                id: id,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdjustmentAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdjustmentAccountsTable,
      AdjustmentAccount,
      $$AdjustmentAccountsTableFilterComposer,
      $$AdjustmentAccountsTableOrderingComposer,
      $$AdjustmentAccountsTableAnnotationComposer,
      $$AdjustmentAccountsTableCreateCompanionBuilder,
      $$AdjustmentAccountsTableUpdateCompanionBuilder,
      (
        AdjustmentAccount,
        BaseReferences<
          _$AppDatabase,
          $AdjustmentAccountsTable,
          AdjustmentAccount
        >,
      ),
      AdjustmentAccount,
      PrefetchHooks Function()
    >;
typedef $$CatalogItemsTableCreateCompanionBuilder =
    CatalogItemsCompanion Function({
      required String id,
      required String locationId,
      required String name,
      required String upc,
      Value<bool> isLotItem,
      Value<bool> isSerialItem,
      Value<int> rowid,
    });
typedef $$CatalogItemsTableUpdateCompanionBuilder =
    CatalogItemsCompanion Function({
      Value<String> id,
      Value<String> locationId,
      Value<String> name,
      Value<String> upc,
      Value<bool> isLotItem,
      Value<bool> isSerialItem,
      Value<int> rowid,
    });

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
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

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLotItem => $composableBuilder(
    column: $table.isLotItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
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

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLotItem => $composableBuilder(
    column: $table.isLotItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get upc =>
      $composableBuilder(column: $table.upc, builder: (column) => column);

  GeneratedColumn<bool> get isLotItem =>
      $composableBuilder(column: $table.isLotItem, builder: (column) => column);

  GeneratedColumn<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => column,
  );
}

class $$CatalogItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogItemsTable,
          CatalogItem,
          $$CatalogItemsTableFilterComposer,
          $$CatalogItemsTableOrderingComposer,
          $$CatalogItemsTableAnnotationComposer,
          $$CatalogItemsTableCreateCompanionBuilder,
          $$CatalogItemsTableUpdateCompanionBuilder,
          (
            CatalogItem,
            BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>,
          ),
          CatalogItem,
          PrefetchHooks Function()
        > {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> upc = const Value.absent(),
                Value<bool> isLotItem = const Value.absent(),
                Value<bool> isSerialItem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion(
                id: id,
                locationId: locationId,
                name: name,
                upc: upc,
                isLotItem: isLotItem,
                isSerialItem: isSerialItem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String locationId,
                required String name,
                required String upc,
                Value<bool> isLotItem = const Value.absent(),
                Value<bool> isSerialItem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion.insert(
                id: id,
                locationId: locationId,
                name: name,
                upc: upc,
                isLotItem: isLotItem,
                isSerialItem: isSerialItem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CatalogItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogItemsTable,
      CatalogItem,
      $$CatalogItemsTableFilterComposer,
      $$CatalogItemsTableOrderingComposer,
      $$CatalogItemsTableAnnotationComposer,
      $$CatalogItemsTableCreateCompanionBuilder,
      $$CatalogItemsTableUpdateCompanionBuilder,
      (
        CatalogItem,
        BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem>,
      ),
      CatalogItem,
      PrefetchHooks Function()
    >;
typedef $$CountSessionsTableCreateCompanionBuilder =
    CountSessionsCompanion Function({
      required String id,
      required String locationId,
      required String locationName,
      required String status,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CountSessionsTableUpdateCompanionBuilder =
    CountSessionsCompanion Function({
      Value<String> id,
      Value<String> locationId,
      Value<String> locationName,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CountSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableFilterComposer({
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

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CountSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CountSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CountSessionsTable> {
  $$CountSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CountSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CountSessionsTable,
          DbSession,
          $$CountSessionsTableFilterComposer,
          $$CountSessionsTableOrderingComposer,
          $$CountSessionsTableAnnotationComposer,
          $$CountSessionsTableCreateCompanionBuilder,
          $$CountSessionsTableUpdateCompanionBuilder,
          (
            DbSession,
            BaseReferences<_$AppDatabase, $CountSessionsTable, DbSession>,
          ),
          DbSession,
          PrefetchHooks Function()
        > {
  $$CountSessionsTableTableManager(_$AppDatabase db, $CountSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CountSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CountSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CountSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> locationId = const Value.absent(),
                Value<String> locationName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CountSessionsCompanion(
                id: id,
                locationId: locationId,
                locationName: locationName,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String locationId,
                required String locationName,
                required String status,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CountSessionsCompanion.insert(
                id: id,
                locationId: locationId,
                locationName: locationName,
                status: status,
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

typedef $$CountSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CountSessionsTable,
      DbSession,
      $$CountSessionsTableFilterComposer,
      $$CountSessionsTableOrderingComposer,
      $$CountSessionsTableAnnotationComposer,
      $$CountSessionsTableCreateCompanionBuilder,
      $$CountSessionsTableUpdateCompanionBuilder,
      (
        DbSession,
        BaseReferences<_$AppDatabase, $CountSessionsTable, DbSession>,
      ),
      DbSession,
      PrefetchHooks Function()
    >;
typedef $$ScannedItemsTableCreateCompanionBuilder =
    ScannedItemsCompanion Function({
      Value<int> rowId,
      required String sessionId,
      required String itemId,
      required String upc,
      required String name,
      required int qty,
      Value<bool> isLotItem,
      Value<bool> isSerialItem,
      Value<String?> lotSerialData,
    });
typedef $$ScannedItemsTableUpdateCompanionBuilder =
    ScannedItemsCompanion Function({
      Value<int> rowId,
      Value<String> sessionId,
      Value<String> itemId,
      Value<String> upc,
      Value<String> name,
      Value<int> qty,
      Value<bool> isLotItem,
      Value<bool> isSerialItem,
      Value<String?> lotSerialData,
    });

class $$ScannedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ScannedItemsTable> {
  $$ScannedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLotItem => $composableBuilder(
    column: $table.isLotItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lotSerialData => $composableBuilder(
    column: $table.lotSerialData,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScannedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScannedItemsTable> {
  $$ScannedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get qty => $composableBuilder(
    column: $table.qty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLotItem => $composableBuilder(
    column: $table.isLotItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lotSerialData => $composableBuilder(
    column: $table.lotSerialData,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScannedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScannedItemsTable> {
  $$ScannedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get upc =>
      $composableBuilder(column: $table.upc, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<bool> get isLotItem =>
      $composableBuilder(column: $table.isLotItem, builder: (column) => column);

  GeneratedColumn<bool> get isSerialItem => $composableBuilder(
    column: $table.isSerialItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lotSerialData => $composableBuilder(
    column: $table.lotSerialData,
    builder: (column) => column,
  );
}

class $$ScannedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScannedItemsTable,
          DbScannedItem,
          $$ScannedItemsTableFilterComposer,
          $$ScannedItemsTableOrderingComposer,
          $$ScannedItemsTableAnnotationComposer,
          $$ScannedItemsTableCreateCompanionBuilder,
          $$ScannedItemsTableUpdateCompanionBuilder,
          (
            DbScannedItem,
            BaseReferences<_$AppDatabase, $ScannedItemsTable, DbScannedItem>,
          ),
          DbScannedItem,
          PrefetchHooks Function()
        > {
  $$ScannedItemsTableTableManager(_$AppDatabase db, $ScannedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScannedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScannedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScannedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> upc = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> qty = const Value.absent(),
                Value<bool> isLotItem = const Value.absent(),
                Value<bool> isSerialItem = const Value.absent(),
                Value<String?> lotSerialData = const Value.absent(),
              }) => ScannedItemsCompanion(
                rowId: rowId,
                sessionId: sessionId,
                itemId: itemId,
                upc: upc,
                name: name,
                qty: qty,
                isLotItem: isLotItem,
                isSerialItem: isSerialItem,
                lotSerialData: lotSerialData,
              ),
          createCompanionCallback:
              ({
                Value<int> rowId = const Value.absent(),
                required String sessionId,
                required String itemId,
                required String upc,
                required String name,
                required int qty,
                Value<bool> isLotItem = const Value.absent(),
                Value<bool> isSerialItem = const Value.absent(),
                Value<String?> lotSerialData = const Value.absent(),
              }) => ScannedItemsCompanion.insert(
                rowId: rowId,
                sessionId: sessionId,
                itemId: itemId,
                upc: upc,
                name: name,
                qty: qty,
                isLotItem: isLotItem,
                isSerialItem: isSerialItem,
                lotSerialData: lotSerialData,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScannedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScannedItemsTable,
      DbScannedItem,
      $$ScannedItemsTableFilterComposer,
      $$ScannedItemsTableOrderingComposer,
      $$ScannedItemsTableAnnotationComposer,
      $$ScannedItemsTableCreateCompanionBuilder,
      $$ScannedItemsTableUpdateCompanionBuilder,
      (
        DbScannedItem,
        BaseReferences<_$AppDatabase, $ScannedItemsTable, DbScannedItem>,
      ),
      DbScannedItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AuthStoreTableTableManager get authStore =>
      $$AuthStoreTableTableManager(_db, _db.authStore);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$AdjustmentAccountsTableTableManager get adjustmentAccounts =>
      $$AdjustmentAccountsTableTableManager(_db, _db.adjustmentAccounts);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$CountSessionsTableTableManager get countSessions =>
      $$CountSessionsTableTableManager(_db, _db.countSessions);
  $$ScannedItemsTableTableManager get scannedItems =>
      $$ScannedItemsTableTableManager(_db, _db.scannedItems);
}
