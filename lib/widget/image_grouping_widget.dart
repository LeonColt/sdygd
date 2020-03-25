import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GridCollageWidget extends StatelessWidget {
    final List<String> images;
    final VoidCallback onMorePressed;
    
    const GridCollageWidget({Key key, this.images, this.onMorePressed}) : assert( images != null ), super(key: key);
    
    @override
    Widget build(BuildContext context) {
        if ( images.length == 1 ) return _getSingleImage();
        else if ( images.length == 2 ) return _getTwoImages();
        else if ( images.length == 3 ) return _getThreeImages();
        else if ( images.length == 4 ) return _getFourImages();
        else if ( images.length == 5 ) return _getFiveImages();
        else return _getImages();
    }
    
    Widget _getSingleImage() => new CachedNetworkImage(
        imageUrl: images.first,
        fit: BoxFit.cover,
    );
    
    Widget _getTwoImages() => new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            new Expanded(
                child: new CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                ),
            ),
            new Expanded(
                child: new CachedNetworkImage(
                    imageUrl: images.last,
                    fit: BoxFit.cover,
                ),
            ),
        ],
    );
    
    Widget _getThreeImages() => new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            new Expanded(
                child: new CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                ),
            ),
            new Expanded(
                child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images[1],
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images.first,
                                fit: BoxFit.cover,
                            ),
                        ),
                    ],
                ),
            ),
        ],
    );

    Widget _getFourImages() => new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            new Expanded(
                child: new Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images.first,
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images[1],
                                fit: BoxFit.cover,
                            ),
                        ),
                    ],
                ),
            ),
            new Expanded(
                child: new Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images[2],
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images.last,
                                fit: BoxFit.cover,
                            ),
                        ),
                    ],
                ),
            ),
        ],
    );
    
    Widget _getFiveImages() => new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            new Expanded(
                child: new CachedNetworkImage(
                    imageUrl: images.first,
                    fit: BoxFit.cover,
                ),
            ),
            new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                    new Expanded(
                        child: new CachedNetworkImage(
                            imageUrl: images[1],
                            fit: BoxFit.cover,
                        ),
                    ),
                    new Expanded(
                        child: new CachedNetworkImage(
                            imageUrl: images[2],
                            fit: BoxFit.cover,
                        ),
                    ),
                    new Expanded(
                        child: new CachedNetworkImage(
                            imageUrl: images[3],
                            fit: BoxFit.cover,
                        ),
                    ),
                    new Expanded(
                        child: new CachedNetworkImage(
                            imageUrl: images.last,
                            fit: BoxFit.cover,
                        ),
                    ),
                ],
            ),
        ],
    );
    
    Widget _getImages() => new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
            new Flexible(
                flex: 3,
                fit: FlexFit.tight,
                child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        new Flexible(
                            fit: FlexFit.tight,
                            flex: 3,
                            child: new CachedNetworkImage(
                                imageUrl: images.first,
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Flexible(
                            fit: FlexFit.loose,
                            flex: 1,
                            child: new Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                    new Expanded(
                                        child: new CachedNetworkImage(
                                            imageUrl: images[1],
                                            fit: BoxFit.cover,
                                        ),
                                    ),
                                    new Expanded(
                                        child: new CachedNetworkImage(
                                            imageUrl: images[2],
                                            fit: BoxFit.cover,
                                        ),
                                    ),
                                ],
                            ),
                        ),
                    ],
                ),
            ),
            new Flexible(
                fit: FlexFit.loose,
                flex: 1,
                child: new Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images[3],
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Expanded(
                            child: new CachedNetworkImage(
                                imageUrl: images[4],
                                fit: BoxFit.cover,
                            ),
                        ),
                        new Expanded(
                            child: images.length > 6 ? _getMoreImage( images[5] ) : new CachedNetworkImage(
                                imageUrl: images[5],
                                fit: BoxFit.cover,
                            ),
                        ),
                    ],
                ),
            ),
        ],
    );
    
    Widget _getMoreImage( final String imageLink ) => new InkWell(
        child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
                new ClipRect(
                    child: new BackdropFilter(
                        filter: new ImageFilter.blur( sigmaX: 10.0, sigmaY: 10.0 ),
                        child: new Container(
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity( 0.25 ),
                                image: new DecorationImage(
                                    image: new CachedNetworkImageProvider(
                                        imageLink,
                                    ),
                                    fit: BoxFit.cover,
                                )
                            ),
                        ),
                    )
                ),
                new Align(
                    alignment: Alignment.center,
                    child: new Text(
                        "+${ images.length - 6 }",
                        style: const TextStyle( fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.white, ),
                    ),
                ),
            ],
        ),
        onTap: onMorePressed,
    );
}