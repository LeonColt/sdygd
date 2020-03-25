import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sdygd/common/config.dart';
import 'package:sentry/sentry.dart';

class ErrorReporter {
    static final _reporter = ErrorReporter._internal();
    
    static ErrorReporter get instance => _reporter;
    String configLink;
    SentryClient _client;
    
    ErrorReporter._internal();
    
    void _init() {
        _client = new SentryClient(dsn: config.sentryDsn);
    }
    
    Future<SentryResponse> captureException(dynamic exception,
            {dynamic stackTrace}) async {
        if (kReleaseMode) {
            if (_client == null) _init();
            return _client.captureException(
                    exception: exception, stackTrace: stackTrace);
        } else {
            if (exception.toString().isEmpty) {
                print("empty exception wtf, ${exception.runtimeType}");
                print(stackTrace);
            } else if (exception is MissingRequiredKeysException) {
                print(exception.missingKeys);
            } else if (exception is DisallowedNullValueException) {
                print(exception.keysWithNullValues);
            } else {
                print(exception);
                print(stackTrace);
            }
            return null;
        }
    }
    
    Future<SentryResponse> capture(Event event) async {
        if (kReleaseMode) {
            if (_client == null) _init();
            return _client.capture(event: event);
        } else {
            print(event);
            return null;
        }
    }
    
    void setUserContext(User user) => _client.userContext = user;
}
