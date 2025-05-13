// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one2many_data.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOne2ManyRecordCollection on Isar {
  IsarCollection<One2ManyRecord> get one2ManyRecords => this.collection();
}

const One2ManyRecordSchema = CollectionSchema(
  name: r'One2ManyRecord',
  id: 8489240681607200811,
  properties: {
    r'data': PropertySchema(
      id: 0,
      name: r'data',
      type: IsarType.string,
    ),
    r'fieldName': PropertySchema(
      id: 1,
      name: r'fieldName',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 2,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'mainModel': PropertySchema(
      id: 3,
      name: r'mainModel',
      type: IsarType.string,
    ),
    r'mainRecordId': PropertySchema(
      id: 4,
      name: r'mainRecordId',
      type: IsarType.long,
    ),
    r'relationField': PropertySchema(
      id: 5,
      name: r'relationField',
      type: IsarType.string,
    ),
    r'relationModel': PropertySchema(
      id: 6,
      name: r'relationModel',
      type: IsarType.string,
    ),
    r'serverId': PropertySchema(
      id: 7,
      name: r'serverId',
      type: IsarType.long,
    ),
    r'tempRecordId': PropertySchema(
      id: 8,
      name: r'tempRecordId',
      type: IsarType.long,
    )
  },
  estimateSize: _one2ManyRecordEstimateSize,
  serialize: _one2ManyRecordSerialize,
  deserialize: _one2ManyRecordDeserialize,
  deserializeProp: _one2ManyRecordDeserializeProp,
  idName: r'id',
  indexes: {
    r'tempRecordId': IndexSchema(
      id: 5347259526818654280,
      name: r'tempRecordId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tempRecordId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'mainModel': IndexSchema(
      id: 3367184361264370013,
      name: r'mainModel',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mainModel',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'mainRecordId': IndexSchema(
      id: -8839075985955094123,
      name: r'mainRecordId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'mainRecordId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'fieldName': IndexSchema(
      id: -1302880987447441522,
      name: r'fieldName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'fieldName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _one2ManyRecordGetId,
  getLinks: _one2ManyRecordGetLinks,
  attach: _one2ManyRecordAttach,
  version: '3.1.0+1',
);

int _one2ManyRecordEstimateSize(
  One2ManyRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.data.length * 3;
  bytesCount += 3 + object.fieldName.length * 3;
  bytesCount += 3 + object.mainModel.length * 3;
  bytesCount += 3 + object.relationField.length * 3;
  bytesCount += 3 + object.relationModel.length * 3;
  return bytesCount;
}

void _one2ManyRecordSerialize(
  One2ManyRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.data);
  writer.writeString(offsets[1], object.fieldName);
  writer.writeBool(offsets[2], object.isSynced);
  writer.writeString(offsets[3], object.mainModel);
  writer.writeLong(offsets[4], object.mainRecordId);
  writer.writeString(offsets[5], object.relationField);
  writer.writeString(offsets[6], object.relationModel);
  writer.writeLong(offsets[7], object.serverId);
  writer.writeLong(offsets[8], object.tempRecordId);
}

One2ManyRecord _one2ManyRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = One2ManyRecord();
  object.data = reader.readString(offsets[0]);
  object.fieldName = reader.readString(offsets[1]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[2]);
  object.mainModel = reader.readString(offsets[3]);
  object.mainRecordId = reader.readLong(offsets[4]);
  object.relationField = reader.readString(offsets[5]);
  object.relationModel = reader.readString(offsets[6]);
  object.serverId = reader.readLongOrNull(offsets[7]);
  object.tempRecordId = reader.readLong(offsets[8]);
  return object;
}

P _one2ManyRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _one2ManyRecordGetId(One2ManyRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _one2ManyRecordGetLinks(One2ManyRecord object) {
  return [];
}

void _one2ManyRecordAttach(
    IsarCollection<dynamic> col, Id id, One2ManyRecord object) {
  object.id = id;
}

extension One2ManyRecordQueryWhereSort
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QWhere> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhere> anyTempRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'tempRecordId'),
      );
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhere> anyMainRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'mainRecordId'),
      );
    });
  }
}

extension One2ManyRecordQueryWhere
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QWhereClause> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause> idBetween(
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

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      tempRecordIdEqualTo(int tempRecordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tempRecordId',
        value: [tempRecordId],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      tempRecordIdNotEqualTo(int tempRecordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tempRecordId',
              lower: [],
              upper: [tempRecordId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tempRecordId',
              lower: [tempRecordId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tempRecordId',
              lower: [tempRecordId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tempRecordId',
              lower: [],
              upper: [tempRecordId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      tempRecordIdGreaterThan(
    int tempRecordId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tempRecordId',
        lower: [tempRecordId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      tempRecordIdLessThan(
    int tempRecordId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tempRecordId',
        lower: [],
        upper: [tempRecordId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      tempRecordIdBetween(
    int lowerTempRecordId,
    int upperTempRecordId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tempRecordId',
        lower: [lowerTempRecordId],
        includeLower: includeLower,
        upper: [upperTempRecordId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainModelEqualTo(String mainModel) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mainModel',
        value: [mainModel],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainModelNotEqualTo(String mainModel) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainModel',
              lower: [],
              upper: [mainModel],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainModel',
              lower: [mainModel],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainModel',
              lower: [mainModel],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainModel',
              lower: [],
              upper: [mainModel],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainRecordIdEqualTo(int mainRecordId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'mainRecordId',
        value: [mainRecordId],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainRecordIdNotEqualTo(int mainRecordId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainRecordId',
              lower: [],
              upper: [mainRecordId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainRecordId',
              lower: [mainRecordId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainRecordId',
              lower: [mainRecordId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'mainRecordId',
              lower: [],
              upper: [mainRecordId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainRecordIdGreaterThan(
    int mainRecordId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mainRecordId',
        lower: [mainRecordId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainRecordIdLessThan(
    int mainRecordId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mainRecordId',
        lower: [],
        upper: [mainRecordId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      mainRecordIdBetween(
    int lowerMainRecordId,
    int upperMainRecordId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'mainRecordId',
        lower: [lowerMainRecordId],
        includeLower: includeLower,
        upper: [upperMainRecordId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      fieldNameEqualTo(String fieldName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'fieldName',
        value: [fieldName],
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterWhereClause>
      fieldNameNotEqualTo(String fieldName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fieldName',
              lower: [],
              upper: [fieldName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fieldName',
              lower: [fieldName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fieldName',
              lower: [fieldName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'fieldName',
              lower: [],
              upper: [fieldName],
              includeUpper: false,
            ));
      }
    });
  }
}

extension One2ManyRecordQueryFilter
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QFilterCondition> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fieldName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fieldName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fieldName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldName',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      fieldNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fieldName',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mainModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mainModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mainModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mainModel',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mainModel',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainRecordIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mainRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainRecordIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mainRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainRecordIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mainRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      mainRecordIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mainRecordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationField',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationField',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationField',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationField',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationFieldIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationField',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'relationModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'relationModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'relationModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'relationModel',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      relationModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'relationModel',
        value: '',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'serverId',
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      serverIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      tempRecordIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tempRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      tempRecordIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tempRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      tempRecordIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tempRecordId',
        value: value,
      ));
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterFilterCondition>
      tempRecordIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tempRecordId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension One2ManyRecordQueryObject
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QFilterCondition> {}

extension One2ManyRecordQueryLinks
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QFilterCondition> {}

extension One2ManyRecordQuerySortBy
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QSortBy> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByFieldName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldName', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByFieldNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldName', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByMainModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainModel', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByMainModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainModel', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByMainRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainRecordId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByMainRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainRecordId', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByRelationField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationField', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByRelationFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationField', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByRelationModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationModel', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByRelationModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationModel', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> sortByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByTempRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempRecordId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      sortByTempRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempRecordId', Sort.desc);
    });
  }
}

extension One2ManyRecordQuerySortThenBy
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QSortThenBy> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByFieldName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldName', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByFieldNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldName', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByMainModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainModel', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByMainModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainModel', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByMainRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainRecordId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByMainRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mainRecordId', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByRelationField() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationField', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByRelationFieldDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationField', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByRelationModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationModel', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByRelationModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'relationModel', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy> thenByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByServerIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverId', Sort.desc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByTempRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempRecordId', Sort.asc);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QAfterSortBy>
      thenByTempRecordIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tempRecordId', Sort.desc);
    });
  }
}

extension One2ManyRecordQueryWhereDistinct
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> {
  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> distinctByData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> distinctByFieldName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> distinctByMainModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mainModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct>
      distinctByMainRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mainRecordId');
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct>
      distinctByRelationField({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationField',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct>
      distinctByRelationModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'relationModel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct> distinctByServerId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverId');
    });
  }

  QueryBuilder<One2ManyRecord, One2ManyRecord, QDistinct>
      distinctByTempRecordId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tempRecordId');
    });
  }
}

extension One2ManyRecordQueryProperty
    on QueryBuilder<One2ManyRecord, One2ManyRecord, QQueryProperty> {
  QueryBuilder<One2ManyRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<One2ManyRecord, String, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<One2ManyRecord, String, QQueryOperations> fieldNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldName');
    });
  }

  QueryBuilder<One2ManyRecord, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<One2ManyRecord, String, QQueryOperations> mainModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mainModel');
    });
  }

  QueryBuilder<One2ManyRecord, int, QQueryOperations> mainRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mainRecordId');
    });
  }

  QueryBuilder<One2ManyRecord, String, QQueryOperations>
      relationFieldProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationField');
    });
  }

  QueryBuilder<One2ManyRecord, String, QQueryOperations>
      relationModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'relationModel');
    });
  }

  QueryBuilder<One2ManyRecord, int?, QQueryOperations> serverIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverId');
    });
  }

  QueryBuilder<One2ManyRecord, int, QQueryOperations> tempRecordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tempRecordId');
    });
  }
}
