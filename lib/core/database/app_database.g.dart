// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SurahsTable extends Surahs with TableInfo<$SurahsTable, SurahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _englishNameMeta =
      const VerificationMeta('englishName');
  @override
  late final GeneratedColumn<String> englishName = GeneratedColumn<String>(
      'english_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _englishNameTranslationMeta =
      const VerificationMeta('englishNameTranslation');
  @override
  late final GeneratedColumn<String> englishNameTranslation =
      GeneratedColumn<String>('english_name_translation', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberOfAyahsMeta =
      const VerificationMeta('numberOfAyahs');
  @override
  late final GeneratedColumn<int> numberOfAyahs = GeneratedColumn<int>(
      'number_of_ayahs', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _revelationTypeMeta =
      const VerificationMeta('revelationType');
  @override
  late final GeneratedColumn<String> revelationType = GeneratedColumn<String>(
      'revelation_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surahs';
  @override
  VerificationContext validateIntegrity(Insertable<SurahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('english_name')) {
      context.handle(
          _englishNameMeta,
          englishName.isAcceptableOrUnknown(
              data['english_name']!, _englishNameMeta));
    } else if (isInserting) {
      context.missing(_englishNameMeta);
    }
    if (data.containsKey('english_name_translation')) {
      context.handle(
          _englishNameTranslationMeta,
          englishNameTranslation.isAcceptableOrUnknown(
              data['english_name_translation']!, _englishNameTranslationMeta));
    } else if (isInserting) {
      context.missing(_englishNameTranslationMeta);
    }
    if (data.containsKey('number_of_ayahs')) {
      context.handle(
          _numberOfAyahsMeta,
          numberOfAyahs.isAcceptableOrUnknown(
              data['number_of_ayahs']!, _numberOfAyahsMeta));
    } else if (isInserting) {
      context.missing(_numberOfAyahsMeta);
    }
    if (data.containsKey('revelation_type')) {
      context.handle(
          _revelationTypeMeta,
          revelationType.isAcceptableOrUnknown(
              data['revelation_type']!, _revelationTypeMeta));
    } else if (isInserting) {
      context.missing(_revelationTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {number};
  @override
  SurahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahRow(
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      englishName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}english_name'])!,
      englishNameTranslation: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}english_name_translation'])!,
      numberOfAyahs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_of_ayahs'])!,
      revelationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}revelation_type'])!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }
}

class SurahRow extends DataClass implements Insertable<SurahRow> {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  const SurahRow(
      {required this.number,
      required this.name,
      required this.englishName,
      required this.englishNameTranslation,
      required this.numberOfAyahs,
      required this.revelationType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    map['english_name'] = Variable<String>(englishName);
    map['english_name_translation'] = Variable<String>(englishNameTranslation);
    map['number_of_ayahs'] = Variable<int>(numberOfAyahs);
    map['revelation_type'] = Variable<String>(revelationType);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      number: Value(number),
      name: Value(name),
      englishName: Value(englishName),
      englishNameTranslation: Value(englishNameTranslation),
      numberOfAyahs: Value(numberOfAyahs),
      revelationType: Value(revelationType),
    );
  }

  factory SurahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahRow(
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
      englishName: serializer.fromJson<String>(json['englishName']),
      englishNameTranslation:
          serializer.fromJson<String>(json['englishNameTranslation']),
      numberOfAyahs: serializer.fromJson<int>(json['numberOfAyahs']),
      revelationType: serializer.fromJson<String>(json['revelationType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
      'englishName': serializer.toJson<String>(englishName),
      'englishNameTranslation':
          serializer.toJson<String>(englishNameTranslation),
      'numberOfAyahs': serializer.toJson<int>(numberOfAyahs),
      'revelationType': serializer.toJson<String>(revelationType),
    };
  }

  SurahRow copyWith(
          {int? number,
          String? name,
          String? englishName,
          String? englishNameTranslation,
          int? numberOfAyahs,
          String? revelationType}) =>
      SurahRow(
        number: number ?? this.number,
        name: name ?? this.name,
        englishName: englishName ?? this.englishName,
        englishNameTranslation:
            englishNameTranslation ?? this.englishNameTranslation,
        numberOfAyahs: numberOfAyahs ?? this.numberOfAyahs,
        revelationType: revelationType ?? this.revelationType,
      );
  SurahRow copyWithCompanion(SurahsCompanion data) {
    return SurahRow(
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
      englishName:
          data.englishName.present ? data.englishName.value : this.englishName,
      englishNameTranslation: data.englishNameTranslation.present
          ? data.englishNameTranslation.value
          : this.englishNameTranslation,
      numberOfAyahs: data.numberOfAyahs.present
          ? data.numberOfAyahs.value
          : this.numberOfAyahs,
      revelationType: data.revelationType.present
          ? data.revelationType.value
          : this.revelationType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahRow(')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('numberOfAyahs: $numberOfAyahs, ')
          ..write('revelationType: $revelationType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(number, name, englishName,
      englishNameTranslation, numberOfAyahs, revelationType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahRow &&
          other.number == this.number &&
          other.name == this.name &&
          other.englishName == this.englishName &&
          other.englishNameTranslation == this.englishNameTranslation &&
          other.numberOfAyahs == this.numberOfAyahs &&
          other.revelationType == this.revelationType);
}

class SurahsCompanion extends UpdateCompanion<SurahRow> {
  final Value<int> number;
  final Value<String> name;
  final Value<String> englishName;
  final Value<String> englishNameTranslation;
  final Value<int> numberOfAyahs;
  final Value<String> revelationType;
  const SurahsCompanion({
    this.number = const Value.absent(),
    this.name = const Value.absent(),
    this.englishName = const Value.absent(),
    this.englishNameTranslation = const Value.absent(),
    this.numberOfAyahs = const Value.absent(),
    this.revelationType = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.number = const Value.absent(),
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required int numberOfAyahs,
    required String revelationType,
  })  : name = Value(name),
        englishName = Value(englishName),
        englishNameTranslation = Value(englishNameTranslation),
        numberOfAyahs = Value(numberOfAyahs),
        revelationType = Value(revelationType);
  static Insertable<SurahRow> custom({
    Expression<int>? number,
    Expression<String>? name,
    Expression<String>? englishName,
    Expression<String>? englishNameTranslation,
    Expression<int>? numberOfAyahs,
    Expression<String>? revelationType,
  }) {
    return RawValuesInsertable({
      if (number != null) 'number': number,
      if (name != null) 'name': name,
      if (englishName != null) 'english_name': englishName,
      if (englishNameTranslation != null)
        'english_name_translation': englishNameTranslation,
      if (numberOfAyahs != null) 'number_of_ayahs': numberOfAyahs,
      if (revelationType != null) 'revelation_type': revelationType,
    });
  }

  SurahsCompanion copyWith(
      {Value<int>? number,
      Value<String>? name,
      Value<String>? englishName,
      Value<String>? englishNameTranslation,
      Value<int>? numberOfAyahs,
      Value<String>? revelationType}) {
    return SurahsCompanion(
      number: number ?? this.number,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      englishNameTranslation:
          englishNameTranslation ?? this.englishNameTranslation,
      numberOfAyahs: numberOfAyahs ?? this.numberOfAyahs,
      revelationType: revelationType ?? this.revelationType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (englishName.present) {
      map['english_name'] = Variable<String>(englishName.value);
    }
    if (englishNameTranslation.present) {
      map['english_name_translation'] =
          Variable<String>(englishNameTranslation.value);
    }
    if (numberOfAyahs.present) {
      map['number_of_ayahs'] = Variable<int>(numberOfAyahs.value);
    }
    if (revelationType.present) {
      map['revelation_type'] = Variable<String>(revelationType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('number: $number, ')
          ..write('name: $name, ')
          ..write('englishName: $englishName, ')
          ..write('englishNameTranslation: $englishNameTranslation, ')
          ..write('numberOfAyahs: $numberOfAyahs, ')
          ..write('revelationType: $revelationType')
          ..write(')'))
        .toString();
  }
}

class $AyahsTable extends Ayahs with TableInfo<$AyahsTable, AyahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahNumberMeta =
      const VerificationMeta('surahNumber');
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
      'surah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahNumberMeta =
      const VerificationMeta('ayahNumber');
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
      'ayah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _arabicTextMeta =
      const VerificationMeta('arabicText');
  @override
  late final GeneratedColumn<String> arabicText = GeneratedColumn<String>(
      'arabic_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _translationMeta =
      const VerificationMeta('translation');
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
      'translation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [surahNumber, ayahNumber, arabicText, translation];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayahs';
  @override
  VerificationContext validateIntegrity(Insertable<AyahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_number')) {
      context.handle(
          _surahNumberMeta,
          surahNumber.isAcceptableOrUnknown(
              data['surah_number']!, _surahNumberMeta));
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
          _ayahNumberMeta,
          ayahNumber.isAcceptableOrUnknown(
              data['ayah_number']!, _ayahNumberMeta));
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('arabic_text')) {
      context.handle(
          _arabicTextMeta,
          arabicText.isAcceptableOrUnknown(
              data['arabic_text']!, _arabicTextMeta));
    } else if (isInserting) {
      context.missing(_arabicTextMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
          _translationMeta,
          translation.isAcceptableOrUnknown(
              data['translation']!, _translationMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahNumber, ayahNumber};
  @override
  AyahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahRow(
      surahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_number'])!,
      ayahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_number'])!,
      arabicText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}arabic_text'])!,
      translation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}translation']),
    );
  }

  @override
  $AyahsTable createAlias(String alias) {
    return $AyahsTable(attachedDatabase, alias);
  }
}

class AyahRow extends DataClass implements Insertable<AyahRow> {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String? translation;
  const AyahRow(
      {required this.surahNumber,
      required this.ayahNumber,
      required this.arabicText,
      this.translation});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['arabic_text'] = Variable<String>(arabicText);
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    return map;
  }

  AyahsCompanion toCompanion(bool nullToAbsent) {
    return AyahsCompanion(
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
      arabicText: Value(arabicText),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
    );
  }

  factory AyahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahRow(
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      arabicText: serializer.fromJson<String>(json['arabicText']),
      translation: serializer.fromJson<String?>(json['translation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'arabicText': serializer.toJson<String>(arabicText),
      'translation': serializer.toJson<String?>(translation),
    };
  }

  AyahRow copyWith(
          {int? surahNumber,
          int? ayahNumber,
          String? arabicText,
          Value<String?> translation = const Value.absent()}) =>
      AyahRow(
        surahNumber: surahNumber ?? this.surahNumber,
        ayahNumber: ayahNumber ?? this.ayahNumber,
        arabicText: arabicText ?? this.arabicText,
        translation: translation.present ? translation.value : this.translation,
      );
  AyahRow copyWithCompanion(AyahsCompanion data) {
    return AyahRow(
      surahNumber:
          data.surahNumber.present ? data.surahNumber.value : this.surahNumber,
      ayahNumber:
          data.ayahNumber.present ? data.ayahNumber.value : this.ayahNumber,
      arabicText:
          data.arabicText.present ? data.arabicText.value : this.arabicText,
      translation:
          data.translation.present ? data.translation.value : this.translation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahRow(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('arabicText: $arabicText, ')
          ..write('translation: $translation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(surahNumber, ayahNumber, arabicText, translation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahRow &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.arabicText == this.arabicText &&
          other.translation == this.translation);
}

class AyahsCompanion extends UpdateCompanion<AyahRow> {
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<String> arabicText;
  final Value<String?> translation;
  final Value<int> rowid;
  const AyahsCompanion({
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.arabicText = const Value.absent(),
    this.translation = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyahsCompanion.insert({
    required int surahNumber,
    required int ayahNumber,
    required String arabicText,
    this.translation = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : surahNumber = Value(surahNumber),
        ayahNumber = Value(ayahNumber),
        arabicText = Value(arabicText);
  static Insertable<AyahRow> custom({
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? arabicText,
    Expression<String>? translation,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (arabicText != null) 'arabic_text': arabicText,
      if (translation != null) 'translation': translation,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyahsCompanion copyWith(
      {Value<int>? surahNumber,
      Value<int>? ayahNumber,
      Value<String>? arabicText,
      Value<String?>? translation,
      Value<int>? rowid}) {
    return AyahsCompanion(
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (arabicText.present) {
      map['arabic_text'] = Variable<String>(arabicText.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyahsCompanion(')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('arabicText: $arabicText, ')
          ..write('translation: $translation, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, BookmarkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($BookmarksTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($BookmarksTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _surahNumberMeta =
      const VerificationMeta('surahNumber');
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
      'surah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _ayahNumberMeta =
      const VerificationMeta('ayahNumber');
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
      'ayah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, deletedAt, deviceId, userId, surahNumber, ayahNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<BookmarkRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
          _surahNumberMeta,
          surahNumber.isAcceptableOrUnknown(
              data['surah_number']!, _surahNumberMeta));
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
          _ayahNumberMeta,
          ayahNumber.isAcceptableOrUnknown(
              data['ayah_number']!, _ayahNumberMeta));
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {surahNumber, ayahNumber},
      ];
  @override
  BookmarkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookmarkRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $BookmarksTable.$converterupdatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $BookmarksTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      surahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_number'])!,
      ayahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_number'])!,
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class BookmarkRow extends DataClass implements Insertable<BookmarkRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final int surahNumber;
  final int ayahNumber;
  const BookmarkRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.surahNumber,
      required this.ayahNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] =
          Variable<int>($BookmarksTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] =
          Variable<int>($BookmarksTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['surah_number'] = Variable<int>(surahNumber);
    map['ayah_number'] = Variable<int>(ayahNumber);
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      surahNumber: Value(surahNumber),
      ayahNumber: Value(ayahNumber),
    );
  }

  factory BookmarkRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookmarkRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
    };
  }

  BookmarkRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          int? surahNumber,
          int? ayahNumber}) =>
      BookmarkRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        surahNumber: surahNumber ?? this.surahNumber,
        ayahNumber: ayahNumber ?? this.ayahNumber,
      );
  BookmarkRow copyWithCompanion(BookmarksCompanion data) {
    return BookmarkRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      surahNumber:
          data.surahNumber.present ? data.surahNumber.value : this.surahNumber,
      ayahNumber:
          data.ayahNumber.present ? data.ayahNumber.value : this.ayahNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookmarkRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, updatedAt, deletedAt, deviceId, userId, surahNumber, ayahNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookmarkRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber);
}

class BookmarksCompanion extends UpdateCompanion<BookmarkRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<int> surahNumber;
  final Value<int> ayahNumber;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required int surahNumber,
    required int ayahNumber,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        surahNumber = Value(surahNumber),
        ayahNumber = Value(ayahNumber);
  static Insertable<BookmarkRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<int>? surahNumber,
      Value<int>? ayahNumber,
      Value<int>? rowid}) {
    return BookmarksCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $BookmarksTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $BookmarksTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($SettingsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($SettingsTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, deletedAt, deviceId, userId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<SettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {key},
      ];
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $SettingsTable.$converterupdatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $SettingsTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final String key;
  final String value;
  const SettingRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.key,
      required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] =
          Variable<int>($SettingsTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] =
          Variable<int>($SettingsTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      key: Value(key),
      value: Value(value),
    );
  }

  factory SettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          String? key,
          String? value}) =>
      SettingRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, deviceId, userId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        key = Value(key),
        value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<String>? key,
      Value<String>? value,
      Value<int>? rowid}) {
    return SettingsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $SettingsTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $SettingsTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistsTable extends Playlists
    with TableInfo<$PlaylistsTable, PlaylistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($PlaylistsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($PlaylistsTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>('created_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($PlaylistsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns =>
      [id, updatedAt, deletedAt, deviceId, userId, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlists';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $PlaylistsTable.$converterupdatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $PlaylistsTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: $PlaylistsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!),
    );
  }

  @override
  $PlaylistsTable createAlias(String alias) {
    return $PlaylistsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const UtcDateTimeConverter();
}

class PlaylistRow extends DataClass implements Insertable<PlaylistRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final String name;
  final DateTime createdAt;
  const PlaylistRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.name,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] =
          Variable<int>($PlaylistsTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] =
          Variable<int>($PlaylistsTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['name'] = Variable<String>(name);
    {
      map['created_at'] =
          Variable<int>($PlaylistsTable.$convertercreatedAt.toSql(createdAt));
    }
    return map;
  }

  PlaylistsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory PlaylistRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlaylistRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          String? name,
          DateTime? createdAt}) =>
      PlaylistRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  PlaylistRow copyWithCompanion(PlaylistsCompanion data) {
    return PlaylistRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, deviceId, userId, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class PlaylistsCompanion extends UpdateCompanion<PlaylistRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlaylistsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<PlaylistRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PlaylistsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      name: name ?? this.name,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $PlaylistsTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $PlaylistsTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
          $PlaylistsTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaylistItemsTable extends PlaylistItems
    with TableInfo<$PlaylistItemsTable, PlaylistItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($PlaylistItemsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($PlaylistItemsTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _playlistIdMeta =
      const VerificationMeta('playlistId');
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
      'playlist_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _trackKeyMeta =
      const VerificationMeta('trackKey');
  @override
  late final GeneratedColumn<String> trackKey = GeneratedColumn<String>(
      'track_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        deviceId,
        userId,
        playlistId,
        position,
        trackKey
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_items';
  @override
  VerificationContext validateIntegrity(Insertable<PlaylistItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
          _playlistIdMeta,
          playlistId.isAcceptableOrUnknown(
              data['playlist_id']!, _playlistIdMeta));
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('track_key')) {
      context.handle(_trackKeyMeta,
          trackKey.isAcceptableOrUnknown(data['track_key']!, _trackKeyMeta));
    } else if (isInserting) {
      context.missing(_trackKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistItemRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $PlaylistItemsTable.$converterupdatedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $PlaylistItemsTable.$converterdeletedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      playlistId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}playlist_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      trackKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_key'])!,
    );
  }

  @override
  $PlaylistItemsTable createAlias(String alias) {
    return $PlaylistItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class PlaylistItemRow extends DataClass implements Insertable<PlaylistItemRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final String playlistId;
  final int position;
  final String trackKey;
  const PlaylistItemRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.playlistId,
      required this.position,
      required this.trackKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] = Variable<int>(
          $PlaylistItemsTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
          $PlaylistItemsTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['playlist_id'] = Variable<String>(playlistId);
    map['position'] = Variable<int>(position);
    map['track_key'] = Variable<String>(trackKey);
    return map;
  }

  PlaylistItemsCompanion toCompanion(bool nullToAbsent) {
    return PlaylistItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      playlistId: Value(playlistId),
      position: Value(position),
      trackKey: Value(trackKey),
    );
  }

  factory PlaylistItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistItemRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      playlistId: serializer.fromJson<String>(json['playlistId']),
      position: serializer.fromJson<int>(json['position']),
      trackKey: serializer.fromJson<String>(json['trackKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'playlistId': serializer.toJson<String>(playlistId),
      'position': serializer.toJson<int>(position),
      'trackKey': serializer.toJson<String>(trackKey),
    };
  }

  PlaylistItemRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          String? playlistId,
          int? position,
          String? trackKey}) =>
      PlaylistItemRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        playlistId: playlistId ?? this.playlistId,
        position: position ?? this.position,
        trackKey: trackKey ?? this.trackKey,
      );
  PlaylistItemRow copyWithCompanion(PlaylistItemsCompanion data) {
    return PlaylistItemRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      playlistId:
          data.playlistId.present ? data.playlistId.value : this.playlistId,
      position: data.position.present ? data.position.value : this.position,
      trackKey: data.trackKey.present ? data.trackKey.value : this.trackKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('trackKey: $trackKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, deviceId, userId,
      playlistId, position, trackKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistItemRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.playlistId == this.playlistId &&
          other.position == this.position &&
          other.trackKey == this.trackKey);
}

class PlaylistItemsCompanion extends UpdateCompanion<PlaylistItemRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<String> playlistId;
  final Value<int> position;
  final Value<String> trackKey;
  final Value<int> rowid;
  const PlaylistItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.position = const Value.absent(),
    this.trackKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaylistItemsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required String playlistId,
    required int position,
    required String trackKey,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        playlistId = Value(playlistId),
        position = Value(position),
        trackKey = Value(trackKey);
  static Insertable<PlaylistItemRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? playlistId,
    Expression<int>? position,
    Expression<String>? trackKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (playlistId != null) 'playlist_id': playlistId,
      if (position != null) 'position': position,
      if (trackKey != null) 'track_key': trackKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaylistItemsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<String>? playlistId,
      Value<int>? position,
      Value<String>? trackKey,
      Value<int>? rowid}) {
    return PlaylistItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      playlistId: playlistId ?? this.playlistId,
      position: position ?? this.position,
      trackKey: trackKey ?? this.trackKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $PlaylistItemsTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $PlaylistItemsTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (trackKey.present) {
      map['track_key'] = Variable<String>(trackKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('playlistId: $playlistId, ')
          ..write('position: $position, ')
          ..write('trackKey: $trackKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrackStatesTable extends TrackStates
    with TableInfo<$TrackStatesTable, TrackStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($TrackStatesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($TrackStatesTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackKeyMeta =
      const VerificationMeta('trackKey');
  @override
  late final GeneratedColumn<String> trackKey = GeneratedColumn<String>(
      'track_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastPlayed =
      GeneratedColumn<int>('last_played', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($TrackStatesTable.$converterlastPlayedn);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        deviceId,
        userId,
        trackKey,
        isFavorite,
        lastPlayed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track_states';
  @override
  VerificationContext validateIntegrity(Insertable<TrackStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('track_key')) {
      context.handle(_trackKeyMeta,
          trackKey.isAcceptableOrUnknown(data['track_key']!, _trackKeyMeta));
    } else if (isInserting) {
      context.missing(_trackKeyMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {trackKey},
      ];
  @override
  TrackStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackStateRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $TrackStatesTable.$converterupdatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $TrackStatesTable.$converterdeletedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      trackKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_key'])!,
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      lastPlayed: $TrackStatesTable.$converterlastPlayedn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}last_played'])),
    );
  }

  @override
  $TrackStatesTable createAlias(String alias) {
    return $TrackStatesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, int> $converterlastPlayed =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterlastPlayedn =
      NullAwareTypeConverter.wrap($converterlastPlayed);
}

class TrackStateRow extends DataClass implements Insertable<TrackStateRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final String trackKey;
  final bool isFavorite;
  final DateTime? lastPlayed;
  const TrackStateRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.trackKey,
      required this.isFavorite,
      this.lastPlayed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] =
          Variable<int>($TrackStatesTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
          $TrackStatesTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['track_key'] = Variable<String>(trackKey);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<int>(
          $TrackStatesTable.$converterlastPlayedn.toSql(lastPlayed));
    }
    return map;
  }

  TrackStatesCompanion toCompanion(bool nullToAbsent) {
    return TrackStatesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      trackKey: Value(trackKey),
      isFavorite: Value(isFavorite),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory TrackStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackStateRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      trackKey: serializer.fromJson<String>(json['trackKey']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'trackKey': serializer.toJson<String>(trackKey),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  TrackStateRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          String? trackKey,
          bool? isFavorite,
          Value<DateTime?> lastPlayed = const Value.absent()}) =>
      TrackStateRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        trackKey: trackKey ?? this.trackKey,
        isFavorite: isFavorite ?? this.isFavorite,
        lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
      );
  TrackStateRow copyWithCompanion(TrackStatesCompanion data) {
    return TrackStateRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      trackKey: data.trackKey.present ? data.trackKey.value : this.trackKey,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      lastPlayed:
          data.lastPlayed.present ? data.lastPlayed.value : this.lastPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackStateRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('trackKey: $trackKey, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, deviceId, userId,
      trackKey, isFavorite, lastPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackStateRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.trackKey == this.trackKey &&
          other.isFavorite == this.isFavorite &&
          other.lastPlayed == this.lastPlayed);
}

class TrackStatesCompanion extends UpdateCompanion<TrackStateRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<String> trackKey;
  final Value<bool> isFavorite;
  final Value<DateTime?> lastPlayed;
  final Value<int> rowid;
  const TrackStatesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.trackKey = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrackStatesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required String trackKey,
    this.isFavorite = const Value.absent(),
    this.lastPlayed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        trackKey = Value(trackKey);
  static Insertable<TrackStateRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<String>? trackKey,
    Expression<bool>? isFavorite,
    Expression<int>? lastPlayed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (trackKey != null) 'track_key': trackKey,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (lastPlayed != null) 'last_played': lastPlayed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrackStatesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<String>? trackKey,
      Value<bool>? isFavorite,
      Value<DateTime?>? lastPlayed,
      Value<int>? rowid}) {
    return TrackStatesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      trackKey: trackKey ?? this.trackKey,
      isFavorite: isFavorite ?? this.isFavorite,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $TrackStatesTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $TrackStatesTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (trackKey.present) {
      map['track_key'] = Variable<String>(trackKey.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<int>(
          $TrackStatesTable.$converterlastPlayedn.toSql(lastPlayed.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackStatesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('trackKey: $trackKey, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('lastPlayed: $lastPlayed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>('updated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($ReadingSessionsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>('deleted_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($ReadingSessionsTable.$converterdeletedAtn);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> startedAt =
      GeneratedColumn<int>('started_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($ReadingSessionsTable.$converterstartedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> endedAt =
      GeneratedColumn<int>('ended_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($ReadingSessionsTable.$converterendedAtn);
  static const VerificationMeta _surahNumberMeta =
      const VerificationMeta('surahNumber');
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
      'surah_number', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fromAyahMeta =
      const VerificationMeta('fromAyah');
  @override
  late final GeneratedColumn<int> fromAyah = GeneratedColumn<int>(
      'from_ayah', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _toAyahMeta = const VerificationMeta('toAyah');
  @override
  late final GeneratedColumn<int> toAyah = GeneratedColumn<int>(
      'to_ayah', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        updatedAt,
        deletedAt,
        deviceId,
        userId,
        startedAt,
        endedAt,
        surahNumber,
        fromAyah,
        toAyah
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<ReadingSessionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
          _surahNumberMeta,
          surahNumber.isAcceptableOrUnknown(
              data['surah_number']!, _surahNumberMeta));
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('from_ayah')) {
      context.handle(_fromAyahMeta,
          fromAyah.isAcceptableOrUnknown(data['from_ayah']!, _fromAyahMeta));
    } else if (isInserting) {
      context.missing(_fromAyahMeta);
    }
    if (data.containsKey('to_ayah')) {
      context.handle(_toAyahMeta,
          toAyah.isAcceptableOrUnknown(data['to_ayah']!, _toAyahMeta));
    } else if (isInserting) {
      context.missing(_toAyahMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSessionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: $ReadingSessionsTable.$converterupdatedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!),
      deletedAt: $ReadingSessionsTable.$converterdeletedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}deleted_at'])),
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      startedAt: $ReadingSessionsTable.$converterstartedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}started_at'])!),
      endedAt: $ReadingSessionsTable.$converterendedAtn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ended_at'])),
      surahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_number'])!,
      fromAyah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}from_ayah'])!,
      toAyah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}to_ayah'])!,
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
  static TypeConverter<DateTime, int> $converterstartedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime, int> $converterendedAt =
      const UtcDateTimeConverter();
  static TypeConverter<DateTime?, int?> $converterendedAtn =
      NullAwareTypeConverter.wrap($converterendedAt);
}

class ReadingSessionRow extends DataClass
    implements Insertable<ReadingSessionRow> {
  /// UUID generated on the device.
  final String id;

  /// Set on every write (UTC).
  final DateTime updatedAt;

  /// Null while the row is live; the deletion time once soft-deleted.
  final DateTime? deletedAt;

  /// Installation that last wrote the row.
  final String deviceId;

  /// Null while the app runs as the local user.
  final String? userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int surahNumber;
  final int fromAyah;
  final int toAyah;
  const ReadingSessionRow(
      {required this.id,
      required this.updatedAt,
      this.deletedAt,
      required this.deviceId,
      this.userId,
      required this.startedAt,
      this.endedAt,
      required this.surahNumber,
      required this.fromAyah,
      required this.toAyah});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['updated_at'] = Variable<int>(
          $ReadingSessionsTable.$converterupdatedAt.toSql(updatedAt));
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
          $ReadingSessionsTable.$converterdeletedAtn.toSql(deletedAt));
    }
    map['device_id'] = Variable<String>(deviceId);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    {
      map['started_at'] = Variable<int>(
          $ReadingSessionsTable.$converterstartedAt.toSql(startedAt));
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<int>(
          $ReadingSessionsTable.$converterendedAtn.toSql(endedAt));
    }
    map['surah_number'] = Variable<int>(surahNumber);
    map['from_ayah'] = Variable<int>(fromAyah);
    map['to_ayah'] = Variable<int>(toAyah);
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      surahNumber: Value(surahNumber),
      fromAyah: Value(fromAyah),
      toAyah: Value(toAyah),
    );
  }

  factory ReadingSessionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSessionRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      userId: serializer.fromJson<String?>(json['userId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      fromAyah: serializer.fromJson<int>(json['fromAyah']),
      toAyah: serializer.fromJson<int>(json['toAyah']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'userId': serializer.toJson<String?>(userId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'fromAyah': serializer.toJson<int>(fromAyah),
      'toAyah': serializer.toJson<int>(toAyah),
    };
  }

  ReadingSessionRow copyWith(
          {String? id,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? deviceId,
          Value<String?> userId = const Value.absent(),
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? surahNumber,
          int? fromAyah,
          int? toAyah}) =>
      ReadingSessionRow(
        id: id ?? this.id,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        deviceId: deviceId ?? this.deviceId,
        userId: userId.present ? userId.value : this.userId,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        surahNumber: surahNumber ?? this.surahNumber,
        fromAyah: fromAyah ?? this.fromAyah,
        toAyah: toAyah ?? this.toAyah,
      );
  ReadingSessionRow copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSessionRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      userId: data.userId.present ? data.userId.value : this.userId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      surahNumber:
          data.surahNumber.present ? data.surahNumber.value : this.surahNumber,
      fromAyah: data.fromAyah.present ? data.fromAyah.value : this.fromAyah,
      toAyah: data.toAyah.present ? data.toAyah.value : this.toAyah,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('fromAyah: $fromAyah, ')
          ..write('toAyah: $toAyah')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, deviceId, userId,
      startedAt, endedAt, surahNumber, fromAyah, toAyah);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSessionRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.userId == this.userId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.surahNumber == this.surahNumber &&
          other.fromAyah == this.fromAyah &&
          other.toAyah == this.toAyah);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSessionRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<String?> userId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> surahNumber;
  final Value<int> fromAyah;
  final Value<int> toAyah;
  final Value<int> rowid;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.userId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.fromAyah = const Value.absent(),
    this.toAyah = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.userId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int surahNumber,
    required int fromAyah,
    required int toAyah,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        updatedAt = Value(updatedAt),
        deviceId = Value(deviceId),
        startedAt = Value(startedAt),
        surahNumber = Value(surahNumber),
        fromAyah = Value(fromAyah),
        toAyah = Value(toAyah);
  static Insertable<ReadingSessionRow> custom({
    Expression<String>? id,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<String>? deviceId,
    Expression<String>? userId,
    Expression<int>? startedAt,
    Expression<int>? endedAt,
    Expression<int>? surahNumber,
    Expression<int>? fromAyah,
    Expression<int>? toAyah,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (userId != null) 'user_id': userId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (fromAyah != null) 'from_ayah': fromAyah,
      if (toAyah != null) 'to_ayah': toAyah,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingSessionsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? deviceId,
      Value<String?>? userId,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? surahNumber,
      Value<int>? fromAyah,
      Value<int>? toAyah,
      Value<int>? rowid}) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      surahNumber: surahNumber ?? this.surahNumber,
      fromAyah: fromAyah ?? this.fromAyah,
      toAyah: toAyah ?? this.toAyah,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
          $ReadingSessionsTable.$converterupdatedAt.toSql(updatedAt.value));
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
          $ReadingSessionsTable.$converterdeletedAtn.toSql(deletedAt.value));
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(
          $ReadingSessionsTable.$converterstartedAt.toSql(startedAt.value));
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<int>(
          $ReadingSessionsTable.$converterendedAtn.toSql(endedAt.value));
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (fromAyah.present) {
      map['from_ayah'] = Variable<int>(fromAyah.value);
    }
    if (toAyah.present) {
      map['to_ayah'] = Variable<int>(toAyah.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('userId: $userId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('fromAyah: $fromAyah, ')
          ..write('toAyah: $toAyah, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, TrackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
      'artist', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationMsMeta =
      const VerificationMeta('durationMs');
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
      'duration_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _surahNumberMeta =
      const VerificationMeta('surahNumber');
  @override
  late final GeneratedColumn<String> surahNumber = GeneratedColumn<String>(
      'surah_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackKeyMeta =
      const VerificationMeta('trackKey');
  @override
  late final GeneratedColumn<String> trackKey = GeneratedColumn<String>(
      'track_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        artist,
        type,
        filePath,
        durationMs,
        surahNumber,
        trackKey,
        source
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(Insertable<TrackRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
          _durationMsMeta,
          durationMs.isAcceptableOrUnknown(
              data['duration_ms']!, _durationMsMeta));
    }
    if (data.containsKey('surah_number')) {
      context.handle(
          _surahNumberMeta,
          surahNumber.isAcceptableOrUnknown(
              data['surah_number']!, _surahNumberMeta));
    }
    if (data.containsKey('track_key')) {
      context.handle(_trackKeyMeta,
          trackKey.isAcceptableOrUnknown(data['track_key']!, _trackKeyMeta));
    } else if (isInserting) {
      context.missing(_trackKeyMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      durationMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_ms'])!,
      surahNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}surah_number']),
      trackKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track_key'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }
}

class TrackRow extends DataClass implements Insertable<TrackRow> {
  final int id;
  final String title;
  final String? artist;

  /// `TrackType` enum name: quran | adhkar | nasheed | whiteNoise.
  final String type;

  /// Absolute for scanned files; relative to the FileStore base for downloads.
  final String filePath;
  final int durationMs;
  final String? surahNumber;

  /// `lib:<path relative to library folder>` or `dl:<catalog file id>`.
  final String trackKey;

  /// `scanned` | `downloaded`.
  final String source;
  const TrackRow(
      {required this.id,
      required this.title,
      this.artist,
      required this.type,
      required this.filePath,
      required this.durationMs,
      this.surahNumber,
      required this.trackKey,
      required this.source});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    map['duration_ms'] = Variable<int>(durationMs);
    if (!nullToAbsent || surahNumber != null) {
      map['surah_number'] = Variable<String>(surahNumber);
    }
    map['track_key'] = Variable<String>(trackKey);
    map['source'] = Variable<String>(source);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      title: Value(title),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      type: Value(type),
      filePath: Value(filePath),
      durationMs: Value(durationMs),
      surahNumber: surahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(surahNumber),
      trackKey: Value(trackKey),
      source: Value(source),
    );
  }

  factory TrackRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      surahNumber: serializer.fromJson<String?>(json['surahNumber']),
      trackKey: serializer.fromJson<String>(json['trackKey']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'durationMs': serializer.toJson<int>(durationMs),
      'surahNumber': serializer.toJson<String?>(surahNumber),
      'trackKey': serializer.toJson<String>(trackKey),
      'source': serializer.toJson<String>(source),
    };
  }

  TrackRow copyWith(
          {int? id,
          String? title,
          Value<String?> artist = const Value.absent(),
          String? type,
          String? filePath,
          int? durationMs,
          Value<String?> surahNumber = const Value.absent(),
          String? trackKey,
          String? source}) =>
      TrackRow(
        id: id ?? this.id,
        title: title ?? this.title,
        artist: artist.present ? artist.value : this.artist,
        type: type ?? this.type,
        filePath: filePath ?? this.filePath,
        durationMs: durationMs ?? this.durationMs,
        surahNumber: surahNumber.present ? surahNumber.value : this.surahNumber,
        trackKey: trackKey ?? this.trackKey,
        source: source ?? this.source,
      );
  TrackRow copyWithCompanion(TracksCompanion data) {
    return TrackRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      durationMs:
          data.durationMs.present ? data.durationMs.value : this.durationMs,
      surahNumber:
          data.surahNumber.present ? data.surahNumber.value : this.surahNumber,
      trackKey: data.trackKey.present ? data.trackKey.value : this.trackKey,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('trackKey: $trackKey, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, artist, type, filePath, durationMs,
      surahNumber, trackKey, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.durationMs == this.durationMs &&
          other.surahNumber == this.surahNumber &&
          other.trackKey == this.trackKey &&
          other.source == this.source);
}

class TracksCompanion extends UpdateCompanion<TrackRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String> type;
  final Value<String> filePath;
  final Value<int> durationMs;
  final Value<String?> surahNumber;
  final Value<String> trackKey;
  final Value<String> source;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.trackKey = const Value.absent(),
    this.source = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.artist = const Value.absent(),
    required String type,
    required String filePath,
    this.durationMs = const Value.absent(),
    this.surahNumber = const Value.absent(),
    required String trackKey,
    required String source,
  })  : title = Value(title),
        type = Value(type),
        filePath = Value(filePath),
        trackKey = Value(trackKey),
        source = Value(source);
  static Insertable<TrackRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<int>? durationMs,
    Expression<String>? surahNumber,
    Expression<String>? trackKey,
    Expression<String>? source,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (durationMs != null) 'duration_ms': durationMs,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (trackKey != null) 'track_key': trackKey,
      if (source != null) 'source': source,
    });
  }

  TracksCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? artist,
      Value<String>? type,
      Value<String>? filePath,
      Value<int>? durationMs,
      Value<String?>? surahNumber,
      Value<String>? trackKey,
      Value<String>? source}) {
    return TracksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      surahNumber: surahNumber ?? this.surahNumber,
      trackKey: trackKey ?? this.trackKey,
      source: source ?? this.source,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<String>(surahNumber.value);
    }
    if (trackKey.present) {
      map['track_key'] = Variable<String>(trackKey.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('durationMs: $durationMs, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('trackKey: $trackKey, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }
}

class $DownloadItemsTable extends DownloadItems
    with TableInfo<$DownloadItemsTable, DownloadItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fileIdMeta = const VerificationMeta('fileId');
  @override
  late final GeneratedColumn<String> fileId = GeneratedColumn<String>(
      'file_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
      'pack_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relativePathMeta =
      const VerificationMeta('relativePath');
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
      'relative_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bytesTotalMeta =
      const VerificationMeta('bytesTotal');
  @override
  late final GeneratedColumn<int> bytesTotal = GeneratedColumn<int>(
      'bytes_total', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bytesDoneMeta =
      const VerificationMeta('bytesDone');
  @override
  late final GeneratedColumn<int> bytesDone = GeneratedColumn<int>(
      'bytes_done', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _checksumMeta =
      const VerificationMeta('checksum');
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
      'checksum', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        fileId,
        packId,
        url,
        relativePath,
        bytesTotal,
        bytesDone,
        status,
        error,
        checksum
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_items';
  @override
  VerificationContext validateIntegrity(Insertable<DownloadItemRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('file_id')) {
      context.handle(_fileIdMeta,
          fileId.isAcceptableOrUnknown(data['file_id']!, _fileIdMeta));
    } else if (isInserting) {
      context.missing(_fileIdMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(_packIdMeta,
          packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta));
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
          _relativePathMeta,
          relativePath.isAcceptableOrUnknown(
              data['relative_path']!, _relativePathMeta));
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('bytes_total')) {
      context.handle(
          _bytesTotalMeta,
          bytesTotal.isAcceptableOrUnknown(
              data['bytes_total']!, _bytesTotalMeta));
    }
    if (data.containsKey('bytes_done')) {
      context.handle(_bytesDoneMeta,
          bytesDone.isAcceptableOrUnknown(data['bytes_done']!, _bytesDoneMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('checksum')) {
      context.handle(_checksumMeta,
          checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fileId};
  @override
  DownloadItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadItemRow(
      fileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_id'])!,
      packId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pack_id'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      relativePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relative_path'])!,
      bytesTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_total']),
      bytesDone: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bytes_done'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      checksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}checksum']),
    );
  }

  @override
  $DownloadItemsTable createAlias(String alias) {
    return $DownloadItemsTable(attachedDatabase, alias);
  }
}

class DownloadItemRow extends DataClass implements Insertable<DownloadItemRow> {
  /// Catalog file id.
  final String fileId;
  final String packId;
  final String url;

  /// Relative to the FileStore base directory.
  final String relativePath;
  final int? bytesTotal;
  final int bytesDone;

  /// queued | running | paused | done | failed.
  final String status;
  final String? error;
  final String? checksum;
  const DownloadItemRow(
      {required this.fileId,
      required this.packId,
      required this.url,
      required this.relativePath,
      this.bytesTotal,
      required this.bytesDone,
      required this.status,
      this.error,
      this.checksum});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['file_id'] = Variable<String>(fileId);
    map['pack_id'] = Variable<String>(packId);
    map['url'] = Variable<String>(url);
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || bytesTotal != null) {
      map['bytes_total'] = Variable<int>(bytesTotal);
    }
    map['bytes_done'] = Variable<int>(bytesDone);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    return map;
  }

  DownloadItemsCompanion toCompanion(bool nullToAbsent) {
    return DownloadItemsCompanion(
      fileId: Value(fileId),
      packId: Value(packId),
      url: Value(url),
      relativePath: Value(relativePath),
      bytesTotal: bytesTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(bytesTotal),
      bytesDone: Value(bytesDone),
      status: Value(status),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
    );
  }

  factory DownloadItemRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadItemRow(
      fileId: serializer.fromJson<String>(json['fileId']),
      packId: serializer.fromJson<String>(json['packId']),
      url: serializer.fromJson<String>(json['url']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      bytesTotal: serializer.fromJson<int?>(json['bytesTotal']),
      bytesDone: serializer.fromJson<int>(json['bytesDone']),
      status: serializer.fromJson<String>(json['status']),
      error: serializer.fromJson<String?>(json['error']),
      checksum: serializer.fromJson<String?>(json['checksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fileId': serializer.toJson<String>(fileId),
      'packId': serializer.toJson<String>(packId),
      'url': serializer.toJson<String>(url),
      'relativePath': serializer.toJson<String>(relativePath),
      'bytesTotal': serializer.toJson<int?>(bytesTotal),
      'bytesDone': serializer.toJson<int>(bytesDone),
      'status': serializer.toJson<String>(status),
      'error': serializer.toJson<String?>(error),
      'checksum': serializer.toJson<String?>(checksum),
    };
  }

  DownloadItemRow copyWith(
          {String? fileId,
          String? packId,
          String? url,
          String? relativePath,
          Value<int?> bytesTotal = const Value.absent(),
          int? bytesDone,
          String? status,
          Value<String?> error = const Value.absent(),
          Value<String?> checksum = const Value.absent()}) =>
      DownloadItemRow(
        fileId: fileId ?? this.fileId,
        packId: packId ?? this.packId,
        url: url ?? this.url,
        relativePath: relativePath ?? this.relativePath,
        bytesTotal: bytesTotal.present ? bytesTotal.value : this.bytesTotal,
        bytesDone: bytesDone ?? this.bytesDone,
        status: status ?? this.status,
        error: error.present ? error.value : this.error,
        checksum: checksum.present ? checksum.value : this.checksum,
      );
  DownloadItemRow copyWithCompanion(DownloadItemsCompanion data) {
    return DownloadItemRow(
      fileId: data.fileId.present ? data.fileId.value : this.fileId,
      packId: data.packId.present ? data.packId.value : this.packId,
      url: data.url.present ? data.url.value : this.url,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      bytesTotal:
          data.bytesTotal.present ? data.bytesTotal.value : this.bytesTotal,
      bytesDone: data.bytesDone.present ? data.bytesDone.value : this.bytesDone,
      status: data.status.present ? data.status.value : this.status,
      error: data.error.present ? data.error.value : this.error,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItemRow(')
          ..write('fileId: $fileId, ')
          ..write('packId: $packId, ')
          ..write('url: $url, ')
          ..write('relativePath: $relativePath, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesDone: $bytesDone, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('checksum: $checksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fileId, packId, url, relativePath, bytesTotal,
      bytesDone, status, error, checksum);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadItemRow &&
          other.fileId == this.fileId &&
          other.packId == this.packId &&
          other.url == this.url &&
          other.relativePath == this.relativePath &&
          other.bytesTotal == this.bytesTotal &&
          other.bytesDone == this.bytesDone &&
          other.status == this.status &&
          other.error == this.error &&
          other.checksum == this.checksum);
}

class DownloadItemsCompanion extends UpdateCompanion<DownloadItemRow> {
  final Value<String> fileId;
  final Value<String> packId;
  final Value<String> url;
  final Value<String> relativePath;
  final Value<int?> bytesTotal;
  final Value<int> bytesDone;
  final Value<String> status;
  final Value<String?> error;
  final Value<String?> checksum;
  final Value<int> rowid;
  const DownloadItemsCompanion({
    this.fileId = const Value.absent(),
    this.packId = const Value.absent(),
    this.url = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.bytesTotal = const Value.absent(),
    this.bytesDone = const Value.absent(),
    this.status = const Value.absent(),
    this.error = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DownloadItemsCompanion.insert({
    required String fileId,
    required String packId,
    required String url,
    required String relativePath,
    this.bytesTotal = const Value.absent(),
    this.bytesDone = const Value.absent(),
    required String status,
    this.error = const Value.absent(),
    this.checksum = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : fileId = Value(fileId),
        packId = Value(packId),
        url = Value(url),
        relativePath = Value(relativePath),
        status = Value(status);
  static Insertable<DownloadItemRow> custom({
    Expression<String>? fileId,
    Expression<String>? packId,
    Expression<String>? url,
    Expression<String>? relativePath,
    Expression<int>? bytesTotal,
    Expression<int>? bytesDone,
    Expression<String>? status,
    Expression<String>? error,
    Expression<String>? checksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fileId != null) 'file_id': fileId,
      if (packId != null) 'pack_id': packId,
      if (url != null) 'url': url,
      if (relativePath != null) 'relative_path': relativePath,
      if (bytesTotal != null) 'bytes_total': bytesTotal,
      if (bytesDone != null) 'bytes_done': bytesDone,
      if (status != null) 'status': status,
      if (error != null) 'error': error,
      if (checksum != null) 'checksum': checksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DownloadItemsCompanion copyWith(
      {Value<String>? fileId,
      Value<String>? packId,
      Value<String>? url,
      Value<String>? relativePath,
      Value<int?>? bytesTotal,
      Value<int>? bytesDone,
      Value<String>? status,
      Value<String?>? error,
      Value<String?>? checksum,
      Value<int>? rowid}) {
    return DownloadItemsCompanion(
      fileId: fileId ?? this.fileId,
      packId: packId ?? this.packId,
      url: url ?? this.url,
      relativePath: relativePath ?? this.relativePath,
      bytesTotal: bytesTotal ?? this.bytesTotal,
      bytesDone: bytesDone ?? this.bytesDone,
      status: status ?? this.status,
      error: error ?? this.error,
      checksum: checksum ?? this.checksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fileId.present) {
      map['file_id'] = Variable<String>(fileId.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (bytesTotal.present) {
      map['bytes_total'] = Variable<int>(bytesTotal.value);
    }
    if (bytesDone.present) {
      map['bytes_done'] = Variable<int>(bytesDone.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadItemsCompanion(')
          ..write('fileId: $fileId, ')
          ..write('packId: $packId, ')
          ..write('url: $url, ')
          ..write('relativePath: $relativePath, ')
          ..write('bytesTotal: $bytesTotal, ')
          ..write('bytesDone: $bytesDone, ')
          ..write('status: $status, ')
          ..write('error: $error, ')
          ..write('checksum: $checksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceSettingsTable extends DeviceSettings
    with TableInfo<$DeviceSettingsTable, DeviceSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_settings';
  @override
  VerificationContext validateIntegrity(Insertable<DeviceSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  DeviceSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $DeviceSettingsTable createAlias(String alias) {
    return $DeviceSettingsTable(attachedDatabase, alias);
  }
}

class DeviceSettingRow extends DataClass
    implements Insertable<DeviceSettingRow> {
  final String key;
  final String value;
  const DeviceSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  DeviceSettingsCompanion toCompanion(bool nullToAbsent) {
    return DeviceSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory DeviceSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  DeviceSettingRow copyWith({String? key, String? value}) => DeviceSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  DeviceSettingRow copyWithCompanion(DeviceSettingsCompanion data) {
    return DeviceSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class DeviceSettingsCompanion extends UpdateCompanion<DeviceSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const DeviceSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<DeviceSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return DeviceSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $AyahsTable ayahs = $AyahsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $PlaylistsTable playlists = $PlaylistsTable(this);
  late final $PlaylistItemsTable playlistItems = $PlaylistItemsTable(this);
  late final $TrackStatesTable trackStates = $TrackStatesTable(this);
  late final $ReadingSessionsTable readingSessions =
      $ReadingSessionsTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $DownloadItemsTable downloadItems = $DownloadItemsTable(this);
  late final $DeviceSettingsTable deviceSettings = $DeviceSettingsTable(this);
  late final Index playlistItemsOrder = Index('playlist_items_order',
      'CREATE INDEX playlist_items_order ON playlist_items (playlist_id, position)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        surahs,
        ayahs,
        bookmarks,
        settings,
        playlists,
        playlistItems,
        trackStates,
        readingSessions,
        tracks,
        downloadItems,
        deviceSettings,
        playlistItemsOrder
      ];
}

typedef $$SurahsTableCreateCompanionBuilder = SurahsCompanion Function({
  Value<int> number,
  required String name,
  required String englishName,
  required String englishNameTranslation,
  required int numberOfAyahs,
  required String revelationType,
});
typedef $$SurahsTableUpdateCompanionBuilder = SurahsCompanion Function({
  Value<int> number,
  Value<String> name,
  Value<String> englishName,
  Value<String> englishNameTranslation,
  Value<int> numberOfAyahs,
  Value<String> revelationType,
});

class $$SurahsTableFilterComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get englishName => $composableBuilder(
      column: $table.englishName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get englishNameTranslation => $composableBuilder(
      column: $table.englishNameTranslation,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberOfAyahs => $composableBuilder(
      column: $table.numberOfAyahs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revelationType => $composableBuilder(
      column: $table.revelationType,
      builder: (column) => ColumnFilters(column));
}

class $$SurahsTableOrderingComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get englishName => $composableBuilder(
      column: $table.englishName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get englishNameTranslation => $composableBuilder(
      column: $table.englishNameTranslation,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberOfAyahs => $composableBuilder(
      column: $table.numberOfAyahs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revelationType => $composableBuilder(
      column: $table.revelationType,
      builder: (column) => ColumnOrderings(column));
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get englishName => $composableBuilder(
      column: $table.englishName, builder: (column) => column);

  GeneratedColumn<String> get englishNameTranslation => $composableBuilder(
      column: $table.englishNameTranslation, builder: (column) => column);

  GeneratedColumn<int> get numberOfAyahs => $composableBuilder(
      column: $table.numberOfAyahs, builder: (column) => column);

  GeneratedColumn<String> get revelationType => $composableBuilder(
      column: $table.revelationType, builder: (column) => column);
}

class $$SurahsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, BaseReferences<_$AppDatabase, $SurahsTable, SurahRow>),
    SurahRow,
    PrefetchHooks Function()> {
  $$SurahsTableTableManager(_$AppDatabase db, $SurahsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> number = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> englishName = const Value.absent(),
            Value<String> englishNameTranslation = const Value.absent(),
            Value<int> numberOfAyahs = const Value.absent(),
            Value<String> revelationType = const Value.absent(),
          }) =>
              SurahsCompanion(
            number: number,
            name: name,
            englishName: englishName,
            englishNameTranslation: englishNameTranslation,
            numberOfAyahs: numberOfAyahs,
            revelationType: revelationType,
          ),
          createCompanionCallback: ({
            Value<int> number = const Value.absent(),
            required String name,
            required String englishName,
            required String englishNameTranslation,
            required int numberOfAyahs,
            required String revelationType,
          }) =>
              SurahsCompanion.insert(
            number: number,
            name: name,
            englishName: englishName,
            englishNameTranslation: englishNameTranslation,
            numberOfAyahs: numberOfAyahs,
            revelationType: revelationType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SurahsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, BaseReferences<_$AppDatabase, $SurahsTable, SurahRow>),
    SurahRow,
    PrefetchHooks Function()>;
typedef $$AyahsTableCreateCompanionBuilder = AyahsCompanion Function({
  required int surahNumber,
  required int ayahNumber,
  required String arabicText,
  Value<String?> translation,
  Value<int> rowid,
});
typedef $$AyahsTableUpdateCompanionBuilder = AyahsCompanion Function({
  Value<int> surahNumber,
  Value<int> ayahNumber,
  Value<String> arabicText,
  Value<String?> translation,
  Value<int> rowid,
});

class $$AyahsTableFilterComposer extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get arabicText => $composableBuilder(
      column: $table.arabicText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => ColumnFilters(column));
}

class $$AyahsTableOrderingComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get arabicText => $composableBuilder(
      column: $table.arabicText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => ColumnOrderings(column));
}

class $$AyahsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AyahsTable> {
  $$AyahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => column);

  GeneratedColumn<String> get arabicText => $composableBuilder(
      column: $table.arabicText, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
      column: $table.translation, builder: (column) => column);
}

class $$AyahsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AyahsTable,
    AyahRow,
    $$AyahsTableFilterComposer,
    $$AyahsTableOrderingComposer,
    $$AyahsTableAnnotationComposer,
    $$AyahsTableCreateCompanionBuilder,
    $$AyahsTableUpdateCompanionBuilder,
    (AyahRow, BaseReferences<_$AppDatabase, $AyahsTable, AyahRow>),
    AyahRow,
    PrefetchHooks Function()> {
  $$AyahsTableTableManager(_$AppDatabase db, $AyahsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> surahNumber = const Value.absent(),
            Value<int> ayahNumber = const Value.absent(),
            Value<String> arabicText = const Value.absent(),
            Value<String?> translation = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AyahsCompanion(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            arabicText: arabicText,
            translation: translation,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int surahNumber,
            required int ayahNumber,
            required String arabicText,
            Value<String?> translation = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AyahsCompanion.insert(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            arabicText: arabicText,
            translation: translation,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AyahsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AyahsTable,
    AyahRow,
    $$AyahsTableFilterComposer,
    $$AyahsTableOrderingComposer,
    $$AyahsTableAnnotationComposer,
    $$AyahsTableCreateCompanionBuilder,
    $$AyahsTableUpdateCompanionBuilder,
    (AyahRow, BaseReferences<_$AppDatabase, $AyahsTable, AyahRow>),
    AyahRow,
    PrefetchHooks Function()>;
typedef $$BookmarksTableCreateCompanionBuilder = BookmarksCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required int surahNumber,
  required int ayahNumber,
  Value<int> rowid,
});
typedef $$BookmarksTableUpdateCompanionBuilder = BookmarksCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<int> surahNumber,
  Value<int> ayahNumber,
  Value<int> rowid,
});

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnFilters(column));
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => ColumnOrderings(column));
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
      column: $table.ayahNumber, builder: (column) => column);
}

class $$BookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>),
    BookmarkRow,
    PrefetchHooks Function()> {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<int> surahNumber = const Value.absent(),
            Value<int> ayahNumber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required int surahNumber,
            required int ayahNumber,
            Value<int> rowid = const Value.absent(),
          }) =>
              BookmarksCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BookmarksTable,
    BookmarkRow,
    $$BookmarksTableFilterComposer,
    $$BookmarksTableOrderingComposer,
    $$BookmarksTableAnnotationComposer,
    $$BookmarksTableCreateCompanionBuilder,
    $$BookmarksTableUpdateCompanionBuilder,
    (BookmarkRow, BaseReferences<_$AppDatabase, $BookmarksTable, BookmarkRow>),
    BookmarkRow,
    PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
    SettingRow,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    SettingRow,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
    SettingRow,
    PrefetchHooks Function()>;
typedef $$PlaylistsTableCreateCompanionBuilder = PlaylistsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required String name,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PlaylistsTableUpdateCompanionBuilder = PlaylistsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$PlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistsTable> {
  $$PlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlaylistsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    PlaylistRow,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistRow, BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow>),
    PlaylistRow,
    PrefetchHooks Function()> {
  $$PlaylistsTableTableManager(_$AppDatabase db, $PlaylistsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required String name,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistsTable,
    PlaylistRow,
    $$PlaylistsTableFilterComposer,
    $$PlaylistsTableOrderingComposer,
    $$PlaylistsTableAnnotationComposer,
    $$PlaylistsTableCreateCompanionBuilder,
    $$PlaylistsTableUpdateCompanionBuilder,
    (PlaylistRow, BaseReferences<_$AppDatabase, $PlaylistsTable, PlaylistRow>),
    PlaylistRow,
    PrefetchHooks Function()>;
typedef $$PlaylistItemsTableCreateCompanionBuilder = PlaylistItemsCompanion
    Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required String playlistId,
  required int position,
  required String trackKey,
  Value<int> rowid,
});
typedef $$PlaylistItemsTableUpdateCompanionBuilder = PlaylistItemsCompanion
    Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<String> playlistId,
  Value<int> position,
  Value<String> trackKey,
  Value<int> rowid,
});

class $$PlaylistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnFilters(column));
}

class $$PlaylistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnOrderings(column));
}

class $$PlaylistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaylistItemsTable> {
  $$PlaylistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get playlistId => $composableBuilder(
      column: $table.playlistId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get trackKey =>
      $composableBuilder(column: $table.trackKey, builder: (column) => column);
}

class $$PlaylistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlaylistItemsTable,
    PlaylistItemRow,
    $$PlaylistItemsTableFilterComposer,
    $$PlaylistItemsTableOrderingComposer,
    $$PlaylistItemsTableAnnotationComposer,
    $$PlaylistItemsTableCreateCompanionBuilder,
    $$PlaylistItemsTableUpdateCompanionBuilder,
    (
      PlaylistItemRow,
      BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItemRow>
    ),
    PlaylistItemRow,
    PrefetchHooks Function()> {
  $$PlaylistItemsTableTableManager(_$AppDatabase db, $PlaylistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> playlistId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<String> trackKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistItemsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            playlistId: playlistId,
            position: position,
            trackKey: trackKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required String playlistId,
            required int position,
            required String trackKey,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlaylistItemsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            playlistId: playlistId,
            position: position,
            trackKey: trackKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlaylistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlaylistItemsTable,
    PlaylistItemRow,
    $$PlaylistItemsTableFilterComposer,
    $$PlaylistItemsTableOrderingComposer,
    $$PlaylistItemsTableAnnotationComposer,
    $$PlaylistItemsTableCreateCompanionBuilder,
    $$PlaylistItemsTableUpdateCompanionBuilder,
    (
      PlaylistItemRow,
      BaseReferences<_$AppDatabase, $PlaylistItemsTable, PlaylistItemRow>
    ),
    PlaylistItemRow,
    PrefetchHooks Function()>;
typedef $$TrackStatesTableCreateCompanionBuilder = TrackStatesCompanion
    Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required String trackKey,
  Value<bool> isFavorite,
  Value<DateTime?> lastPlayed,
  Value<int> rowid,
});
typedef $$TrackStatesTableUpdateCompanionBuilder = TrackStatesCompanion
    Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<String> trackKey,
  Value<bool> isFavorite,
  Value<DateTime?> lastPlayed,
  Value<int> rowid,
});

class $$TrackStatesTableFilterComposer
    extends Composer<_$AppDatabase, $TrackStatesTable> {
  $$TrackStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastPlayed =>
      $composableBuilder(
          column: $table.lastPlayed,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$TrackStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackStatesTable> {
  $$TrackStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPlayed => $composableBuilder(
      column: $table.lastPlayed, builder: (column) => ColumnOrderings(column));
}

class $$TrackStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackStatesTable> {
  $$TrackStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get trackKey =>
      $composableBuilder(column: $table.trackKey, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastPlayed =>
      $composableBuilder(
          column: $table.lastPlayed, builder: (column) => column);
}

class $$TrackStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrackStatesTable,
    TrackStateRow,
    $$TrackStatesTableFilterComposer,
    $$TrackStatesTableOrderingComposer,
    $$TrackStatesTableAnnotationComposer,
    $$TrackStatesTableCreateCompanionBuilder,
    $$TrackStatesTableUpdateCompanionBuilder,
    (
      TrackStateRow,
      BaseReferences<_$AppDatabase, $TrackStatesTable, TrackStateRow>
    ),
    TrackStateRow,
    PrefetchHooks Function()> {
  $$TrackStatesTableTableManager(_$AppDatabase db, $TrackStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<String> trackKey = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastPlayed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackStatesCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            trackKey: trackKey,
            isFavorite: isFavorite,
            lastPlayed: lastPlayed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required String trackKey,
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime?> lastPlayed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrackStatesCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            trackKey: trackKey,
            isFavorite: isFavorite,
            lastPlayed: lastPlayed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TrackStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrackStatesTable,
    TrackStateRow,
    $$TrackStatesTableFilterComposer,
    $$TrackStatesTableOrderingComposer,
    $$TrackStatesTableAnnotationComposer,
    $$TrackStatesTableCreateCompanionBuilder,
    $$TrackStatesTableUpdateCompanionBuilder,
    (
      TrackStateRow,
      BaseReferences<_$AppDatabase, $TrackStatesTable, TrackStateRow>
    ),
    TrackStateRow,
    PrefetchHooks Function()>;
typedef $$ReadingSessionsTableCreateCompanionBuilder = ReadingSessionsCompanion
    Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<String?> userId,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  required int surahNumber,
  required int fromAyah,
  required int toAyah,
  Value<int> rowid,
});
typedef $$ReadingSessionsTableUpdateCompanionBuilder = ReadingSessionsCompanion
    Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<String?> userId,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> surahNumber,
  Value<int> fromAyah,
  Value<int> toAyah,
  Value<int> rowid,
});

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
          column: $table.updatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
          column: $table.deletedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get startedAt =>
      $composableBuilder(
          column: $table.startedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get endedAt =>
      $composableBuilder(
          column: $table.endedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fromAyah => $composableBuilder(
      column: $table.fromAyah, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toAyah => $composableBuilder(
      column: $table.toAyah, builder: (column) => ColumnFilters(column));
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fromAyah => $composableBuilder(
      column: $table.fromAyah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toAyah => $composableBuilder(
      column: $table.toAyah, builder: (column) => ColumnOrderings(column));
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => column);

  GeneratedColumn<int> get fromAyah =>
      $composableBuilder(column: $table.fromAyah, builder: (column) => column);

  GeneratedColumn<int> get toAyah =>
      $composableBuilder(column: $table.toAyah, builder: (column) => column);
}

class $$ReadingSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSessionRow,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (
      ReadingSessionRow,
      BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSessionRow>
    ),
    ReadingSessionRow,
    PrefetchHooks Function()> {
  $$ReadingSessionsTableTableManager(
      _$AppDatabase db, $ReadingSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> surahNumber = const Value.absent(),
            Value<int> fromAyah = const Value.absent(),
            Value<int> toAyah = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingSessionsCompanion(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            startedAt: startedAt,
            endedAt: endedAt,
            surahNumber: surahNumber,
            fromAyah: fromAyah,
            toAyah: toAyah,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            required String deviceId,
            Value<String?> userId = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            required int surahNumber,
            required int fromAyah,
            required int toAyah,
            Value<int> rowid = const Value.absent(),
          }) =>
              ReadingSessionsCompanion.insert(
            id: id,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            deviceId: deviceId,
            userId: userId,
            startedAt: startedAt,
            endedAt: endedAt,
            surahNumber: surahNumber,
            fromAyah: fromAyah,
            toAyah: toAyah,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ReadingSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ReadingSessionsTable,
    ReadingSessionRow,
    $$ReadingSessionsTableFilterComposer,
    $$ReadingSessionsTableOrderingComposer,
    $$ReadingSessionsTableAnnotationComposer,
    $$ReadingSessionsTableCreateCompanionBuilder,
    $$ReadingSessionsTableUpdateCompanionBuilder,
    (
      ReadingSessionRow,
      BaseReferences<_$AppDatabase, $ReadingSessionsTable, ReadingSessionRow>
    ),
    ReadingSessionRow,
    PrefetchHooks Function()>;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> artist,
  required String type,
  required String filePath,
  Value<int> durationMs,
  Value<String?> surahNumber,
  required String trackKey,
  required String source,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> artist,
  Value<String> type,
  Value<String> filePath,
  Value<int> durationMs,
  Value<String?> surahNumber,
  Value<String> trackKey,
  Value<String> source,
});

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get artist => $composableBuilder(
      column: $table.artist, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackKey => $composableBuilder(
      column: $table.trackKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
      column: $table.durationMs, builder: (column) => column);

  GeneratedColumn<String> get surahNumber => $composableBuilder(
      column: $table.surahNumber, builder: (column) => column);

  GeneratedColumn<String> get trackKey =>
      $composableBuilder(column: $table.trackKey, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$TracksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TracksTable,
    TrackRow,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (TrackRow, BaseReferences<_$AppDatabase, $TracksTable, TrackRow>),
    TrackRow,
    PrefetchHooks Function()> {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> artist = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> durationMs = const Value.absent(),
            Value<String?> surahNumber = const Value.absent(),
            Value<String> trackKey = const Value.absent(),
            Value<String> source = const Value.absent(),
          }) =>
              TracksCompanion(
            id: id,
            title: title,
            artist: artist,
            type: type,
            filePath: filePath,
            durationMs: durationMs,
            surahNumber: surahNumber,
            trackKey: trackKey,
            source: source,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> artist = const Value.absent(),
            required String type,
            required String filePath,
            Value<int> durationMs = const Value.absent(),
            Value<String?> surahNumber = const Value.absent(),
            required String trackKey,
            required String source,
          }) =>
              TracksCompanion.insert(
            id: id,
            title: title,
            artist: artist,
            type: type,
            filePath: filePath,
            durationMs: durationMs,
            surahNumber: surahNumber,
            trackKey: trackKey,
            source: source,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TracksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TracksTable,
    TrackRow,
    $$TracksTableFilterComposer,
    $$TracksTableOrderingComposer,
    $$TracksTableAnnotationComposer,
    $$TracksTableCreateCompanionBuilder,
    $$TracksTableUpdateCompanionBuilder,
    (TrackRow, BaseReferences<_$AppDatabase, $TracksTable, TrackRow>),
    TrackRow,
    PrefetchHooks Function()>;
typedef $$DownloadItemsTableCreateCompanionBuilder = DownloadItemsCompanion
    Function({
  required String fileId,
  required String packId,
  required String url,
  required String relativePath,
  Value<int?> bytesTotal,
  Value<int> bytesDone,
  required String status,
  Value<String?> error,
  Value<String?> checksum,
  Value<int> rowid,
});
typedef $$DownloadItemsTableUpdateCompanionBuilder = DownloadItemsCompanion
    Function({
  Value<String> fileId,
  Value<String> packId,
  Value<String> url,
  Value<String> relativePath,
  Value<int?> bytesTotal,
  Value<int> bytesDone,
  Value<String> status,
  Value<String?> error,
  Value<String?> checksum,
  Value<int> rowid,
});

class $$DownloadItemsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get fileId => $composableBuilder(
      column: $table.fileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packId => $composableBuilder(
      column: $table.packId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytesTotal => $composableBuilder(
      column: $table.bytesTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bytesDone => $composableBuilder(
      column: $table.bytesDone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnFilters(column));
}

class $$DownloadItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get fileId => $composableBuilder(
      column: $table.fileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packId => $composableBuilder(
      column: $table.packId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relativePath => $composableBuilder(
      column: $table.relativePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesTotal => $composableBuilder(
      column: $table.bytesTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bytesDone => $composableBuilder(
      column: $table.bytesDone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksum => $composableBuilder(
      column: $table.checksum, builder: (column) => ColumnOrderings(column));
}

class $$DownloadItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadItemsTable> {
  $$DownloadItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get fileId =>
      $composableBuilder(column: $table.fileId, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
      column: $table.relativePath, builder: (column) => column);

  GeneratedColumn<int> get bytesTotal => $composableBuilder(
      column: $table.bytesTotal, builder: (column) => column);

  GeneratedColumn<int> get bytesDone =>
      $composableBuilder(column: $table.bytesDone, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);
}

class $$DownloadItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DownloadItemsTable,
    DownloadItemRow,
    $$DownloadItemsTableFilterComposer,
    $$DownloadItemsTableOrderingComposer,
    $$DownloadItemsTableAnnotationComposer,
    $$DownloadItemsTableCreateCompanionBuilder,
    $$DownloadItemsTableUpdateCompanionBuilder,
    (
      DownloadItemRow,
      BaseReferences<_$AppDatabase, $DownloadItemsTable, DownloadItemRow>
    ),
    DownloadItemRow,
    PrefetchHooks Function()> {
  $$DownloadItemsTableTableManager(_$AppDatabase db, $DownloadItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> fileId = const Value.absent(),
            Value<String> packId = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> relativePath = const Value.absent(),
            Value<int?> bytesTotal = const Value.absent(),
            Value<int> bytesDone = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadItemsCompanion(
            fileId: fileId,
            packId: packId,
            url: url,
            relativePath: relativePath,
            bytesTotal: bytesTotal,
            bytesDone: bytesDone,
            status: status,
            error: error,
            checksum: checksum,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String fileId,
            required String packId,
            required String url,
            required String relativePath,
            Value<int?> bytesTotal = const Value.absent(),
            Value<int> bytesDone = const Value.absent(),
            required String status,
            Value<String?> error = const Value.absent(),
            Value<String?> checksum = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DownloadItemsCompanion.insert(
            fileId: fileId,
            packId: packId,
            url: url,
            relativePath: relativePath,
            bytesTotal: bytesTotal,
            bytesDone: bytesDone,
            status: status,
            error: error,
            checksum: checksum,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DownloadItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DownloadItemsTable,
    DownloadItemRow,
    $$DownloadItemsTableFilterComposer,
    $$DownloadItemsTableOrderingComposer,
    $$DownloadItemsTableAnnotationComposer,
    $$DownloadItemsTableCreateCompanionBuilder,
    $$DownloadItemsTableUpdateCompanionBuilder,
    (
      DownloadItemRow,
      BaseReferences<_$AppDatabase, $DownloadItemsTable, DownloadItemRow>
    ),
    DownloadItemRow,
    PrefetchHooks Function()>;
typedef $$DeviceSettingsTableCreateCompanionBuilder = DeviceSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$DeviceSettingsTableUpdateCompanionBuilder = DeviceSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$DeviceSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$DeviceSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$DeviceSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceSettingsTable> {
  $$DeviceSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$DeviceSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DeviceSettingsTable,
    DeviceSettingRow,
    $$DeviceSettingsTableFilterComposer,
    $$DeviceSettingsTableOrderingComposer,
    $$DeviceSettingsTableAnnotationComposer,
    $$DeviceSettingsTableCreateCompanionBuilder,
    $$DeviceSettingsTableUpdateCompanionBuilder,
    (
      DeviceSettingRow,
      BaseReferences<_$AppDatabase, $DeviceSettingsTable, DeviceSettingRow>
    ),
    DeviceSettingRow,
    PrefetchHooks Function()> {
  $$DeviceSettingsTableTableManager(
      _$AppDatabase db, $DeviceSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              DeviceSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DeviceSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DeviceSettingsTable,
    DeviceSettingRow,
    $$DeviceSettingsTableFilterComposer,
    $$DeviceSettingsTableOrderingComposer,
    $$DeviceSettingsTableAnnotationComposer,
    $$DeviceSettingsTableCreateCompanionBuilder,
    $$DeviceSettingsTableUpdateCompanionBuilder,
    (
      DeviceSettingRow,
      BaseReferences<_$AppDatabase, $DeviceSettingsTable, DeviceSettingRow>
    ),
    DeviceSettingRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$AyahsTableTableManager get ayahs =>
      $$AyahsTableTableManager(_db, _db.ayahs);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$PlaylistsTableTableManager get playlists =>
      $$PlaylistsTableTableManager(_db, _db.playlists);
  $$PlaylistItemsTableTableManager get playlistItems =>
      $$PlaylistItemsTableTableManager(_db, _db.playlistItems);
  $$TrackStatesTableTableManager get trackStates =>
      $$TrackStatesTableTableManager(_db, _db.trackStates);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$DownloadItemsTableTableManager get downloadItems =>
      $$DownloadItemsTableTableManager(_db, _db.downloadItems);
  $$DeviceSettingsTableTableManager get deviceSettings =>
      $$DeviceSettingsTableTableManager(_db, _db.deviceSettings);
}
