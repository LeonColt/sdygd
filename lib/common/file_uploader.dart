
import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class FileUploader {
    static final instance = FileUploader._internal();
    
    // ignore: close_sinks
    final _controller = new StreamController<List<File>>();

    // ignore: close_sinks
    final BehaviorSubject<List<StorageUploadTask>> _uploadTasksSubject = new BehaviorSubject<List<StorageUploadTask>>.seeded( const [] );

    FileUploader._internal() { _startEnqueue(); }
    
    void _startEnqueue() async {
        await for ( final files in _controller.stream ) {
            if ( files != null && files.isNotEmpty ) await _upload(files);
        }
    }
    
    Completer<List<StorageTaskSnapshot>> _completer;

    List<StorageUploadTask> _currentTasks;
    
    Future<List<StorageTaskSnapshot>> _lock;
    
    Future<List<StorageTaskSnapshot>> get onComplete => _lock;
    List<StorageUploadTask> get currentTasks => _currentTasks;
    bool get hasTasks => _lock != null;
    
    Completer<void> _queueCompleter;
    Future<void> _queueLock;
    
    Stream<List<StorageUploadTask>> get uploadTasksStream => _uploadTasksSubject.stream;
    
    Future<void> _upload( final List<File> files ) async {
        assert( files != null );
        assert( files.isNotEmpty );
        if ( _lock != null ) await _lock;
        _completer = new Completer();
        _lock = _completer.future;
        _queueCompleter.complete();
        _queueLock = null;
        
        try {
            _currentTasks = new List<StorageUploadTask>();
            for ( final file in files ) {
                final mime = lookupMimeType( file.path );
                if ( mime.startsWith("image") ) {
                    _currentTasks.add( _uploadImage(file) );
                }
            }
            _uploadTasksSubject.add( _currentTasks );
            final snapshots = await Future.wait( _currentTasks.map( ( task ) => task.onComplete ).toList( growable: false ) );
            _completer.complete( snapshots );
            _lock = null;
            _currentTasks = null;
        } catch ( error, st ) {
            _completer.completeError( error, st );
            _lock = null;
            _currentTasks = null;
        }
    }
    
    StorageUploadTask _uploadImage( final File file ) {
        final reference = FirebaseStorage.instance.ref().child("/event/images/${ Uuid().v4() }${ path.extension( file.path ) }");
        return reference.putFile(file);
    }
    
    Future<void> enqueue( final List<File> files ) async {
        if ( _queueLock != null ) await _queueLock;
        _queueCompleter = new Completer();
        _queueLock = _queueCompleter.future;
        _controller.add( files );
        await _queueLock;
    }
    
    Future<List<StorageUploadTask>> enqueueImages( final List<File> files ) async {
        assert( files != null );
        assert( files.isNotEmpty );
        if ( _lock != null ) await _lock;
        _completer = new Completer();
        _lock = _completer.future;
        
        _currentTasks = new List<StorageUploadTask>();
        for ( final file in files ) {
            final reference = FirebaseStorage.instance.ref().child("/event/images/${ Uuid().v4() }${ path.extension( file.path ) }");
            final uploadTask = reference.putFile(file);
            _currentTasks.add( uploadTask );
        }

        Future.wait( _currentTasks.map( ( task ) => task.onComplete ).toList( growable: false ) ).then(
            ( snapshots ) {
                _currentTasks = null;
                _completer.complete( snapshots );
                _lock = null;
            },
            onError: ( error, st ) {
                _currentTasks = null;
                _completer.completeError( error, st );
                _lock = null;
            },
        );
        
        return _currentTasks;
    }
    
}