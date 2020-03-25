import 'package:cached_network_image/cached_network_image.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:sdygd/common/config.dart';
import 'package:sdygd/model/event.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

enum _EventShareType {
    CAPTION,
    MEDIA,
}

class EventPage extends StatelessWidget {
    final Event event;
    
    const EventPage({Key key, this.event}) : super(key: key);
    
    @override
    Widget build(BuildContext context) => new Scaffold(
        body: new NestedScrollView(
            headerSliverBuilder: ( _, __ ) => <Widget>[
                new SliverAppBar(
                    title: new Text(
                        event.name,
                    ),
                    actions: <Widget>[
                        new IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareEvent( context ),
                        ),
                    ],
                ),
            ],
            body: new Padding(
                padding: const EdgeInsets.symmetric( horizontal: 10.0, ),
                child: new ListView.separated(
                    itemCount: event.images.length + 1,
                    separatorBuilder: ( _, __ ) => new SizedBox( height: 10.0, ),
                    itemBuilder: ( _, final int index ) {
                        if ( index == 0 ) {
                            return new Card(
                                elevation: DEFAULT_ELEVATION,
                                child: new Padding(
                                    padding: const EdgeInsets.all( 10.0 ),
                                    child: new Text(
                                        event.caption,
                                    ),
                                ),
                            );
                        } else {
                            return new Card(
                                elevation: DEFAULT_ELEVATION,
                                child: new Container(
                                    width: MediaQuery.of(context).size.width - 40,
                                    height: MediaQuery.of(context).size.width - 40,
                                    child: new FullScreenWidget(
                                        child: new CachedNetworkImage(
                                            imageUrl: event.images[ index - 1 ],
                                            fit: BoxFit.cover,
                                        ),
                                    ),
                                ),
                            );
                        }
                    },
                ),
            ),
        ),
    );
    
    void _shareEvent( final BuildContext context ) async {
        final shareType = await showModalBottomSheet(
            context: context,
            elevation: 10.0,
            builder: (BuildContext modalContext) => new ListView(
                shrinkWrap: true,
                children: <Widget>[
                    new ListTile(
                        title: new Text(
                            "Batal",
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                        leading: const Icon(Icons.close),
                        onTap: () => Navigator.of(modalContext).pop(),
                    ),
                    new ListTile(
                        title: new Text(
                            "Media",
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                        onTap: () => Navigator.of(modalContext).pop( _EventShareType.MEDIA ),
                    ),
                    new ListTile(
                        title: new Text(
                            "Caption",
                            style: const TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w700,
                            ),
                        ),
                        onTap: () => Navigator.of(modalContext).pop( _EventShareType.CAPTION ),
                    ),
                ],
            ),
        );
        
        if ( shareType == _EventShareType.MEDIA ) {
            final waiter = Flushbar(
                title: "Berbagi",
                message: "Mohon menunggu...",
                isDismissible: false,
            );
            waiter.show(context);
            final Map<String, List<int>> images = new Map();
            for ( final imageLink in event.images ) {
                final fileInfo = await new DefaultCacheManager().getFileFromCache( imageLink );
                final ref = await FirebaseStorage.instance.getReferenceFromUrl( imageLink );
                if ( fileInfo == null || fileInfo.file == null ) {
                    final downloadedFileInfo = await new DefaultCacheManager().downloadFile( imageLink );
                    final imageData = await downloadedFileInfo.file.readAsBytes();
                    images[ await ref.getName() ] = imageData;
                } else {
                    final imageData = await fileInfo.file.readAsBytes();
                    images[ await ref.getName() ] = imageData;
                }
            }
            await waiter.dismiss();
            await Share.files(
                event.name,
                images,
                "images/*",
            );
        } else if ( shareType == _EventShareType.CAPTION ) {
            Share.text( event.name, event.caption, "text/plain");
        }
    }
}
