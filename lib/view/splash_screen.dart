import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
    @override
    Widget build(BuildContext context) => new Material(
        color: Theme.of(context).primaryColor,
        child: new Center(
            child: new Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.width * 0.4,
                child: new Image.asset( "res/images/logo.png" ),
            ),
        ),
    );
}