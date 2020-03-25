
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sdygd/view/main_page.dart';
import 'package:sdygd/view/sign_in.dart';

class SessionManager {
    static final instance = SessionManager._internal();
    
    SessionManager._internal();
    
    GlobalKey<NavigatorState> navigatorState;
    
    Future<void> init( final GlobalKey<NavigatorState> navigatorState ) async {
        while( navigatorState.currentState == null )  await Future.delayed( const Duration( milliseconds: 500 ) );
        this.navigatorState = navigatorState;
        FirebaseAuth.instance.onAuthStateChanged.listen( ( final FirebaseUser user ) async {
            if ( user == null ) {
                navigatorState.currentState.pushAndRemoveUntil(
                    new MaterialPageRoute(
                        builder: ( _ ) => new SignIn(),
                    ),
                    ( _ ) => false,
                );
            } else {
                navigatorState.currentState.pushAndRemoveUntil(
                    new MaterialPageRoute(
                        builder: ( _ ) => new MainPage(),
                    ),
                    ( _ ) => false,
                );
            }
        } );
    }
}