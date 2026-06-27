// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'technical_table_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TableRowData {

 String get label; String get value; SignalType get signal;
/// Create a copy of TableRowData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TableRowDataCopyWith<TableRowData> get copyWith => _$TableRowDataCopyWithImpl<TableRowData>(this as TableRowData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TableRowData&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.signal, signal) || other.signal == signal));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,signal);

@override
String toString() {
  return 'TableRowData(label: $label, value: $value, signal: $signal)';
}


}

/// @nodoc
abstract mixin class $TableRowDataCopyWith<$Res>  {
  factory $TableRowDataCopyWith(TableRowData value, $Res Function(TableRowData) _then) = _$TableRowDataCopyWithImpl;
@useResult
$Res call({
 String label, String value, SignalType signal
});




}
/// @nodoc
class _$TableRowDataCopyWithImpl<$Res>
    implements $TableRowDataCopyWith<$Res> {
  _$TableRowDataCopyWithImpl(this._self, this._then);

  final TableRowData _self;
  final $Res Function(TableRowData) _then;

/// Create a copy of TableRowData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? value = null,Object? signal = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,signal: null == signal ? _self.signal : signal // ignore: cast_nullable_to_non_nullable
as SignalType,
  ));
}

}


/// Adds pattern-matching-related methods to [TableRowData].
extension TableRowDataPatterns on TableRowData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TableRowData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TableRowData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TableRowData value)  $default,){
final _that = this;
switch (_that) {
case _TableRowData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TableRowData value)?  $default,){
final _that = this;
switch (_that) {
case _TableRowData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  String value,  SignalType signal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TableRowData() when $default != null:
return $default(_that.label,_that.value,_that.signal);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  String value,  SignalType signal)  $default,) {final _that = this;
switch (_that) {
case _TableRowData():
return $default(_that.label,_that.value,_that.signal);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  String value,  SignalType signal)?  $default,) {final _that = this;
switch (_that) {
case _TableRowData() when $default != null:
return $default(_that.label,_that.value,_that.signal);case _:
  return null;

}
}

}

/// @nodoc


class _TableRowData extends TableRowData {
  const _TableRowData({required this.label, this.value = '...', this.signal = SignalType.loading}): super._();
  

@override final  String label;
@override@JsonKey() final  String value;
@override@JsonKey() final  SignalType signal;

/// Create a copy of TableRowData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TableRowDataCopyWith<_TableRowData> get copyWith => __$TableRowDataCopyWithImpl<_TableRowData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TableRowData&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.signal, signal) || other.signal == signal));
}


@override
int get hashCode => Object.hash(runtimeType,label,value,signal);

@override
String toString() {
  return 'TableRowData(label: $label, value: $value, signal: $signal)';
}


}

/// @nodoc
abstract mixin class _$TableRowDataCopyWith<$Res> implements $TableRowDataCopyWith<$Res> {
  factory _$TableRowDataCopyWith(_TableRowData value, $Res Function(_TableRowData) _then) = __$TableRowDataCopyWithImpl;
@override @useResult
$Res call({
 String label, String value, SignalType signal
});




}
/// @nodoc
class __$TableRowDataCopyWithImpl<$Res>
    implements _$TableRowDataCopyWith<$Res> {
  __$TableRowDataCopyWithImpl(this._self, this._then);

  final _TableRowData _self;
  final $Res Function(_TableRowData) _then;

/// Create a copy of TableRowData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? value = null,Object? signal = null,}) {
  return _then(_TableRowData(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,signal: null == signal ? _self.signal : signal // ignore: cast_nullable_to_non_nullable
as SignalType,
  ));
}


}

/// @nodoc
mixin _$TechnicalTableData {

 String get symbol; Map<String, TableRowData> get rows;
/// Create a copy of TechnicalTableData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TechnicalTableDataCopyWith<TechnicalTableData> get copyWith => _$TechnicalTableDataCopyWithImpl<TechnicalTableData>(this as TechnicalTableData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TechnicalTableData&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other.rows, rows));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,const DeepCollectionEquality().hash(rows));

@override
String toString() {
  return 'TechnicalTableData(symbol: $symbol, rows: $rows)';
}


}

/// @nodoc
abstract mixin class $TechnicalTableDataCopyWith<$Res>  {
  factory $TechnicalTableDataCopyWith(TechnicalTableData value, $Res Function(TechnicalTableData) _then) = _$TechnicalTableDataCopyWithImpl;
@useResult
$Res call({
 String symbol, Map<String, TableRowData> rows
});




}
/// @nodoc
class _$TechnicalTableDataCopyWithImpl<$Res>
    implements $TechnicalTableDataCopyWith<$Res> {
  _$TechnicalTableDataCopyWithImpl(this._self, this._then);

  final TechnicalTableData _self;
  final $Res Function(TechnicalTableData) _then;

/// Create a copy of TechnicalTableData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? rows = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as Map<String, TableRowData>,
  ));
}

}


/// Adds pattern-matching-related methods to [TechnicalTableData].
extension TechnicalTableDataPatterns on TechnicalTableData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TechnicalTableData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TechnicalTableData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TechnicalTableData value)  $default,){
final _that = this;
switch (_that) {
case _TechnicalTableData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TechnicalTableData value)?  $default,){
final _that = this;
switch (_that) {
case _TechnicalTableData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  Map<String, TableRowData> rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TechnicalTableData() when $default != null:
return $default(_that.symbol,_that.rows);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  Map<String, TableRowData> rows)  $default,) {final _that = this;
switch (_that) {
case _TechnicalTableData():
return $default(_that.symbol,_that.rows);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  Map<String, TableRowData> rows)?  $default,) {final _that = this;
switch (_that) {
case _TechnicalTableData() when $default != null:
return $default(_that.symbol,_that.rows);case _:
  return null;

}
}

}

/// @nodoc


class _TechnicalTableData extends TechnicalTableData {
  const _TechnicalTableData({required this.symbol, required final  Map<String, TableRowData> rows}): _rows = rows,super._();
  

@override final  String symbol;
 final  Map<String, TableRowData> _rows;
@override Map<String, TableRowData> get rows {
  if (_rows is EqualUnmodifiableMapView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rows);
}


/// Create a copy of TechnicalTableData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TechnicalTableDataCopyWith<_TechnicalTableData> get copyWith => __$TechnicalTableDataCopyWithImpl<_TechnicalTableData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TechnicalTableData&&(identical(other.symbol, symbol) || other.symbol == symbol)&&const DeepCollectionEquality().equals(other._rows, _rows));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,const DeepCollectionEquality().hash(_rows));

@override
String toString() {
  return 'TechnicalTableData(symbol: $symbol, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$TechnicalTableDataCopyWith<$Res> implements $TechnicalTableDataCopyWith<$Res> {
  factory _$TechnicalTableDataCopyWith(_TechnicalTableData value, $Res Function(_TechnicalTableData) _then) = __$TechnicalTableDataCopyWithImpl;
@override @useResult
$Res call({
 String symbol, Map<String, TableRowData> rows
});




}
/// @nodoc
class __$TechnicalTableDataCopyWithImpl<$Res>
    implements _$TechnicalTableDataCopyWith<$Res> {
  __$TechnicalTableDataCopyWithImpl(this._self, this._then);

  final _TechnicalTableData _self;
  final $Res Function(_TechnicalTableData) _then;

/// Create a copy of TechnicalTableData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? rows = null,}) {
  return _then(_TechnicalTableData(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as Map<String, TableRowData>,
  ));
}


}

// dart format on
