import 'package:json_annotation/json_annotation.dart';

part 'static.config.g.dart';

@JsonSerializable()
class StaticConfig {
	@JsonKey(required: true, nullable: false, disallowNullValue: true)
	final String sentryDsn;
	
	StaticConfig( this.sentryDsn );
	
	factory StaticConfig.fromJson( Map<String, dynamic> json ) => _$StaticConfigFromJson(json);
}