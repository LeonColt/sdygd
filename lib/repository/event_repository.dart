import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sdygd/model/event.dart';
import 'package:sdygd/model/meta.dart';

class EventRepository {
    static Stream<List<Event>> getEventsStream( final int limit ) => Firestore.instance.collection("test/data/events").orderBy("date", descending: true).limit( limit ).snapshots().transform(
        new StreamTransformer.fromHandlers(
            handleData: ( QuerySnapshot snapshot, EventSink<List<Event>> output ) {
                try {
                    final events = new List<Event>();
                    for ( final docSnapshot in snapshot.documents ) {
                        if ( docSnapshot.data["date"] is Timestamp ) {
                            docSnapshot.data["date"] = ( docSnapshot.data["date"] as Timestamp ).toDate().toIso8601String();
                        }
                        events.add( Event.fromJson( docSnapshot.data..addAll( { "id": docSnapshot.documentID } ) ) );
                    }
                    output.add( events );
                } catch ( error, st ) {
                    output.addError(error, st);
                }
            }
        ),
    );
    
    static Future<void> create( final Event event ) async {
        final docSnapshotMeta = await Firestore.instance.document("test/data").get();
        final meta = Meta.fromJson( docSnapshotMeta.data );
        final newMeta = meta.copyWith( eventCount: meta.eventCount + 1 );
        final eventRef = Firestore.instance.collection("test/data/events").reference().document();
        await Firestore.instance.runTransaction( ( final transaction ) async {
            await transaction.set( eventRef, event.toJson()..remove("id") );
            await transaction.update( Firestore.instance.document("test/data"), newMeta.toJson() );
        } );
    }
}