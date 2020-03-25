import 'package:flutter/material.dart';
import 'package:sdygd/common/event_creator_manager.dart';
import 'package:sdygd/view/event_creation_progress_page.dart';
import 'package:sdygd/view/event_creator.dart';
import 'package:sdygd/view/event_list.dart';

class MainPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
    @override
    Widget build(BuildContext context) => new Scaffold(
        body: new NestedScrollView(
            headerSliverBuilder: (_, __) => <Widget>[
                new SliverAppBar(
                    centerTitle: true,
                    title: new Text(
                        "Acara",
                    ),
                ),
            ],
            body: new Padding(
                padding: const EdgeInsets.symmetric( horizontal: 20.0 ),
                child: new EventList(),
            ),
        ),
        floatingActionButton: new FloatingActionButton(
            child: const Icon( Icons.add ),
            onPressed: () {
                if ( EventCreatorManager.instance.isCreating ) {
                    Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: ( _ ) => new EventCreationProgressPage(),
                        ),
                    );
                } else {
                    Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: ( _ ) => new EventCreator(),
                        ),
                    );
                }
            },
        ),
    );
}
