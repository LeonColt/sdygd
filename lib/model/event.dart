
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'event.g.dart';

@immutable
@JsonSerializable()
class Event {
    @JsonKey( ignore: true )
    final String id;
    
    @JsonKey( name: "name", required: true, nullable: false, disallowNullValue: true )
    final String name;
    
    @JsonKey( name: "caption", required: true, nullable: false, disallowNullValue: true )
    final String caption;
    
    @JsonKey( name: "images", required: true, nullable: false, disallowNullValue: true )
    final List<String> images;
    
    @JsonKey( name: "videos", required: true, nullable: false, disallowNullValue: true )
    final List<String> videos;
    
    @JsonKey( name: "date", required: true, nullable: false, disallowNullValue: true )
    final DateTime date;
    
    Event({
        @required this.id,
        @required this.name,
        @required this.caption,
        @required this.images,
        @required this.videos,
        @required this.date,
    } );
    
    factory Event.fromJson( final Map<String, dynamic> json ) => _$EventFromJson(json);
    Map<String, dynamic> toJson() => _$EventToJson(this);
}