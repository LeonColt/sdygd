import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sdygd/common/error_reporter.dart';
import 'package:sdygd/common/session_manager.dart';
import 'package:sdygd/translations/i18n.dart';
import 'package:sdygd/view/splash_screen.dart';

void mainCommon() {
    FlutterError.onError = (FlutterErrorDetails details) => ErrorReporter.instance
            .captureException(details.exception, stackTrace: details.stack);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
    // This widget is the root of your application.
    
    GlobalKey<NavigatorState> _navigatorState = new GlobalKey();
    
    MyApp() {
        SessionManager.instance.init( _navigatorState );
    }
    
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            navigatorKey: _navigatorState,
            title: 'Flutter Demo',
            localizationsDelegates: [
                I18N.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: I18N.delegate.supportedLocales,
            localeResolutionCallback:
            I18N.delegate.resolution(fallback: const Locale('id', '')),
            theme: ThemeData(
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or simply save your changes to "hot reload" in a Flutter IDE).
                // Notice that the counter didn't reset back to zero; the application
                // is not restarted.
                primarySwatch: Colors.blue,
            ),
            home: new SplashScreen(),
        );
    }
}