import 'package:json_annotation/json_annotation.dart';
import 'package:sdygd/model/static.config.dart';

part 'shen_te.g.dart';

@JsonLiteral('shen_te.json', asConst: true)
Map<String, dynamic> get _config => _$_configJsonLiteral;

final StaticConfig shenTeConfig = StaticConfig.fromJson( _config );