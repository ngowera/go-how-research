// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _institutionIdMeta =
      const VerificationMeta('institutionId');
  @override
  late final GeneratedColumn<String> institutionId = GeneratedColumn<String>(
      'institution_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCurrentUserMeta =
      const VerificationMeta('isCurrentUser');
  @override
  late final GeneratedColumn<bool> isCurrentUser = GeneratedColumn<bool>(
      'is_current_user', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_current_user" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        email,
        name,
        role,
        institutionId,
        avatarUrl,
        createdAt,
        isCurrentUser
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('institution_id')) {
      context.handle(
          _institutionIdMeta,
          institutionId.isAcceptableOrUnknown(
              data['institution_id']!, _institutionIdMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_current_user')) {
      context.handle(
          _isCurrentUserMeta,
          isCurrentUser.isAcceptableOrUnknown(
              data['is_current_user']!, _isCurrentUserMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      institutionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}institution_id']),
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      isCurrentUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_current_user'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? institutionId;
  final String? avatarUrl;
  final String createdAt;
  final bool isCurrentUser;
  const User(
      {required this.id,
      required this.email,
      required this.name,
      required this.role,
      this.institutionId,
      this.avatarUrl,
      required this.createdAt,
      required this.isCurrentUser});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || institutionId != null) {
      map['institution_id'] = Variable<String>(institutionId);
    }
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['is_current_user'] = Variable<bool>(isCurrentUser);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      role: Value(role),
      institutionId: institutionId == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionId),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      createdAt: Value(createdAt),
      isCurrentUser: Value(isCurrentUser),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<String>(json['role']),
      institutionId: serializer.fromJson<String?>(json['institutionId']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      isCurrentUser: serializer.fromJson<bool>(json['isCurrentUser']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String>(role),
      'institutionId': serializer.toJson<String?>(institutionId),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'createdAt': serializer.toJson<String>(createdAt),
      'isCurrentUser': serializer.toJson<bool>(isCurrentUser),
    };
  }

  User copyWith(
          {String? id,
          String? email,
          String? name,
          String? role,
          Value<String?> institutionId = const Value.absent(),
          Value<String?> avatarUrl = const Value.absent(),
          String? createdAt,
          bool? isCurrentUser}) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        role: role ?? this.role,
        institutionId:
            institutionId.present ? institutionId.value : this.institutionId,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        createdAt: createdAt ?? this.createdAt,
        isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      institutionId: data.institutionId.present
          ? data.institutionId.value
          : this.institutionId,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isCurrentUser: data.isCurrentUser.present
          ? data.isCurrentUser.value
          : this.isCurrentUser,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('institutionId: $institutionId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCurrentUser: $isCurrentUser')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, name, role, institutionId,
      avatarUrl, createdAt, isCurrentUser);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.role == this.role &&
          other.institutionId == this.institutionId &&
          other.avatarUrl == this.avatarUrl &&
          other.createdAt == this.createdAt &&
          other.isCurrentUser == this.isCurrentUser);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  final Value<String> role;
  final Value<String?> institutionId;
  final Value<String?> avatarUrl;
  final Value<String> createdAt;
  final Value<bool> isCurrentUser;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.institutionId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isCurrentUser = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    required String name,
    required String role,
    this.institutionId = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    required String createdAt,
    this.isCurrentUser = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        name = Value(name),
        role = Value(role),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? institutionId,
    Expression<String>? avatarUrl,
    Expression<String>? createdAt,
    Expression<bool>? isCurrentUser,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (institutionId != null) 'institution_id': institutionId,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (isCurrentUser != null) 'is_current_user': isCurrentUser,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? name,
      Value<String>? role,
      Value<String?>? institutionId,
      Value<String?>? avatarUrl,
      Value<String>? createdAt,
      Value<bool>? isCurrentUser,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      institutionId: institutionId ?? this.institutionId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (institutionId.present) {
      map['institution_id'] = Variable<String>(institutionId.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (isCurrentUser.present) {
      map['is_current_user'] = Variable<bool>(isCurrentUser.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('institutionId: $institutionId, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('isCurrentUser: $isCurrentUser, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _objectivesMeta =
      const VerificationMeta('objectives');
  @override
  late final GeneratedColumn<String> objectives = GeneratedColumn<String>(
      'objectives', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _researchQuestionsMeta =
      const VerificationMeta('researchQuestions');
  @override
  late final GeneratedColumn<String> researchQuestions =
      GeneratedColumn<String>('research_questions', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('[]'));
  static const VerificationMeta _methodologyMeta =
      const VerificationMeta('methodology');
  @override
  late final GeneratedColumn<String> methodology = GeneratedColumn<String>(
      'methodology', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _populationMeta =
      const VerificationMeta('population');
  @override
  late final GeneratedColumn<String> population = GeneratedColumn<String>(
      'population', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sampleSizeMeta =
      const VerificationMeta('sampleSize');
  @override
  late final GeneratedColumn<int> sampleSize = GeneratedColumn<int>(
      'sample_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sitesMeta = const VerificationMeta('sites');
  @override
  late final GeneratedColumn<String> sites = GeneratedColumn<String>(
      'sites', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _supervisorIdMeta =
      const VerificationMeta('supervisorId');
  @override
  late final GeneratedColumn<String> supervisorId = GeneratedColumn<String>(
      'supervisor_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
      'end_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        objectives,
        researchQuestions,
        methodology,
        population,
        sampleSize,
        sites,
        status,
        ownerId,
        supervisorId,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('objectives')) {
      context.handle(
          _objectivesMeta,
          objectives.isAcceptableOrUnknown(
              data['objectives']!, _objectivesMeta));
    } else if (isInserting) {
      context.missing(_objectivesMeta);
    }
    if (data.containsKey('research_questions')) {
      context.handle(
          _researchQuestionsMeta,
          researchQuestions.isAcceptableOrUnknown(
              data['research_questions']!, _researchQuestionsMeta));
    }
    if (data.containsKey('methodology')) {
      context.handle(
          _methodologyMeta,
          methodology.isAcceptableOrUnknown(
              data['methodology']!, _methodologyMeta));
    } else if (isInserting) {
      context.missing(_methodologyMeta);
    }
    if (data.containsKey('population')) {
      context.handle(
          _populationMeta,
          population.isAcceptableOrUnknown(
              data['population']!, _populationMeta));
    } else if (isInserting) {
      context.missing(_populationMeta);
    }
    if (data.containsKey('sample_size')) {
      context.handle(
          _sampleSizeMeta,
          sampleSize.isAcceptableOrUnknown(
              data['sample_size']!, _sampleSizeMeta));
    }
    if (data.containsKey('sites')) {
      context.handle(
          _sitesMeta, sites.isAcceptableOrUnknown(data['sites']!, _sitesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('supervisor_id')) {
      context.handle(
          _supervisorIdMeta,
          supervisorId.isAcceptableOrUnknown(
              data['supervisor_id']!, _supervisorIdMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      objectives: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objectives'])!,
      researchQuestions: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}research_questions'])!,
      methodology: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}methodology'])!,
      population: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}population'])!,
      sampleSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sample_size'])!,
      sites: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sites'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      supervisorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supervisor_id']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_date']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String title;
  final String description;
  final String objectives;
  final String researchQuestions;
  final String methodology;
  final String population;
  final int sampleSize;
  final String sites;
  final String status;
  final String ownerId;
  final String? supervisorId;
  final String? startDate;
  final String? endDate;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  const Project(
      {required this.id,
      required this.title,
      required this.description,
      required this.objectives,
      required this.researchQuestions,
      required this.methodology,
      required this.population,
      required this.sampleSize,
      required this.sites,
      required this.status,
      required this.ownerId,
      this.supervisorId,
      this.startDate,
      this.endDate,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['objectives'] = Variable<String>(objectives);
    map['research_questions'] = Variable<String>(researchQuestions);
    map['methodology'] = Variable<String>(methodology);
    map['population'] = Variable<String>(population);
    map['sample_size'] = Variable<int>(sampleSize);
    map['sites'] = Variable<String>(sites);
    map['status'] = Variable<String>(status);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || supervisorId != null) {
      map['supervisor_id'] = Variable<String>(supervisorId);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<String>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(endDate);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      objectives: Value(objectives),
      researchQuestions: Value(researchQuestions),
      methodology: Value(methodology),
      population: Value(population),
      sampleSize: Value(sampleSize),
      sites: Value(sites),
      status: Value(status),
      ownerId: Value(ownerId),
      supervisorId: supervisorId == null && nullToAbsent
          ? const Value.absent()
          : Value(supervisorId),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      objectives: serializer.fromJson<String>(json['objectives']),
      researchQuestions: serializer.fromJson<String>(json['researchQuestions']),
      methodology: serializer.fromJson<String>(json['methodology']),
      population: serializer.fromJson<String>(json['population']),
      sampleSize: serializer.fromJson<int>(json['sampleSize']),
      sites: serializer.fromJson<String>(json['sites']),
      status: serializer.fromJson<String>(json['status']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      supervisorId: serializer.fromJson<String?>(json['supervisorId']),
      startDate: serializer.fromJson<String?>(json['startDate']),
      endDate: serializer.fromJson<String?>(json['endDate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'objectives': serializer.toJson<String>(objectives),
      'researchQuestions': serializer.toJson<String>(researchQuestions),
      'methodology': serializer.toJson<String>(methodology),
      'population': serializer.toJson<String>(population),
      'sampleSize': serializer.toJson<int>(sampleSize),
      'sites': serializer.toJson<String>(sites),
      'status': serializer.toJson<String>(status),
      'ownerId': serializer.toJson<String>(ownerId),
      'supervisorId': serializer.toJson<String?>(supervisorId),
      'startDate': serializer.toJson<String?>(startDate),
      'endDate': serializer.toJson<String?>(endDate),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Project copyWith(
          {String? id,
          String? title,
          String? description,
          String? objectives,
          String? researchQuestions,
          String? methodology,
          String? population,
          int? sampleSize,
          String? sites,
          String? status,
          String? ownerId,
          Value<String?> supervisorId = const Value.absent(),
          Value<String?> startDate = const Value.absent(),
          Value<String?> endDate = const Value.absent(),
          String? createdAt,
          String? updatedAt,
          String? syncStatus}) =>
      Project(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        objectives: objectives ?? this.objectives,
        researchQuestions: researchQuestions ?? this.researchQuestions,
        methodology: methodology ?? this.methodology,
        population: population ?? this.population,
        sampleSize: sampleSize ?? this.sampleSize,
        sites: sites ?? this.sites,
        status: status ?? this.status,
        ownerId: ownerId ?? this.ownerId,
        supervisorId:
            supervisorId.present ? supervisorId.value : this.supervisorId,
        startDate: startDate.present ? startDate.value : this.startDate,
        endDate: endDate.present ? endDate.value : this.endDate,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      objectives:
          data.objectives.present ? data.objectives.value : this.objectives,
      researchQuestions: data.researchQuestions.present
          ? data.researchQuestions.value
          : this.researchQuestions,
      methodology:
          data.methodology.present ? data.methodology.value : this.methodology,
      population:
          data.population.present ? data.population.value : this.population,
      sampleSize:
          data.sampleSize.present ? data.sampleSize.value : this.sampleSize,
      sites: data.sites.present ? data.sites.value : this.sites,
      status: data.status.present ? data.status.value : this.status,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      supervisorId: data.supervisorId.present
          ? data.supervisorId.value
          : this.supervisorId,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('objectives: $objectives, ')
          ..write('researchQuestions: $researchQuestions, ')
          ..write('methodology: $methodology, ')
          ..write('population: $population, ')
          ..write('sampleSize: $sampleSize, ')
          ..write('sites: $sites, ')
          ..write('status: $status, ')
          ..write('ownerId: $ownerId, ')
          ..write('supervisorId: $supervisorId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      objectives,
      researchQuestions,
      methodology,
      population,
      sampleSize,
      sites,
      status,
      ownerId,
      supervisorId,
      startDate,
      endDate,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.objectives == this.objectives &&
          other.researchQuestions == this.researchQuestions &&
          other.methodology == this.methodology &&
          other.population == this.population &&
          other.sampleSize == this.sampleSize &&
          other.sites == this.sites &&
          other.status == this.status &&
          other.ownerId == this.ownerId &&
          other.supervisorId == this.supervisorId &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<String> objectives;
  final Value<String> researchQuestions;
  final Value<String> methodology;
  final Value<String> population;
  final Value<int> sampleSize;
  final Value<String> sites;
  final Value<String> status;
  final Value<String> ownerId;
  final Value<String?> supervisorId;
  final Value<String?> startDate;
  final Value<String?> endDate;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.objectives = const Value.absent(),
    this.researchQuestions = const Value.absent(),
    this.methodology = const Value.absent(),
    this.population = const Value.absent(),
    this.sampleSize = const Value.absent(),
    this.sites = const Value.absent(),
    this.status = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.supervisorId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required String objectives,
    this.researchQuestions = const Value.absent(),
    required String methodology,
    required String population,
    this.sampleSize = const Value.absent(),
    this.sites = const Value.absent(),
    required String status,
    required String ownerId,
    this.supervisorId = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        objectives = Value(objectives),
        methodology = Value(methodology),
        population = Value(population),
        status = Value(status),
        ownerId = Value(ownerId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        syncStatus = Value(syncStatus);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? objectives,
    Expression<String>? researchQuestions,
    Expression<String>? methodology,
    Expression<String>? population,
    Expression<int>? sampleSize,
    Expression<String>? sites,
    Expression<String>? status,
    Expression<String>? ownerId,
    Expression<String>? supervisorId,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (objectives != null) 'objectives': objectives,
      if (researchQuestions != null) 'research_questions': researchQuestions,
      if (methodology != null) 'methodology': methodology,
      if (population != null) 'population': population,
      if (sampleSize != null) 'sample_size': sampleSize,
      if (sites != null) 'sites': sites,
      if (status != null) 'status': status,
      if (ownerId != null) 'owner_id': ownerId,
      if (supervisorId != null) 'supervisor_id': supervisorId,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<String>? objectives,
      Value<String>? researchQuestions,
      Value<String>? methodology,
      Value<String>? population,
      Value<int>? sampleSize,
      Value<String>? sites,
      Value<String>? status,
      Value<String>? ownerId,
      Value<String?>? supervisorId,
      Value<String?>? startDate,
      Value<String?>? endDate,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      objectives: objectives ?? this.objectives,
      researchQuestions: researchQuestions ?? this.researchQuestions,
      methodology: methodology ?? this.methodology,
      population: population ?? this.population,
      sampleSize: sampleSize ?? this.sampleSize,
      sites: sites ?? this.sites,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      supervisorId: supervisorId ?? this.supervisorId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (objectives.present) {
      map['objectives'] = Variable<String>(objectives.value);
    }
    if (researchQuestions.present) {
      map['research_questions'] = Variable<String>(researchQuestions.value);
    }
    if (methodology.present) {
      map['methodology'] = Variable<String>(methodology.value);
    }
    if (population.present) {
      map['population'] = Variable<String>(population.value);
    }
    if (sampleSize.present) {
      map['sample_size'] = Variable<int>(sampleSize.value);
    }
    if (sites.present) {
      map['sites'] = Variable<String>(sites.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (supervisorId.present) {
      map['supervisor_id'] = Variable<String>(supervisorId.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('objectives: $objectives, ')
          ..write('researchQuestions: $researchQuestions, ')
          ..write('methodology: $methodology, ')
          ..write('population: $population, ')
          ..write('sampleSize: $sampleSize, ')
          ..write('sites: $sites, ')
          ..write('status: $status, ')
          ..write('ownerId: $ownerId, ')
          ..write('supervisorId: $supervisorId, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionnairesTable extends Questionnaires
    with TableInfo<$QuestionnairesTable, QuestionnaireRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionnairesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isApprovedMeta =
      const VerificationMeta('isApproved');
  @override
  late final GeneratedColumn<bool> isApproved = GeneratedColumn<bool>(
      'is_approved', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_approved" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isPublishedMeta =
      const VerificationMeta('isPublished');
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
      'is_published', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_published" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        title,
        description,
        version,
        isApproved,
        isPublished,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questionnaires';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionnaireRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_approved')) {
      context.handle(
          _isApprovedMeta,
          isApproved.isAcceptableOrUnknown(
              data['is_approved']!, _isApprovedMeta));
    }
    if (data.containsKey('is_published')) {
      context.handle(
          _isPublishedMeta,
          isPublished.isAcceptableOrUnknown(
              data['is_published']!, _isPublishedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionnaireRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionnaireRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isApproved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_approved'])!,
      isPublished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_published'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $QuestionnairesTable createAlias(String alias) {
    return $QuestionnairesTable(attachedDatabase, alias);
  }
}

class QuestionnaireRow extends DataClass
    implements Insertable<QuestionnaireRow> {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final int version;
  final bool isApproved;
  final bool isPublished;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  const QuestionnaireRow(
      {required this.id,
      required this.projectId,
      required this.title,
      required this.description,
      required this.version,
      required this.isApproved,
      required this.isPublished,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['version'] = Variable<int>(version);
    map['is_approved'] = Variable<bool>(isApproved);
    map['is_published'] = Variable<bool>(isPublished);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  QuestionnairesCompanion toCompanion(bool nullToAbsent) {
    return QuestionnairesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      title: Value(title),
      description: Value(description),
      version: Value(version),
      isApproved: Value(isApproved),
      isPublished: Value(isPublished),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory QuestionnaireRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionnaireRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      version: serializer.fromJson<int>(json['version']),
      isApproved: serializer.fromJson<bool>(json['isApproved']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'version': serializer.toJson<int>(version),
      'isApproved': serializer.toJson<bool>(isApproved),
      'isPublished': serializer.toJson<bool>(isPublished),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  QuestionnaireRow copyWith(
          {String? id,
          String? projectId,
          String? title,
          String? description,
          int? version,
          bool? isApproved,
          bool? isPublished,
          String? createdAt,
          String? updatedAt,
          String? syncStatus}) =>
      QuestionnaireRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        description: description ?? this.description,
        version: version ?? this.version,
        isApproved: isApproved ?? this.isApproved,
        isPublished: isPublished ?? this.isPublished,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  QuestionnaireRow copyWithCompanion(QuestionnairesCompanion data) {
    return QuestionnaireRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      version: data.version.present ? data.version.value : this.version,
      isApproved:
          data.isApproved.present ? data.isApproved.value : this.isApproved,
      isPublished:
          data.isPublished.present ? data.isPublished.value : this.isPublished,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnaireRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('version: $version, ')
          ..write('isApproved: $isApproved, ')
          ..write('isPublished: $isPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, title, description, version,
      isApproved, isPublished, createdAt, updatedAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionnaireRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.version == this.version &&
          other.isApproved == this.isApproved &&
          other.isPublished == this.isPublished &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class QuestionnairesCompanion extends UpdateCompanion<QuestionnaireRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> title;
  final Value<String> description;
  final Value<int> version;
  final Value<bool> isApproved;
  final Value<bool> isPublished;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const QuestionnairesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.version = const Value.absent(),
    this.isApproved = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionnairesCompanion.insert({
    required String id,
    required String projectId,
    required String title,
    required String description,
    this.version = const Value.absent(),
    this.isApproved = const Value.absent(),
    this.isPublished = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        title = Value(title),
        description = Value(description),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt),
        syncStatus = Value(syncStatus);
  static Insertable<QuestionnaireRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? version,
    Expression<bool>? isApproved,
    Expression<bool>? isPublished,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (version != null) 'version': version,
      if (isApproved != null) 'is_approved': isApproved,
      if (isPublished != null) 'is_published': isPublished,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionnairesCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? title,
      Value<String>? description,
      Value<int>? version,
      Value<bool>? isApproved,
      Value<bool>? isPublished,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return QuestionnairesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      version: version ?? this.version,
      isApproved: isApproved ?? this.isApproved,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isApproved.present) {
      map['is_approved'] = Variable<bool>(isApproved.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnairesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('version: $version, ')
          ..write('isApproved: $isApproved, ')
          ..write('isPublished: $isPublished, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, QuestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionnaireIdMeta =
      const VerificationMeta('questionnaireId');
  @override
  late final GeneratedColumn<String> questionnaireId = GeneratedColumn<String>(
      'questionnaire_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _questionTypeMeta =
      const VerificationMeta('questionType');
  @override
  late final GeneratedColumn<String> questionType = GeneratedColumn<String>(
      'question_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionTextMeta =
      const VerificationMeta('questionText');
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
      'question_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _helpTextMeta =
      const VerificationMeta('helpText');
  @override
  late final GeneratedColumn<String> helpText = GeneratedColumn<String>(
      'help_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isRequiredMeta =
      const VerificationMeta('isRequired');
  @override
  late final GeneratedColumn<bool> isRequired = GeneratedColumn<bool>(
      'is_required', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_required" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _optionsJsonMeta =
      const VerificationMeta('optionsJson');
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
      'options_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _minValueMeta =
      const VerificationMeta('minValue');
  @override
  late final GeneratedColumn<double> minValue = GeneratedColumn<double>(
      'min_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _maxValueMeta =
      const VerificationMeta('maxValue');
  @override
  late final GeneratedColumn<double> maxValue = GeneratedColumn<double>(
      'max_value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _skipLogicJsonMeta =
      const VerificationMeta('skipLogicJson');
  @override
  late final GeneratedColumn<String> skipLogicJson = GeneratedColumn<String>(
      'skip_logic_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rowsJsonMeta =
      const VerificationMeta('rowsJson');
  @override
  late final GeneratedColumn<String> rowsJson = GeneratedColumn<String>(
      'rows_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _columnsJsonMeta =
      const VerificationMeta('columnsJson');
  @override
  late final GeneratedColumn<String> columnsJson = GeneratedColumn<String>(
      'columns_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questionnaireId,
        orderIndex,
        questionType,
        questionText,
        helpText,
        isRequired,
        optionsJson,
        minValue,
        maxValue,
        skipLogicJson,
        rowsJson,
        columnsJson
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('questionnaire_id')) {
      context.handle(
          _questionnaireIdMeta,
          questionnaireId.isAcceptableOrUnknown(
              data['questionnaire_id']!, _questionnaireIdMeta));
    } else if (isInserting) {
      context.missing(_questionnaireIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('question_type')) {
      context.handle(
          _questionTypeMeta,
          questionType.isAcceptableOrUnknown(
              data['question_type']!, _questionTypeMeta));
    } else if (isInserting) {
      context.missing(_questionTypeMeta);
    }
    if (data.containsKey('question_text')) {
      context.handle(
          _questionTextMeta,
          questionText.isAcceptableOrUnknown(
              data['question_text']!, _questionTextMeta));
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('help_text')) {
      context.handle(_helpTextMeta,
          helpText.isAcceptableOrUnknown(data['help_text']!, _helpTextMeta));
    }
    if (data.containsKey('is_required')) {
      context.handle(
          _isRequiredMeta,
          isRequired.isAcceptableOrUnknown(
              data['is_required']!, _isRequiredMeta));
    }
    if (data.containsKey('options_json')) {
      context.handle(
          _optionsJsonMeta,
          optionsJson.isAcceptableOrUnknown(
              data['options_json']!, _optionsJsonMeta));
    }
    if (data.containsKey('min_value')) {
      context.handle(_minValueMeta,
          minValue.isAcceptableOrUnknown(data['min_value']!, _minValueMeta));
    }
    if (data.containsKey('max_value')) {
      context.handle(_maxValueMeta,
          maxValue.isAcceptableOrUnknown(data['max_value']!, _maxValueMeta));
    }
    if (data.containsKey('skip_logic_json')) {
      context.handle(
          _skipLogicJsonMeta,
          skipLogicJson.isAcceptableOrUnknown(
              data['skip_logic_json']!, _skipLogicJsonMeta));
    }
    if (data.containsKey('rows_json')) {
      context.handle(_rowsJsonMeta,
          rowsJson.isAcceptableOrUnknown(data['rows_json']!, _rowsJsonMeta));
    }
    if (data.containsKey('columns_json')) {
      context.handle(
          _columnsJsonMeta,
          columnsJson.isAcceptableOrUnknown(
              data['columns_json']!, _columnsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questionnaireId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}questionnaire_id'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
      questionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_type'])!,
      questionText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question_text'])!,
      helpText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}help_text']),
      isRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_required'])!,
      optionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options_json'])!,
      minValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_value']),
      maxValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_value']),
      skipLogicJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skip_logic_json']),
      rowsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rows_json']),
      columnsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}columns_json']),
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class QuestionRow extends DataClass implements Insertable<QuestionRow> {
  final String id;
  final String questionnaireId;
  final int orderIndex;
  final String questionType;
  final String questionText;
  final String? helpText;
  final bool isRequired;
  final String optionsJson;
  final double? minValue;
  final double? maxValue;
  final String? skipLogicJson;
  final String? rowsJson;
  final String? columnsJson;
  const QuestionRow(
      {required this.id,
      required this.questionnaireId,
      required this.orderIndex,
      required this.questionType,
      required this.questionText,
      this.helpText,
      required this.isRequired,
      required this.optionsJson,
      this.minValue,
      this.maxValue,
      this.skipLogicJson,
      this.rowsJson,
      this.columnsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['questionnaire_id'] = Variable<String>(questionnaireId);
    map['order_index'] = Variable<int>(orderIndex);
    map['question_type'] = Variable<String>(questionType);
    map['question_text'] = Variable<String>(questionText);
    if (!nullToAbsent || helpText != null) {
      map['help_text'] = Variable<String>(helpText);
    }
    map['is_required'] = Variable<bool>(isRequired);
    map['options_json'] = Variable<String>(optionsJson);
    if (!nullToAbsent || minValue != null) {
      map['min_value'] = Variable<double>(minValue);
    }
    if (!nullToAbsent || maxValue != null) {
      map['max_value'] = Variable<double>(maxValue);
    }
    if (!nullToAbsent || skipLogicJson != null) {
      map['skip_logic_json'] = Variable<String>(skipLogicJson);
    }
    if (!nullToAbsent || rowsJson != null) {
      map['rows_json'] = Variable<String>(rowsJson);
    }
    if (!nullToAbsent || columnsJson != null) {
      map['columns_json'] = Variable<String>(columnsJson);
    }
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      questionnaireId: Value(questionnaireId),
      orderIndex: Value(orderIndex),
      questionType: Value(questionType),
      questionText: Value(questionText),
      helpText: helpText == null && nullToAbsent
          ? const Value.absent()
          : Value(helpText),
      isRequired: Value(isRequired),
      optionsJson: Value(optionsJson),
      minValue: minValue == null && nullToAbsent
          ? const Value.absent()
          : Value(minValue),
      maxValue: maxValue == null && nullToAbsent
          ? const Value.absent()
          : Value(maxValue),
      skipLogicJson: skipLogicJson == null && nullToAbsent
          ? const Value.absent()
          : Value(skipLogicJson),
      rowsJson: rowsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(rowsJson),
      columnsJson: columnsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(columnsJson),
    );
  }

  factory QuestionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionRow(
      id: serializer.fromJson<String>(json['id']),
      questionnaireId: serializer.fromJson<String>(json['questionnaireId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      questionType: serializer.fromJson<String>(json['questionType']),
      questionText: serializer.fromJson<String>(json['questionText']),
      helpText: serializer.fromJson<String?>(json['helpText']),
      isRequired: serializer.fromJson<bool>(json['isRequired']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      minValue: serializer.fromJson<double?>(json['minValue']),
      maxValue: serializer.fromJson<double?>(json['maxValue']),
      skipLogicJson: serializer.fromJson<String?>(json['skipLogicJson']),
      rowsJson: serializer.fromJson<String?>(json['rowsJson']),
      columnsJson: serializer.fromJson<String?>(json['columnsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionnaireId': serializer.toJson<String>(questionnaireId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'questionType': serializer.toJson<String>(questionType),
      'questionText': serializer.toJson<String>(questionText),
      'helpText': serializer.toJson<String?>(helpText),
      'isRequired': serializer.toJson<bool>(isRequired),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'minValue': serializer.toJson<double?>(minValue),
      'maxValue': serializer.toJson<double?>(maxValue),
      'skipLogicJson': serializer.toJson<String?>(skipLogicJson),
      'rowsJson': serializer.toJson<String?>(rowsJson),
      'columnsJson': serializer.toJson<String?>(columnsJson),
    };
  }

  QuestionRow copyWith(
          {String? id,
          String? questionnaireId,
          int? orderIndex,
          String? questionType,
          String? questionText,
          Value<String?> helpText = const Value.absent(),
          bool? isRequired,
          String? optionsJson,
          Value<double?> minValue = const Value.absent(),
          Value<double?> maxValue = const Value.absent(),
          Value<String?> skipLogicJson = const Value.absent(),
          Value<String?> rowsJson = const Value.absent(),
          Value<String?> columnsJson = const Value.absent()}) =>
      QuestionRow(
        id: id ?? this.id,
        questionnaireId: questionnaireId ?? this.questionnaireId,
        orderIndex: orderIndex ?? this.orderIndex,
        questionType: questionType ?? this.questionType,
        questionText: questionText ?? this.questionText,
        helpText: helpText.present ? helpText.value : this.helpText,
        isRequired: isRequired ?? this.isRequired,
        optionsJson: optionsJson ?? this.optionsJson,
        minValue: minValue.present ? minValue.value : this.minValue,
        maxValue: maxValue.present ? maxValue.value : this.maxValue,
        skipLogicJson:
            skipLogicJson.present ? skipLogicJson.value : this.skipLogicJson,
        rowsJson: rowsJson.present ? rowsJson.value : this.rowsJson,
        columnsJson: columnsJson.present ? columnsJson.value : this.columnsJson,
      );
  QuestionRow copyWithCompanion(QuestionsCompanion data) {
    return QuestionRow(
      id: data.id.present ? data.id.value : this.id,
      questionnaireId: data.questionnaireId.present
          ? data.questionnaireId.value
          : this.questionnaireId,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
      questionType: data.questionType.present
          ? data.questionType.value
          : this.questionType,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      helpText: data.helpText.present ? data.helpText.value : this.helpText,
      isRequired:
          data.isRequired.present ? data.isRequired.value : this.isRequired,
      optionsJson:
          data.optionsJson.present ? data.optionsJson.value : this.optionsJson,
      minValue: data.minValue.present ? data.minValue.value : this.minValue,
      maxValue: data.maxValue.present ? data.maxValue.value : this.maxValue,
      skipLogicJson: data.skipLogicJson.present
          ? data.skipLogicJson.value
          : this.skipLogicJson,
      rowsJson: data.rowsJson.present ? data.rowsJson.value : this.rowsJson,
      columnsJson:
          data.columnsJson.present ? data.columnsJson.value : this.columnsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionRow(')
          ..write('id: $id, ')
          ..write('questionnaireId: $questionnaireId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('questionType: $questionType, ')
          ..write('questionText: $questionText, ')
          ..write('helpText: $helpText, ')
          ..write('isRequired: $isRequired, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('skipLogicJson: $skipLogicJson, ')
          ..write('rowsJson: $rowsJson, ')
          ..write('columnsJson: $columnsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      questionnaireId,
      orderIndex,
      questionType,
      questionText,
      helpText,
      isRequired,
      optionsJson,
      minValue,
      maxValue,
      skipLogicJson,
      rowsJson,
      columnsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionRow &&
          other.id == this.id &&
          other.questionnaireId == this.questionnaireId &&
          other.orderIndex == this.orderIndex &&
          other.questionType == this.questionType &&
          other.questionText == this.questionText &&
          other.helpText == this.helpText &&
          other.isRequired == this.isRequired &&
          other.optionsJson == this.optionsJson &&
          other.minValue == this.minValue &&
          other.maxValue == this.maxValue &&
          other.skipLogicJson == this.skipLogicJson &&
          other.rowsJson == this.rowsJson &&
          other.columnsJson == this.columnsJson);
}

class QuestionsCompanion extends UpdateCompanion<QuestionRow> {
  final Value<String> id;
  final Value<String> questionnaireId;
  final Value<int> orderIndex;
  final Value<String> questionType;
  final Value<String> questionText;
  final Value<String?> helpText;
  final Value<bool> isRequired;
  final Value<String> optionsJson;
  final Value<double?> minValue;
  final Value<double?> maxValue;
  final Value<String?> skipLogicJson;
  final Value<String?> rowsJson;
  final Value<String?> columnsJson;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.questionnaireId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.questionType = const Value.absent(),
    this.questionText = const Value.absent(),
    this.helpText = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.skipLogicJson = const Value.absent(),
    this.rowsJson = const Value.absent(),
    this.columnsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required String questionnaireId,
    required int orderIndex,
    required String questionType,
    required String questionText,
    this.helpText = const Value.absent(),
    this.isRequired = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.minValue = const Value.absent(),
    this.maxValue = const Value.absent(),
    this.skipLogicJson = const Value.absent(),
    this.rowsJson = const Value.absent(),
    this.columnsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        questionnaireId = Value(questionnaireId),
        orderIndex = Value(orderIndex),
        questionType = Value(questionType),
        questionText = Value(questionText);
  static Insertable<QuestionRow> custom({
    Expression<String>? id,
    Expression<String>? questionnaireId,
    Expression<int>? orderIndex,
    Expression<String>? questionType,
    Expression<String>? questionText,
    Expression<String>? helpText,
    Expression<bool>? isRequired,
    Expression<String>? optionsJson,
    Expression<double>? minValue,
    Expression<double>? maxValue,
    Expression<String>? skipLogicJson,
    Expression<String>? rowsJson,
    Expression<String>? columnsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionnaireId != null) 'questionnaire_id': questionnaireId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (questionType != null) 'question_type': questionType,
      if (questionText != null) 'question_text': questionText,
      if (helpText != null) 'help_text': helpText,
      if (isRequired != null) 'is_required': isRequired,
      if (optionsJson != null) 'options_json': optionsJson,
      if (minValue != null) 'min_value': minValue,
      if (maxValue != null) 'max_value': maxValue,
      if (skipLogicJson != null) 'skip_logic_json': skipLogicJson,
      if (rowsJson != null) 'rows_json': rowsJson,
      if (columnsJson != null) 'columns_json': columnsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? questionnaireId,
      Value<int>? orderIndex,
      Value<String>? questionType,
      Value<String>? questionText,
      Value<String?>? helpText,
      Value<bool>? isRequired,
      Value<String>? optionsJson,
      Value<double?>? minValue,
      Value<double?>? maxValue,
      Value<String?>? skipLogicJson,
      Value<String?>? rowsJson,
      Value<String?>? columnsJson,
      Value<int>? rowid}) {
    return QuestionsCompanion(
      id: id ?? this.id,
      questionnaireId: questionnaireId ?? this.questionnaireId,
      orderIndex: orderIndex ?? this.orderIndex,
      questionType: questionType ?? this.questionType,
      questionText: questionText ?? this.questionText,
      helpText: helpText ?? this.helpText,
      isRequired: isRequired ?? this.isRequired,
      optionsJson: optionsJson ?? this.optionsJson,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      skipLogicJson: skipLogicJson ?? this.skipLogicJson,
      rowsJson: rowsJson ?? this.rowsJson,
      columnsJson: columnsJson ?? this.columnsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionnaireId.present) {
      map['questionnaire_id'] = Variable<String>(questionnaireId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (questionType.present) {
      map['question_type'] = Variable<String>(questionType.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (helpText.present) {
      map['help_text'] = Variable<String>(helpText.value);
    }
    if (isRequired.present) {
      map['is_required'] = Variable<bool>(isRequired.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (minValue.present) {
      map['min_value'] = Variable<double>(minValue.value);
    }
    if (maxValue.present) {
      map['max_value'] = Variable<double>(maxValue.value);
    }
    if (skipLogicJson.present) {
      map['skip_logic_json'] = Variable<String>(skipLogicJson.value);
    }
    if (rowsJson.present) {
      map['rows_json'] = Variable<String>(rowsJson.value);
    }
    if (columnsJson.present) {
      map['columns_json'] = Variable<String>(columnsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('questionnaireId: $questionnaireId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('questionType: $questionType, ')
          ..write('questionText: $questionText, ')
          ..write('helpText: $helpText, ')
          ..write('isRequired: $isRequired, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('minValue: $minValue, ')
          ..write('maxValue: $maxValue, ')
          ..write('skipLogicJson: $skipLogicJson, ')
          ..write('rowsJson: $rowsJson, ')
          ..write('columnsJson: $columnsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResponsesTable extends Responses
    with TableInfo<$ResponsesTable, Response> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionnaireIdMeta =
      const VerificationMeta('questionnaireId');
  @override
  late final GeneratedColumn<String> questionnaireId = GeneratedColumn<String>(
      'questionnaire_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _participantIdMeta =
      const VerificationMeta('participantId');
  @override
  late final GeneratedColumn<String> participantId = GeneratedColumn<String>(
      'participant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responsesJsonMeta =
      const VerificationMeta('responsesJson');
  @override
  late final GeneratedColumn<String> responsesJson = GeneratedColumn<String>(
      'responses_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _collectedAtMeta =
      const VerificationMeta('collectedAt');
  @override
  late final GeneratedColumn<String> collectedAt = GeneratedColumn<String>(
      'collected_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        questionnaireId,
        participantId,
        responsesJson,
        collectedAt,
        syncStatus,
        latitude,
        longitude
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'responses';
  @override
  VerificationContext validateIntegrity(Insertable<Response> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('questionnaire_id')) {
      context.handle(
          _questionnaireIdMeta,
          questionnaireId.isAcceptableOrUnknown(
              data['questionnaire_id']!, _questionnaireIdMeta));
    } else if (isInserting) {
      context.missing(_questionnaireIdMeta);
    }
    if (data.containsKey('participant_id')) {
      context.handle(
          _participantIdMeta,
          participantId.isAcceptableOrUnknown(
              data['participant_id']!, _participantIdMeta));
    } else if (isInserting) {
      context.missing(_participantIdMeta);
    }
    if (data.containsKey('responses_json')) {
      context.handle(
          _responsesJsonMeta,
          responsesJson.isAcceptableOrUnknown(
              data['responses_json']!, _responsesJsonMeta));
    } else if (isInserting) {
      context.missing(_responsesJsonMeta);
    }
    if (data.containsKey('collected_at')) {
      context.handle(
          _collectedAtMeta,
          collectedAt.isAcceptableOrUnknown(
              data['collected_at']!, _collectedAtMeta));
    } else if (isInserting) {
      context.missing(_collectedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Response map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Response(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      questionnaireId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}questionnaire_id'])!,
      participantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}participant_id'])!,
      responsesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}responses_json'])!,
      collectedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collected_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
    );
  }

  @override
  $ResponsesTable createAlias(String alias) {
    return $ResponsesTable(attachedDatabase, alias);
  }
}

class Response extends DataClass implements Insertable<Response> {
  final String id;
  final String questionnaireId;
  final String participantId;
  final String responsesJson;
  final String collectedAt;
  final String syncStatus;
  final double? latitude;
  final double? longitude;
  const Response(
      {required this.id,
      required this.questionnaireId,
      required this.participantId,
      required this.responsesJson,
      required this.collectedAt,
      required this.syncStatus,
      this.latitude,
      this.longitude});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['questionnaire_id'] = Variable<String>(questionnaireId);
    map['participant_id'] = Variable<String>(participantId);
    map['responses_json'] = Variable<String>(responsesJson);
    map['collected_at'] = Variable<String>(collectedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    return map;
  }

  ResponsesCompanion toCompanion(bool nullToAbsent) {
    return ResponsesCompanion(
      id: Value(id),
      questionnaireId: Value(questionnaireId),
      participantId: Value(participantId),
      responsesJson: Value(responsesJson),
      collectedAt: Value(collectedAt),
      syncStatus: Value(syncStatus),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
    );
  }

  factory Response.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Response(
      id: serializer.fromJson<String>(json['id']),
      questionnaireId: serializer.fromJson<String>(json['questionnaireId']),
      participantId: serializer.fromJson<String>(json['participantId']),
      responsesJson: serializer.fromJson<String>(json['responsesJson']),
      collectedAt: serializer.fromJson<String>(json['collectedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionnaireId': serializer.toJson<String>(questionnaireId),
      'participantId': serializer.toJson<String>(participantId),
      'responsesJson': serializer.toJson<String>(responsesJson),
      'collectedAt': serializer.toJson<String>(collectedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
    };
  }

  Response copyWith(
          {String? id,
          String? questionnaireId,
          String? participantId,
          String? responsesJson,
          String? collectedAt,
          String? syncStatus,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent()}) =>
      Response(
        id: id ?? this.id,
        questionnaireId: questionnaireId ?? this.questionnaireId,
        participantId: participantId ?? this.participantId,
        responsesJson: responsesJson ?? this.responsesJson,
        collectedAt: collectedAt ?? this.collectedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
      );
  Response copyWithCompanion(ResponsesCompanion data) {
    return Response(
      id: data.id.present ? data.id.value : this.id,
      questionnaireId: data.questionnaireId.present
          ? data.questionnaireId.value
          : this.questionnaireId,
      participantId: data.participantId.present
          ? data.participantId.value
          : this.participantId,
      responsesJson: data.responsesJson.present
          ? data.responsesJson.value
          : this.responsesJson,
      collectedAt:
          data.collectedAt.present ? data.collectedAt.value : this.collectedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Response(')
          ..write('id: $id, ')
          ..write('questionnaireId: $questionnaireId, ')
          ..write('participantId: $participantId, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, questionnaireId, participantId,
      responsesJson, collectedAt, syncStatus, latitude, longitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Response &&
          other.id == this.id &&
          other.questionnaireId == this.questionnaireId &&
          other.participantId == this.participantId &&
          other.responsesJson == this.responsesJson &&
          other.collectedAt == this.collectedAt &&
          other.syncStatus == this.syncStatus &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude);
}

class ResponsesCompanion extends UpdateCompanion<Response> {
  final Value<String> id;
  final Value<String> questionnaireId;
  final Value<String> participantId;
  final Value<String> responsesJson;
  final Value<String> collectedAt;
  final Value<String> syncStatus;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int> rowid;
  const ResponsesCompanion({
    this.id = const Value.absent(),
    this.questionnaireId = const Value.absent(),
    this.participantId = const Value.absent(),
    this.responsesJson = const Value.absent(),
    this.collectedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResponsesCompanion.insert({
    required String id,
    required String questionnaireId,
    required String participantId,
    required String responsesJson,
    required String collectedAt,
    required String syncStatus,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        questionnaireId = Value(questionnaireId),
        participantId = Value(participantId),
        responsesJson = Value(responsesJson),
        collectedAt = Value(collectedAt),
        syncStatus = Value(syncStatus);
  static Insertable<Response> custom({
    Expression<String>? id,
    Expression<String>? questionnaireId,
    Expression<String>? participantId,
    Expression<String>? responsesJson,
    Expression<String>? collectedAt,
    Expression<String>? syncStatus,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionnaireId != null) 'questionnaire_id': questionnaireId,
      if (participantId != null) 'participant_id': participantId,
      if (responsesJson != null) 'responses_json': responsesJson,
      if (collectedAt != null) 'collected_at': collectedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResponsesCompanion copyWith(
      {Value<String>? id,
      Value<String>? questionnaireId,
      Value<String>? participantId,
      Value<String>? responsesJson,
      Value<String>? collectedAt,
      Value<String>? syncStatus,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<int>? rowid}) {
    return ResponsesCompanion(
      id: id ?? this.id,
      questionnaireId: questionnaireId ?? this.questionnaireId,
      participantId: participantId ?? this.participantId,
      responsesJson: responsesJson ?? this.responsesJson,
      collectedAt: collectedAt ?? this.collectedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionnaireId.present) {
      map['questionnaire_id'] = Variable<String>(questionnaireId.value);
    }
    if (participantId.present) {
      map['participant_id'] = Variable<String>(participantId.value);
    }
    if (responsesJson.present) {
      map['responses_json'] = Variable<String>(responsesJson.value);
    }
    if (collectedAt.present) {
      map['collected_at'] = Variable<String>(collectedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResponsesCompanion(')
          ..write('id: $id, ')
          ..write('questionnaireId: $questionnaireId, ')
          ..write('participantId: $participantId, ')
          ..write('responsesJson: $responsesJson, ')
          ..write('collectedAt: $collectedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ParticipantsTable extends Participants
    with TableInfo<$ParticipantsTable, ParticipantRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ParticipantsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hasConsentedMeta =
      const VerificationMeta('hasConsented');
  @override
  late final GeneratedColumn<bool> hasConsented = GeneratedColumn<bool>(
      'has_consented', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_consented" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _consentDateMeta =
      const VerificationMeta('consentDate');
  @override
  late final GeneratedColumn<String> consentDate = GeneratedColumn<String>(
      'consent_date', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        projectId,
        code,
        name,
        phone,
        email,
        hasConsented,
        consentDate,
        notes,
        createdAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'participants';
  @override
  VerificationContext validateIntegrity(Insertable<ParticipantRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('has_consented')) {
      context.handle(
          _hasConsentedMeta,
          hasConsented.isAcceptableOrUnknown(
              data['has_consented']!, _hasConsentedMeta));
    }
    if (data.containsKey('consent_date')) {
      context.handle(
          _consentDateMeta,
          consentDate.isAcceptableOrUnknown(
              data['consent_date']!, _consentDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ParticipantRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ParticipantRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      hasConsented: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_consented'])!,
      consentDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}consent_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ParticipantsTable createAlias(String alias) {
    return $ParticipantsTable(attachedDatabase, alias);
  }
}

class ParticipantRow extends DataClass implements Insertable<ParticipantRow> {
  final String id;
  final String projectId;
  final String code;
  final String name;
  final String? phone;
  final String? email;
  final bool hasConsented;
  final String? consentDate;
  final String? notes;
  final String createdAt;
  final String syncStatus;
  const ParticipantRow(
      {required this.id,
      required this.projectId,
      required this.code,
      required this.name,
      this.phone,
      this.email,
      required this.hasConsented,
      this.consentDate,
      this.notes,
      required this.createdAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['has_consented'] = Variable<bool>(hasConsented);
    if (!nullToAbsent || consentDate != null) {
      map['consent_date'] = Variable<String>(consentDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ParticipantsCompanion toCompanion(bool nullToAbsent) {
    return ParticipantsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      code: Value(code),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      hasConsented: Value(hasConsented),
      consentDate: consentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(consentDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ParticipantRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ParticipantRow(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      hasConsented: serializer.fromJson<bool>(json['hasConsented']),
      consentDate: serializer.fromJson<String?>(json['consentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'hasConsented': serializer.toJson<bool>(hasConsented),
      'consentDate': serializer.toJson<String?>(consentDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ParticipantRow copyWith(
          {String? id,
          String? projectId,
          String? code,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> email = const Value.absent(),
          bool? hasConsented,
          Value<String?> consentDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? createdAt,
          String? syncStatus}) =>
      ParticipantRow(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        code: code ?? this.code,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        email: email.present ? email.value : this.email,
        hasConsented: hasConsented ?? this.hasConsented,
        consentDate: consentDate.present ? consentDate.value : this.consentDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ParticipantRow copyWithCompanion(ParticipantsCompanion data) {
    return ParticipantRow(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      hasConsented: data.hasConsented.present
          ? data.hasConsented.value
          : this.hasConsented,
      consentDate:
          data.consentDate.present ? data.consentDate.value : this.consentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantRow(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('hasConsented: $hasConsented, ')
          ..write('consentDate: $consentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, code, name, phone, email,
      hasConsented, consentDate, notes, createdAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ParticipantRow &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.code == this.code &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.hasConsented == this.hasConsented &&
          other.consentDate == this.consentDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.syncStatus == this.syncStatus);
}

class ParticipantsCompanion extends UpdateCompanion<ParticipantRow> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<bool> hasConsented;
  final Value<String?> consentDate;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ParticipantsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.hasConsented = const Value.absent(),
    this.consentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ParticipantsCompanion.insert({
    required String id,
    required String projectId,
    required String code,
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.hasConsented = const Value.absent(),
    this.consentDate = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    required String syncStatus,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        projectId = Value(projectId),
        code = Value(code),
        name = Value(name),
        createdAt = Value(createdAt),
        syncStatus = Value(syncStatus);
  static Insertable<ParticipantRow> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<bool>? hasConsented,
    Expression<String>? consentDate,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (hasConsented != null) 'has_consented': hasConsented,
      if (consentDate != null) 'consent_date': consentDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ParticipantsCompanion copyWith(
      {Value<String>? id,
      Value<String>? projectId,
      Value<String>? code,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? email,
      Value<bool>? hasConsented,
      Value<String?>? consentDate,
      Value<String?>? notes,
      Value<String>? createdAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ParticipantsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      code: code ?? this.code,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hasConsented: hasConsented ?? this.hasConsented,
      consentDate: consentDate ?? this.consentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (hasConsented.present) {
      map['has_consented'] = Variable<bool>(hasConsented.value);
    }
    if (consentDate.present) {
      map['consent_date'] = Variable<String>(consentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ParticipantsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('hasConsented: $hasConsented, ')
          ..write('consentDate: $consentDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncDeletionsTable extends SyncDeletions
    with TableInfo<$SyncDeletionsTable, SyncDeletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDeletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [entityType, entityId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_deletions';
  @override
  VerificationContext validateIntegrity(Insertable<SyncDeletion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncDeletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDeletion(
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncDeletionsTable createAlias(String alias) {
    return $SyncDeletionsTable(attachedDatabase, alias);
  }
}

class SyncDeletion extends DataClass implements Insertable<SyncDeletion> {
  final String entityType;
  final String entityId;
  final String createdAt;
  const SyncDeletion(
      {required this.entityType,
      required this.entityId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  SyncDeletionsCompanion toCompanion(bool nullToAbsent) {
    return SyncDeletionsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      createdAt: Value(createdAt),
    );
  }

  factory SyncDeletion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDeletion(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  SyncDeletion copyWith(
          {String? entityType, String? entityId, String? createdAt}) =>
      SyncDeletion(
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncDeletion copyWithCompanion(SyncDeletionsCompanion data) {
    return SyncDeletion(
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeletion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityType, entityId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDeletion &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.createdAt == this.createdAt);
}

class SyncDeletionsCompanion extends UpdateCompanion<SyncDeletion> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> createdAt;
  final Value<int> rowid;
  const SyncDeletionsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDeletionsCompanion.insert({
    required String entityType,
    required String entityId,
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        createdAt = Value(createdAt);
  static Insertable<SyncDeletion> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDeletionsCompanion copyWith(
      {Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return SyncDeletionsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeletionsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterviewDraftsTable extends InterviewDrafts
    with TableInfo<$InterviewDraftsTable, InterviewDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterviewDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metadataMeta =
      const VerificationMeta('metadata');
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _audioMeta = const VerificationMeta('audio');
  @override
  late final GeneratedColumn<Uint8List> audio = GeneratedColumn<Uint8List>(
      'audio', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  static const VerificationMeta _readyMeta = const VerificationMeta('ready');
  @override
  late final GeneratedColumn<bool> ready = GeneratedColumn<bool>(
      'ready', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("ready" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, ownerId, metadata, audio, ready];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interview_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<InterviewDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(_metadataMeta,
          metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta));
    } else if (isInserting) {
      context.missing(_metadataMeta);
    }
    if (data.containsKey('audio')) {
      context.handle(
          _audioMeta, audio.isAcceptableOrUnknown(data['audio']!, _audioMeta));
    } else if (isInserting) {
      context.missing(_audioMeta);
    }
    if (data.containsKey('ready')) {
      context.handle(
          _readyMeta, ready.isAcceptableOrUnknown(data['ready']!, _readyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterviewDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterviewDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata'])!,
      audio: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}audio'])!,
      ready: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}ready'])!,
    );
  }

  @override
  $InterviewDraftsTable createAlias(String alias) {
    return $InterviewDraftsTable(attachedDatabase, alias);
  }
}

class InterviewDraft extends DataClass implements Insertable<InterviewDraft> {
  final String id;
  final String ownerId;
  final String metadata;
  final Uint8List audio;
  final bool ready;
  const InterviewDraft(
      {required this.id,
      required this.ownerId,
      required this.metadata,
      required this.audio,
      required this.ready});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['metadata'] = Variable<String>(metadata);
    map['audio'] = Variable<Uint8List>(audio);
    map['ready'] = Variable<bool>(ready);
    return map;
  }

  InterviewDraftsCompanion toCompanion(bool nullToAbsent) {
    return InterviewDraftsCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      metadata: Value(metadata),
      audio: Value(audio),
      ready: Value(ready),
    );
  }

  factory InterviewDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterviewDraft(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      metadata: serializer.fromJson<String>(json['metadata']),
      audio: serializer.fromJson<Uint8List>(json['audio']),
      ready: serializer.fromJson<bool>(json['ready']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'metadata': serializer.toJson<String>(metadata),
      'audio': serializer.toJson<Uint8List>(audio),
      'ready': serializer.toJson<bool>(ready),
    };
  }

  InterviewDraft copyWith(
          {String? id,
          String? ownerId,
          String? metadata,
          Uint8List? audio,
          bool? ready}) =>
      InterviewDraft(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        metadata: metadata ?? this.metadata,
        audio: audio ?? this.audio,
        ready: ready ?? this.ready,
      );
  InterviewDraft copyWithCompanion(InterviewDraftsCompanion data) {
    return InterviewDraft(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      audio: data.audio.present ? data.audio.value : this.audio,
      ready: data.ready.present ? data.ready.value : this.ready,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterviewDraft(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('metadata: $metadata, ')
          ..write('audio: $audio, ')
          ..write('ready: $ready')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, metadata, $driftBlobEquality.hash(audio), ready);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterviewDraft &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.metadata == this.metadata &&
          $driftBlobEquality.equals(other.audio, this.audio) &&
          other.ready == this.ready);
}

class InterviewDraftsCompanion extends UpdateCompanion<InterviewDraft> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> metadata;
  final Value<Uint8List> audio;
  final Value<bool> ready;
  final Value<int> rowid;
  const InterviewDraftsCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.audio = const Value.absent(),
    this.ready = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterviewDraftsCompanion.insert({
    required String id,
    required String ownerId,
    required String metadata,
    required Uint8List audio,
    this.ready = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerId = Value(ownerId),
        metadata = Value(metadata),
        audio = Value(audio);
  static Insertable<InterviewDraft> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? metadata,
    Expression<Uint8List>? audio,
    Expression<bool>? ready,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (metadata != null) 'metadata': metadata,
      if (audio != null) 'audio': audio,
      if (ready != null) 'ready': ready,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterviewDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? ownerId,
      Value<String>? metadata,
      Value<Uint8List>? audio,
      Value<bool>? ready,
      Value<int>? rowid}) {
    return InterviewDraftsCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      metadata: metadata ?? this.metadata,
      audio: audio ?? this.audio,
      ready: ready ?? this.ready,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (audio.present) {
      map['audio'] = Variable<Uint8List>(audio.value);
    }
    if (ready.present) {
      map['ready'] = Variable<bool>(ready.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterviewDraftsCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('metadata: $metadata, ')
          ..write('audio: $audio, ')
          ..write('ready: $ready, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProjectMembersTable extends ProjectMembers
    with TableInfo<$ProjectMembersTable, ProjectMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
      'project_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectRoleMeta =
      const VerificationMeta('projectRole');
  @override
  late final GeneratedColumn<String> projectRole = GeneratedColumn<String>(
      'project_role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [projectId, userId, projectRole];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_members';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('project_role')) {
      context.handle(
          _projectRoleMeta,
          projectRole.isAcceptableOrUnknown(
              data['project_role']!, _projectRoleMeta));
    } else if (isInserting) {
      context.missing(_projectRoleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {projectId, userId};
  @override
  ProjectMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectMember(
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      projectRole: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}project_role'])!,
    );
  }

  @override
  $ProjectMembersTable createAlias(String alias) {
    return $ProjectMembersTable(attachedDatabase, alias);
  }
}

class ProjectMember extends DataClass implements Insertable<ProjectMember> {
  final String projectId;
  final String userId;
  final String projectRole;
  const ProjectMember(
      {required this.projectId,
      required this.userId,
      required this.projectRole});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['project_id'] = Variable<String>(projectId);
    map['user_id'] = Variable<String>(userId);
    map['project_role'] = Variable<String>(projectRole);
    return map;
  }

  ProjectMembersCompanion toCompanion(bool nullToAbsent) {
    return ProjectMembersCompanion(
      projectId: Value(projectId),
      userId: Value(userId),
      projectRole: Value(projectRole),
    );
  }

  factory ProjectMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectMember(
      projectId: serializer.fromJson<String>(json['projectId']),
      userId: serializer.fromJson<String>(json['userId']),
      projectRole: serializer.fromJson<String>(json['projectRole']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'projectId': serializer.toJson<String>(projectId),
      'userId': serializer.toJson<String>(userId),
      'projectRole': serializer.toJson<String>(projectRole),
    };
  }

  ProjectMember copyWith(
          {String? projectId, String? userId, String? projectRole}) =>
      ProjectMember(
        projectId: projectId ?? this.projectId,
        userId: userId ?? this.userId,
        projectRole: projectRole ?? this.projectRole,
      );
  ProjectMember copyWithCompanion(ProjectMembersCompanion data) {
    return ProjectMember(
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      userId: data.userId.present ? data.userId.value : this.userId,
      projectRole:
          data.projectRole.present ? data.projectRole.value : this.projectRole,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectMember(')
          ..write('projectId: $projectId, ')
          ..write('userId: $userId, ')
          ..write('projectRole: $projectRole')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(projectId, userId, projectRole);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectMember &&
          other.projectId == this.projectId &&
          other.userId == this.userId &&
          other.projectRole == this.projectRole);
}

class ProjectMembersCompanion extends UpdateCompanion<ProjectMember> {
  final Value<String> projectId;
  final Value<String> userId;
  final Value<String> projectRole;
  final Value<int> rowid;
  const ProjectMembersCompanion({
    this.projectId = const Value.absent(),
    this.userId = const Value.absent(),
    this.projectRole = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectMembersCompanion.insert({
    required String projectId,
    required String userId,
    required String projectRole,
    this.rowid = const Value.absent(),
  })  : projectId = Value(projectId),
        userId = Value(userId),
        projectRole = Value(projectRole);
  static Insertable<ProjectMember> custom({
    Expression<String>? projectId,
    Expression<String>? userId,
    Expression<String>? projectRole,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (projectId != null) 'project_id': projectId,
      if (userId != null) 'user_id': userId,
      if (projectRole != null) 'project_role': projectRole,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectMembersCompanion copyWith(
      {Value<String>? projectId,
      Value<String>? userId,
      Value<String>? projectRole,
      Value<int>? rowid}) {
    return ProjectMembersCompanion(
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      projectRole: projectRole ?? this.projectRole,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (projectRole.present) {
      map['project_role'] = Variable<String>(projectRole.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectMembersCompanion(')
          ..write('projectId: $projectId, ')
          ..write('userId: $userId, ')
          ..write('projectRole: $projectRole, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $QuestionnairesTable questionnaires = $QuestionnairesTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $ResponsesTable responses = $ResponsesTable(this);
  late final $ParticipantsTable participants = $ParticipantsTable(this);
  late final $SyncDeletionsTable syncDeletions = $SyncDeletionsTable(this);
  late final $InterviewDraftsTable interviewDrafts =
      $InterviewDraftsTable(this);
  late final $ProjectMembersTable projectMembers = $ProjectMembersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        users,
        projects,
        questionnaires,
        questions,
        responses,
        participants,
        syncDeletions,
        interviewDrafts,
        projectMembers
      ];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String email,
  required String name,
  required String role,
  Value<String?> institutionId,
  Value<String?> avatarUrl,
  required String createdAt,
  Value<bool> isCurrentUser,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> name,
  Value<String> role,
  Value<String?> institutionId,
  Value<String?> avatarUrl,
  Value<String> createdAt,
  Value<bool> isCurrentUser,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get institutionId => $composableBuilder(
      column: $table.institutionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCurrentUser => $composableBuilder(
      column: $table.isCurrentUser, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get institutionId => $composableBuilder(
      column: $table.institutionId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCurrentUser => $composableBuilder(
      column: $table.isCurrentUser,
      builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get institutionId => $composableBuilder(
      column: $table.institutionId, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isCurrentUser => $composableBuilder(
      column: $table.isCurrentUser, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String?> institutionId = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<bool> isCurrentUser = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            email: email,
            name: name,
            role: role,
            institutionId: institutionId,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            isCurrentUser: isCurrentUser,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String email,
            required String name,
            required String role,
            Value<String?> institutionId = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            required String createdAt,
            Value<bool> isCurrentUser = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            email: email,
            name: name,
            role: role,
            institutionId: institutionId,
            avatarUrl: avatarUrl,
            createdAt: createdAt,
            isCurrentUser: isCurrentUser,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UsersTable, User>(table),
                    BaseReferences<_$AppDatabase, $UsersTable, User>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  required String id,
  required String title,
  required String description,
  required String objectives,
  Value<String> researchQuestions,
  required String methodology,
  required String population,
  Value<int> sampleSize,
  Value<String> sites,
  required String status,
  required String ownerId,
  Value<String?> supervisorId,
  Value<String?> startDate,
  Value<String?> endDate,
  required String createdAt,
  required String updatedAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<String> objectives,
  Value<String> researchQuestions,
  Value<String> methodology,
  Value<String> population,
  Value<int> sampleSize,
  Value<String> sites,
  Value<String> status,
  Value<String> ownerId,
  Value<String?> supervisorId,
  Value<String?> startDate,
  Value<String?> endDate,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectives => $composableBuilder(
      column: $table.objectives, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get researchQuestions => $composableBuilder(
      column: $table.researchQuestions,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get methodology => $composableBuilder(
      column: $table.methodology, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get population => $composableBuilder(
      column: $table.population, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sampleSize => $composableBuilder(
      column: $table.sampleSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sites => $composableBuilder(
      column: $table.sites, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supervisorId => $composableBuilder(
      column: $table.supervisorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectives => $composableBuilder(
      column: $table.objectives, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get researchQuestions => $composableBuilder(
      column: $table.researchQuestions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get methodology => $composableBuilder(
      column: $table.methodology, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get population => $composableBuilder(
      column: $table.population, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sampleSize => $composableBuilder(
      column: $table.sampleSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sites => $composableBuilder(
      column: $table.sites, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supervisorId => $composableBuilder(
      column: $table.supervisorId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get objectives => $composableBuilder(
      column: $table.objectives, builder: (column) => column);

  GeneratedColumn<String> get researchQuestions => $composableBuilder(
      column: $table.researchQuestions, builder: (column) => column);

  GeneratedColumn<String> get methodology => $composableBuilder(
      column: $table.methodology, builder: (column) => column);

  GeneratedColumn<String> get population => $composableBuilder(
      column: $table.population, builder: (column) => column);

  GeneratedColumn<int> get sampleSize => $composableBuilder(
      column: $table.sampleSize, builder: (column) => column);

  GeneratedColumn<String> get sites =>
      $composableBuilder(column: $table.sites, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get supervisorId => $composableBuilder(
      column: $table.supervisorId, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> objectives = const Value.absent(),
            Value<String> researchQuestions = const Value.absent(),
            Value<String> methodology = const Value.absent(),
            Value<String> population = const Value.absent(),
            Value<int> sampleSize = const Value.absent(),
            Value<String> sites = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String?> supervisorId = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            title: title,
            description: description,
            objectives: objectives,
            researchQuestions: researchQuestions,
            methodology: methodology,
            population: population,
            sampleSize: sampleSize,
            sites: sites,
            status: status,
            ownerId: ownerId,
            supervisorId: supervisorId,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required String objectives,
            Value<String> researchQuestions = const Value.absent(),
            required String methodology,
            required String population,
            Value<int> sampleSize = const Value.absent(),
            Value<String> sites = const Value.absent(),
            required String status,
            required String ownerId,
            Value<String?> supervisorId = const Value.absent(),
            Value<String?> startDate = const Value.absent(),
            Value<String?> endDate = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            title: title,
            description: description,
            objectives: objectives,
            researchQuestions: researchQuestions,
            methodology: methodology,
            population: population,
            sampleSize: sampleSize,
            sites: sites,
            status: status,
            ownerId: ownerId,
            supervisorId: supervisorId,
            startDate: startDate,
            endDate: endDate,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProjectsTable, Project>(table),
                    BaseReferences<_$AppDatabase, $ProjectsTable, Project>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableAnnotationComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder,
    (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
    Project,
    PrefetchHooks Function()>;
typedef $$QuestionnairesTableCreateCompanionBuilder = QuestionnairesCompanion
    Function({
  required String id,
  required String projectId,
  required String title,
  required String description,
  Value<int> version,
  Value<bool> isApproved,
  Value<bool> isPublished,
  required String createdAt,
  required String updatedAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$QuestionnairesTableUpdateCompanionBuilder = QuestionnairesCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> title,
  Value<String> description,
  Value<int> version,
  Value<bool> isApproved,
  Value<bool> isPublished,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$QuestionnairesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionnairesTable> {
  $$QuestionnairesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$QuestionnairesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionnairesTable> {
  $$QuestionnairesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$QuestionnairesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionnairesTable> {
  $$QuestionnairesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isApproved => $composableBuilder(
      column: $table.isApproved, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
      column: $table.isPublished, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$QuestionnairesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionnairesTable,
    QuestionnaireRow,
    $$QuestionnairesTableFilterComposer,
    $$QuestionnairesTableOrderingComposer,
    $$QuestionnairesTableAnnotationComposer,
    $$QuestionnairesTableCreateCompanionBuilder,
    $$QuestionnairesTableUpdateCompanionBuilder,
    (
      QuestionnaireRow,
      BaseReferences<_$AppDatabase, $QuestionnairesTable, QuestionnaireRow>
    ),
    QuestionnaireRow,
    PrefetchHooks Function()> {
  $$QuestionnairesTableTableManager(
      _$AppDatabase db, $QuestionnairesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionnairesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionnairesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionnairesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isApproved = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionnairesCompanion(
            id: id,
            projectId: projectId,
            title: title,
            description: description,
            version: version,
            isApproved: isApproved,
            isPublished: isPublished,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String title,
            required String description,
            Value<int> version = const Value.absent(),
            Value<bool> isApproved = const Value.absent(),
            Value<bool> isPublished = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionnairesCompanion.insert(
            id: id,
            projectId: projectId,
            title: title,
            description: description,
            version: version,
            isApproved: isApproved,
            isPublished: isPublished,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QuestionnairesTable, QuestionnaireRow>(table),
                    BaseReferences<_$AppDatabase, $QuestionnairesTable,
                        QuestionnaireRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestionnairesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionnairesTable,
    QuestionnaireRow,
    $$QuestionnairesTableFilterComposer,
    $$QuestionnairesTableOrderingComposer,
    $$QuestionnairesTableAnnotationComposer,
    $$QuestionnairesTableCreateCompanionBuilder,
    $$QuestionnairesTableUpdateCompanionBuilder,
    (
      QuestionnaireRow,
      BaseReferences<_$AppDatabase, $QuestionnairesTable, QuestionnaireRow>
    ),
    QuestionnaireRow,
    PrefetchHooks Function()>;
typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  required String id,
  required String questionnaireId,
  required int orderIndex,
  required String questionType,
  required String questionText,
  Value<String?> helpText,
  Value<bool> isRequired,
  Value<String> optionsJson,
  Value<double?> minValue,
  Value<double?> maxValue,
  Value<String?> skipLogicJson,
  Value<String?> rowsJson,
  Value<String?> columnsJson,
  Value<int> rowid,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<String> id,
  Value<String> questionnaireId,
  Value<int> orderIndex,
  Value<String> questionType,
  Value<String> questionText,
  Value<String?> helpText,
  Value<bool> isRequired,
  Value<String> optionsJson,
  Value<double?> minValue,
  Value<double?> maxValue,
  Value<String?> skipLogicJson,
  Value<String?> rowsJson,
  Value<String?> columnsJson,
  Value<int> rowid,
});

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionType => $composableBuilder(
      column: $table.questionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get helpText => $composableBuilder(
      column: $table.helpText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minValue => $composableBuilder(
      column: $table.minValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxValue => $composableBuilder(
      column: $table.maxValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skipLogicJson => $composableBuilder(
      column: $table.skipLogicJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowsJson => $composableBuilder(
      column: $table.rowsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get columnsJson => $composableBuilder(
      column: $table.columnsJson, builder: (column) => ColumnFilters(column));
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionType => $composableBuilder(
      column: $table.questionType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionText => $composableBuilder(
      column: $table.questionText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get helpText => $composableBuilder(
      column: $table.helpText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minValue => $composableBuilder(
      column: $table.minValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxValue => $composableBuilder(
      column: $table.maxValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skipLogicJson => $composableBuilder(
      column: $table.skipLogicJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowsJson => $composableBuilder(
      column: $table.rowsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get columnsJson => $composableBuilder(
      column: $table.columnsJson, builder: (column) => ColumnOrderings(column));
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  GeneratedColumn<String> get questionType => $composableBuilder(
      column: $table.questionType, builder: (column) => column);

  GeneratedColumn<String> get questionText => $composableBuilder(
      column: $table.questionText, builder: (column) => column);

  GeneratedColumn<String> get helpText =>
      $composableBuilder(column: $table.helpText, builder: (column) => column);

  GeneratedColumn<bool> get isRequired => $composableBuilder(
      column: $table.isRequired, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
      column: $table.optionsJson, builder: (column) => column);

  GeneratedColumn<double> get minValue =>
      $composableBuilder(column: $table.minValue, builder: (column) => column);

  GeneratedColumn<double> get maxValue =>
      $composableBuilder(column: $table.maxValue, builder: (column) => column);

  GeneratedColumn<String> get skipLogicJson => $composableBuilder(
      column: $table.skipLogicJson, builder: (column) => column);

  GeneratedColumn<String> get rowsJson =>
      $composableBuilder(column: $table.rowsJson, builder: (column) => column);

  GeneratedColumn<String> get columnsJson => $composableBuilder(
      column: $table.columnsJson, builder: (column) => column);
}

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    QuestionRow,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (QuestionRow, BaseReferences<_$AppDatabase, $QuestionsTable, QuestionRow>),
    QuestionRow,
    PrefetchHooks Function()> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> questionnaireId = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
            Value<String> questionType = const Value.absent(),
            Value<String> questionText = const Value.absent(),
            Value<String?> helpText = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<double?> minValue = const Value.absent(),
            Value<double?> maxValue = const Value.absent(),
            Value<String?> skipLogicJson = const Value.absent(),
            Value<String?> rowsJson = const Value.absent(),
            Value<String?> columnsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion(
            id: id,
            questionnaireId: questionnaireId,
            orderIndex: orderIndex,
            questionType: questionType,
            questionText: questionText,
            helpText: helpText,
            isRequired: isRequired,
            optionsJson: optionsJson,
            minValue: minValue,
            maxValue: maxValue,
            skipLogicJson: skipLogicJson,
            rowsJson: rowsJson,
            columnsJson: columnsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String questionnaireId,
            required int orderIndex,
            required String questionType,
            required String questionText,
            Value<String?> helpText = const Value.absent(),
            Value<bool> isRequired = const Value.absent(),
            Value<String> optionsJson = const Value.absent(),
            Value<double?> minValue = const Value.absent(),
            Value<double?> maxValue = const Value.absent(),
            Value<String?> skipLogicJson = const Value.absent(),
            Value<String?> rowsJson = const Value.absent(),
            Value<String?> columnsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            id: id,
            questionnaireId: questionnaireId,
            orderIndex: orderIndex,
            questionType: questionType,
            questionText: questionText,
            helpText: helpText,
            isRequired: isRequired,
            optionsJson: optionsJson,
            minValue: minValue,
            maxValue: maxValue,
            skipLogicJson: skipLogicJson,
            rowsJson: rowsJson,
            columnsJson: columnsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$QuestionsTable, QuestionRow>(table),
                    BaseReferences<_$AppDatabase, $QuestionsTable, QuestionRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionsTable,
    QuestionRow,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (QuestionRow, BaseReferences<_$AppDatabase, $QuestionsTable, QuestionRow>),
    QuestionRow,
    PrefetchHooks Function()>;
typedef $$ResponsesTableCreateCompanionBuilder = ResponsesCompanion Function({
  required String id,
  required String questionnaireId,
  required String participantId,
  required String responsesJson,
  required String collectedAt,
  required String syncStatus,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});
typedef $$ResponsesTableUpdateCompanionBuilder = ResponsesCompanion Function({
  Value<String> id,
  Value<String> questionnaireId,
  Value<String> participantId,
  Value<String> responsesJson,
  Value<String> collectedAt,
  Value<String> syncStatus,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<int> rowid,
});

class $$ResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get participantId => $composableBuilder(
      column: $table.participantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collectedAt => $composableBuilder(
      column: $table.collectedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));
}

class $$ResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get participantId => $composableBuilder(
      column: $table.participantId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collectedAt => $composableBuilder(
      column: $table.collectedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));
}

class $$ResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResponsesTable> {
  $$ResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionnaireId => $composableBuilder(
      column: $table.questionnaireId, builder: (column) => column);

  GeneratedColumn<String> get participantId => $composableBuilder(
      column: $table.participantId, builder: (column) => column);

  GeneratedColumn<String> get responsesJson => $composableBuilder(
      column: $table.responsesJson, builder: (column) => column);

  GeneratedColumn<String> get collectedAt => $composableBuilder(
      column: $table.collectedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);
}

class $$ResponsesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResponsesTable,
    Response,
    $$ResponsesTableFilterComposer,
    $$ResponsesTableOrderingComposer,
    $$ResponsesTableAnnotationComposer,
    $$ResponsesTableCreateCompanionBuilder,
    $$ResponsesTableUpdateCompanionBuilder,
    (Response, BaseReferences<_$AppDatabase, $ResponsesTable, Response>),
    Response,
    PrefetchHooks Function()> {
  $$ResponsesTableTableManager(_$AppDatabase db, $ResponsesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResponsesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResponsesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResponsesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> questionnaireId = const Value.absent(),
            Value<String> participantId = const Value.absent(),
            Value<String> responsesJson = const Value.absent(),
            Value<String> collectedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResponsesCompanion(
            id: id,
            questionnaireId: questionnaireId,
            participantId: participantId,
            responsesJson: responsesJson,
            collectedAt: collectedAt,
            syncStatus: syncStatus,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String questionnaireId,
            required String participantId,
            required String responsesJson,
            required String collectedAt,
            required String syncStatus,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResponsesCompanion.insert(
            id: id,
            questionnaireId: questionnaireId,
            participantId: participantId,
            responsesJson: responsesJson,
            collectedAt: collectedAt,
            syncStatus: syncStatus,
            latitude: latitude,
            longitude: longitude,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ResponsesTable, Response>(table),
                    BaseReferences<_$AppDatabase, $ResponsesTable, Response>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ResponsesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResponsesTable,
    Response,
    $$ResponsesTableFilterComposer,
    $$ResponsesTableOrderingComposer,
    $$ResponsesTableAnnotationComposer,
    $$ResponsesTableCreateCompanionBuilder,
    $$ResponsesTableUpdateCompanionBuilder,
    (Response, BaseReferences<_$AppDatabase, $ResponsesTable, Response>),
    Response,
    PrefetchHooks Function()>;
typedef $$ParticipantsTableCreateCompanionBuilder = ParticipantsCompanion
    Function({
  required String id,
  required String projectId,
  required String code,
  required String name,
  Value<String?> phone,
  Value<String?> email,
  Value<bool> hasConsented,
  Value<String?> consentDate,
  Value<String?> notes,
  required String createdAt,
  required String syncStatus,
  Value<int> rowid,
});
typedef $$ParticipantsTableUpdateCompanionBuilder = ParticipantsCompanion
    Function({
  Value<String> id,
  Value<String> projectId,
  Value<String> code,
  Value<String> name,
  Value<String?> phone,
  Value<String?> email,
  Value<bool> hasConsented,
  Value<String?> consentDate,
  Value<String?> notes,
  Value<String> createdAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$ParticipantsTableFilterComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentDate => $composableBuilder(
      column: $table.consentDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));
}

class $$ParticipantsTableOrderingComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentDate => $composableBuilder(
      column: $table.consentDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));
}

class $$ParticipantsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ParticipantsTable> {
  $$ParticipantsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get hasConsented => $composableBuilder(
      column: $table.hasConsented, builder: (column) => column);

  GeneratedColumn<String> get consentDate => $composableBuilder(
      column: $table.consentDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);
}

class $$ParticipantsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    ParticipantRow,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (
      ParticipantRow,
      BaseReferences<_$AppDatabase, $ParticipantsTable, ParticipantRow>
    ),
    ParticipantRow,
    PrefetchHooks Function()> {
  $$ParticipantsTableTableManager(_$AppDatabase db, $ParticipantsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ParticipantsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ParticipantsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ParticipantsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> projectId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> hasConsented = const Value.absent(),
            Value<String?> consentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion(
            id: id,
            projectId: projectId,
            code: code,
            name: name,
            phone: phone,
            email: email,
            hasConsented: hasConsented,
            consentDate: consentDate,
            notes: notes,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String projectId,
            required String code,
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<bool> hasConsented = const Value.absent(),
            Value<String?> consentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String createdAt,
            required String syncStatus,
            Value<int> rowid = const Value.absent(),
          }) =>
              ParticipantsCompanion.insert(
            id: id,
            projectId: projectId,
            code: code,
            name: name,
            phone: phone,
            email: email,
            hasConsented: hasConsented,
            consentDate: consentDate,
            notes: notes,
            createdAt: createdAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ParticipantsTable, ParticipantRow>(table),
                    BaseReferences<_$AppDatabase, $ParticipantsTable,
                        ParticipantRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ParticipantsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ParticipantsTable,
    ParticipantRow,
    $$ParticipantsTableFilterComposer,
    $$ParticipantsTableOrderingComposer,
    $$ParticipantsTableAnnotationComposer,
    $$ParticipantsTableCreateCompanionBuilder,
    $$ParticipantsTableUpdateCompanionBuilder,
    (
      ParticipantRow,
      BaseReferences<_$AppDatabase, $ParticipantsTable, ParticipantRow>
    ),
    ParticipantRow,
    PrefetchHooks Function()>;
typedef $$SyncDeletionsTableCreateCompanionBuilder = SyncDeletionsCompanion
    Function({
  required String entityType,
  required String entityId,
  required String createdAt,
  Value<int> rowid,
});
typedef $$SyncDeletionsTableUpdateCompanionBuilder = SyncDeletionsCompanion
    Function({
  Value<String> entityType,
  Value<String> entityId,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$SyncDeletionsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDeletionsTable> {
  $$SyncDeletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncDeletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDeletionsTable> {
  $$SyncDeletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncDeletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDeletionsTable> {
  $$SyncDeletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncDeletionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncDeletionsTable,
    SyncDeletion,
    $$SyncDeletionsTableFilterComposer,
    $$SyncDeletionsTableOrderingComposer,
    $$SyncDeletionsTableAnnotationComposer,
    $$SyncDeletionsTableCreateCompanionBuilder,
    $$SyncDeletionsTableUpdateCompanionBuilder,
    (
      SyncDeletion,
      BaseReferences<_$AppDatabase, $SyncDeletionsTable, SyncDeletion>
    ),
    SyncDeletion,
    PrefetchHooks Function()> {
  $$SyncDeletionsTableTableManager(_$AppDatabase db, $SyncDeletionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDeletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDeletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDeletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncDeletionsCompanion(
            entityType: entityType,
            entityId: entityId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entityType,
            required String entityId,
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncDeletionsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncDeletionsTable, SyncDeletion>(table),
                    BaseReferences<_$AppDatabase, $SyncDeletionsTable,
                        SyncDeletion>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncDeletionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncDeletionsTable,
    SyncDeletion,
    $$SyncDeletionsTableFilterComposer,
    $$SyncDeletionsTableOrderingComposer,
    $$SyncDeletionsTableAnnotationComposer,
    $$SyncDeletionsTableCreateCompanionBuilder,
    $$SyncDeletionsTableUpdateCompanionBuilder,
    (
      SyncDeletion,
      BaseReferences<_$AppDatabase, $SyncDeletionsTable, SyncDeletion>
    ),
    SyncDeletion,
    PrefetchHooks Function()>;
typedef $$InterviewDraftsTableCreateCompanionBuilder = InterviewDraftsCompanion
    Function({
  required String id,
  required String ownerId,
  required String metadata,
  required Uint8List audio,
  Value<bool> ready,
  Value<int> rowid,
});
typedef $$InterviewDraftsTableUpdateCompanionBuilder = InterviewDraftsCompanion
    Function({
  Value<String> id,
  Value<String> ownerId,
  Value<String> metadata,
  Value<Uint8List> audio,
  Value<bool> ready,
  Value<int> rowid,
});

class $$InterviewDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $InterviewDraftsTable> {
  $$InterviewDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get audio => $composableBuilder(
      column: $table.audio, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get ready => $composableBuilder(
      column: $table.ready, builder: (column) => ColumnFilters(column));
}

class $$InterviewDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $InterviewDraftsTable> {
  $$InterviewDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get audio => $composableBuilder(
      column: $table.audio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get ready => $composableBuilder(
      column: $table.ready, builder: (column) => ColumnOrderings(column));
}

class $$InterviewDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InterviewDraftsTable> {
  $$InterviewDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<Uint8List> get audio =>
      $composableBuilder(column: $table.audio, builder: (column) => column);

  GeneratedColumn<bool> get ready =>
      $composableBuilder(column: $table.ready, builder: (column) => column);
}

class $$InterviewDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InterviewDraftsTable,
    InterviewDraft,
    $$InterviewDraftsTableFilterComposer,
    $$InterviewDraftsTableOrderingComposer,
    $$InterviewDraftsTableAnnotationComposer,
    $$InterviewDraftsTableCreateCompanionBuilder,
    $$InterviewDraftsTableUpdateCompanionBuilder,
    (
      InterviewDraft,
      BaseReferences<_$AppDatabase, $InterviewDraftsTable, InterviewDraft>
    ),
    InterviewDraft,
    PrefetchHooks Function()> {
  $$InterviewDraftsTableTableManager(
      _$AppDatabase db, $InterviewDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterviewDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InterviewDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InterviewDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> metadata = const Value.absent(),
            Value<Uint8List> audio = const Value.absent(),
            Value<bool> ready = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InterviewDraftsCompanion(
            id: id,
            ownerId: ownerId,
            metadata: metadata,
            audio: audio,
            ready: ready,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String ownerId,
            required String metadata,
            required Uint8List audio,
            Value<bool> ready = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InterviewDraftsCompanion.insert(
            id: id,
            ownerId: ownerId,
            metadata: metadata,
            audio: audio,
            ready: ready,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$InterviewDraftsTable, InterviewDraft>(table),
                    BaseReferences<_$AppDatabase, $InterviewDraftsTable,
                        InterviewDraft>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InterviewDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InterviewDraftsTable,
    InterviewDraft,
    $$InterviewDraftsTableFilterComposer,
    $$InterviewDraftsTableOrderingComposer,
    $$InterviewDraftsTableAnnotationComposer,
    $$InterviewDraftsTableCreateCompanionBuilder,
    $$InterviewDraftsTableUpdateCompanionBuilder,
    (
      InterviewDraft,
      BaseReferences<_$AppDatabase, $InterviewDraftsTable, InterviewDraft>
    ),
    InterviewDraft,
    PrefetchHooks Function()>;
typedef $$ProjectMembersTableCreateCompanionBuilder = ProjectMembersCompanion
    Function({
  required String projectId,
  required String userId,
  required String projectRole,
  Value<int> rowid,
});
typedef $$ProjectMembersTableUpdateCompanionBuilder = ProjectMembersCompanion
    Function({
  Value<String> projectId,
  Value<String> userId,
  Value<String> projectRole,
  Value<int> rowid,
});

class $$ProjectMembersTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectMembersTable> {
  $$ProjectMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projectRole => $composableBuilder(
      column: $table.projectRole, builder: (column) => ColumnFilters(column));
}

class $$ProjectMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectMembersTable> {
  $$ProjectMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get projectId => $composableBuilder(
      column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projectRole => $composableBuilder(
      column: $table.projectRole, builder: (column) => ColumnOrderings(column));
}

class $$ProjectMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectMembersTable> {
  $$ProjectMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get projectRole => $composableBuilder(
      column: $table.projectRole, builder: (column) => column);
}

class $$ProjectMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectMembersTable,
    ProjectMember,
    $$ProjectMembersTableFilterComposer,
    $$ProjectMembersTableOrderingComposer,
    $$ProjectMembersTableAnnotationComposer,
    $$ProjectMembersTableCreateCompanionBuilder,
    $$ProjectMembersTableUpdateCompanionBuilder,
    (
      ProjectMember,
      BaseReferences<_$AppDatabase, $ProjectMembersTable, ProjectMember>
    ),
    ProjectMember,
    PrefetchHooks Function()> {
  $$ProjectMembersTableTableManager(
      _$AppDatabase db, $ProjectMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> projectId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> projectRole = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectMembersCompanion(
            projectId: projectId,
            userId: userId,
            projectRole: projectRole,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String projectId,
            required String userId,
            required String projectRole,
            Value<int> rowid = const Value.absent(),
          }) =>
              ProjectMembersCompanion.insert(
            projectId: projectId,
            userId: userId,
            projectRole: projectRole,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProjectMembersTable, ProjectMember>(table),
                    BaseReferences<_$AppDatabase, $ProjectMembersTable,
                        ProjectMember>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProjectMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProjectMembersTable,
    ProjectMember,
    $$ProjectMembersTableFilterComposer,
    $$ProjectMembersTableOrderingComposer,
    $$ProjectMembersTableAnnotationComposer,
    $$ProjectMembersTableCreateCompanionBuilder,
    $$ProjectMembersTableUpdateCompanionBuilder,
    (
      ProjectMember,
      BaseReferences<_$AppDatabase, $ProjectMembersTable, ProjectMember>
    ),
    ProjectMember,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$QuestionnairesTableTableManager get questionnaires =>
      $$QuestionnairesTableTableManager(_db, _db.questionnaires);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$ResponsesTableTableManager get responses =>
      $$ResponsesTableTableManager(_db, _db.responses);
  $$ParticipantsTableTableManager get participants =>
      $$ParticipantsTableTableManager(_db, _db.participants);
  $$SyncDeletionsTableTableManager get syncDeletions =>
      $$SyncDeletionsTableTableManager(_db, _db.syncDeletions);
  $$InterviewDraftsTableTableManager get interviewDrafts =>
      $$InterviewDraftsTableTableManager(_db, _db.interviewDrafts);
  $$ProjectMembersTableTableManager get projectMembers =>
      $$ProjectMembersTableTableManager(_db, _db.projectMembers);
}
