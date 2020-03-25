import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/common/event_creator_manager.dart';
import 'package:sdygd/view/event_creator.dart';

class EventCreationProgressPage extends StatelessWidget {
    @override
    Widget build(BuildContext context) => new Scaffold(
        body: new NestedScrollView(
            headerSliverBuilder: (_, __) => <Widget>[
                new SliverAppBar(
                    title: new Text(
                        "Menyimpan Acara",
                    ),
                ),
            ],
            body: new Padding(
                padding: const EdgeInsets.symmetric( vertical: 10.0, horizontal: 20.0 ),
                child: new StreamBuilder<EventCreationState>(
                    stream: EventCreatorManager.instance.stateStream,
                    builder: ( _, snapshot ) {
                        if ( snapshot.data == null ) {
                            return new Center(
                                child: new CircularProgressIndicator(),
                            );
                        } else {
                            if ( snapshot.data == EventCreationState.UPLOADING_FILES || snapshot.data == EventCreationState.CREATING ) {
                                return new StreamBuilder<List<StorageUploadTask>>(
                                    stream: EventCreatorManager.instance.uploadTasksStream,
                                    builder: ( _, uploadTasksSnapshot ) {
                                        return new ListView.separated(
                                            itemCount: ( uploadTasksSnapshot.data?.length ?? 0 ) + 1,
                                            separatorBuilder: ( _, __ ) => new SizedBox( height: 20.0, ),
                                            itemBuilder: ( _, final int index ) {
                                                if ( index == 0 ) {
                                                    return new Center(
                                                        child: new Text(
                                                            snapshot.data.toReadableString(),
                                                            style: const TextStyle( fontSize: 24.0, fontWeight: FontWeight.w700, ),
                                                        ),
                                                    );
                                                } else {
                                                    return new _UploadProgress(
                                                        index: index,
                                                        events: uploadTasksSnapshot.data[index - 1].events,
                                                    );
                                                }
                                            },
                                        );
                                    },
                                );
                            } else if ( snapshot.data == EventCreationState.SUCCESS ) {
                                return new Center(
                                    child: new Text( "Acara berhasil disimpan.", style: new TextStyle( color: Theme.of(context).accentColor, fontSize: 25.0, ), ),
                                );
                            } else if ( snapshot.data == EventCreationState.FAILURE ) {
                                return new Center(
                                    child: new Column(
                                        children: <Widget>[
                                            new Text( "Terdapat kesalahan pada saat menyimpan acara!!!", style: new TextStyle( color: Theme.of(context).errorColor ), ),
                                            new SizedBox( height: 20.0, ),
                                            new IconButton(
                                                icon: const Icon( Icons.refresh ),
                                                onPressed: EventCreatorManager.instance.retry,
                                            ),
                                        ],
                                    ),
                                );
                            } else {
                                new Future.delayed( Duration.zero, () => Navigator.of(context).pushReplacement( new MaterialPageRoute(builder: ( _  ) => new EventCreator() ) ) );
                                return new Container();
                            }
                        }
                    },
                ),
            ),
        ),
    );
}

class _UploadProgress extends StatelessWidget {
    final int index;
    final Stream<StorageTaskEvent> events;
    
    const _UploadProgress({Key key, @required this.index, @required this.events}) : assert( index != null ), assert( events != null ), super(key: key);
    
    @override
    Widget build(BuildContext context) => new Card(
        elevation: DEFAULT_ELEVATION,
        child: new Padding(
            padding: const EdgeInsets.all( 10.0 ),
            child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    new Text( "Mengunggah file ke $index" ),
                    new SizedBox( height: 20.0, ),
                    new StreamBuilder<StorageTaskEvent>(
                        stream: events,
                        builder: ( _, snapshot ) {
                            if ( snapshot == null || snapshot.data == null ) {
                                return new Text( "Mempersiapkan..." );
                            } else {
                                if ( snapshot.data.snapshot == null ) {
                                    return new Text( snapshot.data.type.toString() );
                                } else {
                                    return new LinearProgressIndicator(
                                        value: ( snapshot.data.snapshot.bytesTransferred / snapshot.data.snapshot.totalByteCount ),
                                    );
                                }
                            }
                        },
                    )
                ],
            ),
        ),
    );
}
