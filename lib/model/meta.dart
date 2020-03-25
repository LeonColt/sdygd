import 'package:json_annotation/json_annotation.dart';

part 'meta.g.dart';

@JsonSerializable()
class Meta {
    
    @JsonKey( name: "event_count", required: true, nullable: false, disallowNullValue: true)
    final int eventCount;
    
    Meta({
        this.eventCount,
    });
    
    factory Meta.fromJson(final Map<String, dynamic> json) => _$MetaFromJson(json);
    Map<String, dynamic> toJson() => _$MetaToJson(this);
    
    Meta copyWith( {
        final int eventCount,
    } ) {
        return new Meta(
            eventCount: eventCount ?? this.eventCount,
        );
    }
}