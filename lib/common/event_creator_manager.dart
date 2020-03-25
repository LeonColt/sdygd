
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdygd/common/file_uploader.dart';
import 'package:sdygd/model/event.dart';
import 'package:sdygd/repository/event_repository.dart';

@immutable
class _EventCreationData {
    final DateTime date;
    final String name;
    final String caption;
    final List<File> images;
    
    _EventCreationData( {
        @required this.date,
        @required this.name,
        @required this.caption,
        @required this.images,
    } ) : assert( date != null ), assert( name != null ),
            assert( caption != null ), assert( images != null );
}

@immutable
class EventCreationProgress {
    final EventCreationState state;
    final List<StorageUploadTask> uploadTasks;
    EventCreationProgress( { @required this.state, @required this.uploadTasks } ) : assert( state != null ), assert( uploadTasks != null );
}

enum EventCreationState {
    NONE,
    UPLOADING_FILES,
    CREATING,
    SUCCESS,
    FAILURE,
}

extension EventCreationStateToString on EventCreationState {
    String toReadableString() {
        switch ( this ) {
            case EventCreationState.UPLOADING_FILES: return "Mengunggah File...";
            case EventCreationState.CREATING: return "Menyimpan Acara...";
            case EventCreationState.SUCCESS: return "Acara berhasil disimpan.";
            case EventCreationState.FAILURE: return "Terdapat kesalahan pada saat menyimpan acara.";
            default: return "-";
        }
    }
}

class EventCreatorManager {
    static final instance = EventCreatorManager._internal();
    EventCreatorManager._internal() {
        FileUploader.instance.uploadTasksStream.listen( ( uploadTasks ) => _uploadTasksSubject.add( uploadTasks ) );
        _startEnqueue();
    }

    // ignore: close_sinks
    final _controller = new StreamController<_EventCreationData>();
    
    // ignore: close_sinks
    final BehaviorSubject<EventCreationState> _stateSubject = new BehaviorSubject<EventCreationState>.seeded( EventCreationState.NONE );
    // ignore: close_sinks
    final BehaviorSubject<List<StorageUploadTask>> _uploadTasksSubject = new BehaviorSubject<List<StorageUploadTask>>.seeded( const [] );
    
    bool get isCreating => FileUploader.instance.hasTasks;
    Stream<EventCreationState> get stateStream => _stateSubject.stream;
    Stream<List<StorageUploadTask>> get uploadTasksStream => _uploadTasksSubject.stream;

    _EventCreationData _previousEventCreationData;

    void _startEnqueue() async {
        await for ( final event in _controller.stream ) await _create(event);
    }
    
    Future<void> _create( final _EventCreationData event ) async {
        if ( event == null ) return;
        _stateSubject.add( EventCreationState.UPLOADING_FILES );
        await FileUploader.instance.enqueue( event.images );
        final snapshots = await FileUploader.instance.onComplete;
        _stateSubject.add( EventCreationState.CREATING );

        final imagesLinks = new List<String>();
        for ( final snapshot in snapshots ) imagesLinks.add( await snapshot.ref.getDownloadURL() as String );

        await EventRepository.create(
            new Event(
                id: "",
                date: event.date,
                name: event.name,
                caption: event.caption,
                images: imagesLinks,
                videos: const [],
            ),
        );
        
        _stateSubject.add( EventCreationState.SUCCESS );
    }

    void create( {
        @required final DateTime date,
        @required final String name,
        @required final String caption,
        @required final List<File> images,
    } ) {
        assert( date != null );
        assert( name != null );
        assert( caption != null );
        assert( images != null );
        _previousEventCreationData = new _EventCreationData(
            date: date,
            name: name,
            caption: caption,
            images: images,
        );
        _controller.add( _previousEventCreationData );
    }
    
    void retry() => _controller.add( _previousEventCreationData );
}