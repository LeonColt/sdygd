import 'package:flutter/material.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/model/event.dart';
import 'package:sdygd/widget/image_grouping_widget.dart';

class EventTile extends StatelessWidget {
    final Event event;
    final VoidCallback onPressed;
    
    const EventTile({Key key, this.event, this.onPressed, }) : assert( event != null ), super(key: key);
    
    @override
    Widget build(BuildContext context) => new InkWell(
        child: new Card(
            elevation: DEFAULT_ELEVATION,
            child: new Padding(
                padding: const EdgeInsets.all( 10.0, ),
                child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                        new Text(
                            event.name,
                            style: const TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600,
                            ),
                        ),
                        new SizedBox( height: 5.0, ),
                        new Text(
                            event.caption,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                        ),
                        new SizedBox( height: 20.0, ),
                        new Container(
                            width: MediaQuery.of(context).size.width - 60,
                            height: MediaQuery.of(context).size.width - 60,
                            child: new GridCollageWidget(
                                images: event.images,
                            ),
                        ),
                    ],
                ),
            ),
        ),
        onTap: onPressed,
    );
}

