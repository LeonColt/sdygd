import 'package:flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:mobx/mobx.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sdygd/common/error_reporter.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/model/event.dart';
import 'package:sdygd/repository/event_repository.dart';
import 'package:sdygd/view/event_page.dart';
import 'package:sdygd/view/event_tile.dart';

part 'event_list.g.dart';

class EventList extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => new _EventListState();
}

class _EventListState extends State<EventList> {
    _EventListController _controller;
    @override
    Widget build(BuildContext context) => new StreamBuilder<List<Event>>(
        stream: _controller.stream,
        initialData: const [],
        builder: ( _, snapshot ) => new Observer(
            builder: ( _ ) => new LazyLoadScrollView(
                onEndOfPage: _controller.onLoad,
                scrollOffset: 100,
                isLoading: _controller.endLoadMore,
                child: new ListView.separated(
                    itemCount: snapshot.data.length,
                    separatorBuilder: ( _, __ ) => new SizedBox( height: 20.0, ),
                    itemBuilder: ( _, final int index ) => new EventTile(
                        event: snapshot.data[index],
                        onPressed: () => Navigator.of( context ).push(
                            new MaterialPageRoute(
                                builder: ( _ ) => new EventPage(
                                    event: snapshot.data[index],
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        ),
    );
    
    @override
    void initState() {
        _controller = new _EventListController( context );
        super.initState();
    }
    
    @override
    void dispose() {
        _controller.dispose();
        super.dispose();
    }
}

class _EventListController = _EventListControllerBase with _$_EventListController;

abstract class _EventListControllerBase with Store {
    final BuildContext context;
    final BehaviorSubject<List<Event>> _eventsSubject;
    
    Stream<List<Event>> _eventStream;
    
    int _limit = DEFAULT_EVENTS_PER_PAGE;
    
    @observable bool endLoadMore =  false;
    
    _EventListControllerBase( this.context ) : _eventsSubject = new BehaviorSubject.seeded( const [] ) {
        _eventStream = EventRepository.getEventsStream( _limit );
        _eventStream.listen(
            ( final List<Event> data ) => _eventsSubject.add( data ),
            onError: ( error, st ) {
                ErrorReporter.instance.captureException(error, stackTrace: st);
            },
            cancelOnError: false,
        );
    }
    
    Stream<List<Event>> get stream => _eventsSubject.stream;
    
    @action Future<void> onLoad() async {
        try {
            if ( _eventsSubject.value.length < _limit ) {
                endLoadMore = true;
            } else {
                _limit += DEFAULT_EVENTS_PER_PAGE;
                _eventStream = EventRepository.getEventsStream( _limit );
                _eventStream.listen(
                            ( final List<Event> data ) => _eventsSubject.add(data),
                    onError: ( error, st ) => _eventsSubject.addError(error, st),
                    cancelOnError: false,
                );
                endLoadMore = false;
            }
        } catch ( error, st ) {
            ErrorReporter.instance.captureException( error, stackTrace: st );
            FlushbarHelper.createError(message: "Terjadi kesalahan.").show(context);
        }
    }
    
    void dispose() {
        _eventsSubject.close();
    }
}
