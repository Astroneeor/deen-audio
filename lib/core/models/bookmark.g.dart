// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBookmarkCollection on Isar {
  IsarCollection<Bookmark> get bookmarks => this.collection();
}

const BookmarkSchema = CollectionSchema(
  name: r'Bookmark',
  id: 6727227738202460809,
  properties: {
    r'ayahNumber': PropertySchema(
      id: 0,
      name: r'ayahNumber',
      type: IsarType.long,
    ),
    r'savedAt': PropertySchema(
      id: 1,
      name: r'savedAt',
      type: IsarType.dateTime,
    ),
    r'surahNumber': PropertySchema(
      id: 2,
      name: r'surahNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _bookmarkEstimateSize,
  serialize: _bookmarkSerialize,
  deserialize: _bookmarkDeserialize,
  deserializeProp: _bookmarkDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _bookmarkGetId,
  getLinks: _bookmarkGetLinks,
  attach: _bookmarkAttach,
  version: '3.1.0+1',
);

int _bookmarkEstimateSize(
  Bookmark object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _bookmarkSerialize(
  Bookmark object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.ayahNumber);
  writer.writeDateTime(offsets[1], object.savedAt);
  writer.writeLong(offsets[2], object.surahNumber);
}

Bookmark _bookmarkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Bookmark();
  object.ayahNumber = reader.readLong(offsets[0]);
  object.id = id;
  object.savedAt = reader.readDateTime(offsets[1]);
  object.surahNumber = reader.readLong(offsets[2]);
  return object;
}

P _bookmarkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bookmarkGetId(Bookmark object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _bookmarkGetLinks(Bookmark object) {
  return [];
}

void _bookmarkAttach(IsarCollection<dynamic> col, Id id, Bookmark object) {
  object.id = id;
}

extension BookmarkQueryWhereSort on QueryBuilder<Bookmark, Bookmark, QWhere> {
  QueryBuilder<Bookmark, Bookmark, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BookmarkQueryWhere on QueryBuilder<Bookmark, Bookmark, QWhereClause> {
  QueryBuilder<Bookmark, Bookmark, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkQueryFilter
    on QueryBuilder<Bookmark, Bookmark, QFilterCondition> {
  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> ayahNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> ayahNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> ayahNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ayahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> ayahNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ayahNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> savedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> savedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> savedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'savedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> savedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'savedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> surahNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition>
      surahNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> surahNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'surahNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterFilterCondition> surahNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'surahNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension BookmarkQueryObject
    on QueryBuilder<Bookmark, Bookmark, QFilterCondition> {}

extension BookmarkQueryLinks
    on QueryBuilder<Bookmark, Bookmark, QFilterCondition> {}

extension BookmarkQuerySortBy on QueryBuilder<Bookmark, Bookmark, QSortBy> {
  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortByAyahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.desc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> sortBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }
}

extension BookmarkQuerySortThenBy
    on QueryBuilder<Bookmark, Bookmark, QSortThenBy> {
  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenByAyahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ayahNumber', Sort.desc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenBySavedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedAt', Sort.desc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.asc);
    });
  }

  QueryBuilder<Bookmark, Bookmark, QAfterSortBy> thenBySurahNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'surahNumber', Sort.desc);
    });
  }
}

extension BookmarkQueryWhereDistinct
    on QueryBuilder<Bookmark, Bookmark, QDistinct> {
  QueryBuilder<Bookmark, Bookmark, QDistinct> distinctByAyahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ayahNumber');
    });
  }

  QueryBuilder<Bookmark, Bookmark, QDistinct> distinctBySavedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedAt');
    });
  }

  QueryBuilder<Bookmark, Bookmark, QDistinct> distinctBySurahNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'surahNumber');
    });
  }
}

extension BookmarkQueryProperty
    on QueryBuilder<Bookmark, Bookmark, QQueryProperty> {
  QueryBuilder<Bookmark, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Bookmark, int, QQueryOperations> ayahNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ayahNumber');
    });
  }

  QueryBuilder<Bookmark, DateTime, QQueryOperations> savedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedAt');
    });
  }

  QueryBuilder<Bookmark, int, QQueryOperations> surahNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'surahNumber');
    });
  }
}
