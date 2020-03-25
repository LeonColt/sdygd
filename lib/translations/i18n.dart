import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 's.i18n.dart';
import 's_id.i18n.dart';

class I18N implements WidgetsLocalizations {
    const I18N();
    
    static S current;
    
    @override TextDirection get textDirection => TextDirection.ltr;
    
    static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();
    
    static S of(BuildContext context) => Localizations.of<S>(context, S);
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
    const GeneratedLocalizationsDelegate();
    
    List<Locale> get supportedLocales {
        return const <Locale>[
            Locale("en", ""),
            Locale("id", ""),
        ];
    }
    
    LocaleListResolutionCallback listResolution({Locale fallback, bool withCountry = true}) {
        return (List<Locale> locales, Iterable<Locale> supported) {
            if (locales == null || locales.isEmpty) {
                return fallback ?? supported.first;
            } else {
                return _resolve(locales.first, fallback, supported, withCountry);
            }
        };
    }
    
    LocaleResolutionCallback resolution({Locale fallback, bool withCountry = true}) {
        return (Locale locale, Iterable<Locale> supported) {
            return _resolve(locale, fallback, supported, withCountry);
        };
    }
    
    @override
    Future<S> load(Locale locale) {
        final String lang = getLang(locale);
        if (lang != null) {
            switch (lang) {
                case "en":
                    I18N.current = const S();
                    return SynchronousFuture<S>(I18N.current);
                case "id":
                    I18N.current = const S_id();
                    return SynchronousFuture<S>(I18N.current);
                default:
                // NO-OP.
            }
        }
        I18N.current = const S();
        return SynchronousFuture<S>(I18N.current);
    }
    
    @override
    bool isSupported(Locale locale) => _isSupported(locale, true);
    
    @override
    bool shouldReload(GeneratedLocalizationsDelegate old) => false;
    
    ///
    /// Internal method to resolve a locale from a list of locales.
    ///
    Locale _resolve(Locale locale, Locale fallback, Iterable<Locale> supported, bool withCountry) {
        if (locale == null || !_isSupported(locale, withCountry)) {
            return fallback ?? supported.first;
        }
        
        final Locale languageLocale = Locale(locale.languageCode, "");
        if (supported.contains(locale)) {
            return locale;
        } else if (supported.contains(languageLocale)) {
            return languageLocale;
        } else {
            final Locale fallbackLocale = fallback ?? supported.first;
            return fallbackLocale;
        }
    }
    
    ///
    /// Returns true if the specified locale is supported, false otherwise.
    ///
    bool _isSupported(Locale locale, bool withCountry) {
        if (locale != null) {
            for (Locale supportedLocale in supportedLocales) {
                // Language must always match both locales.
                if (supportedLocale.languageCode != locale.languageCode) {
                    continue;
                }
                
                // If country code matches, return this locale.
                if (supportedLocale.countryCode == locale.countryCode) {
                    return true;
                }
                
                // If no country requirement is requested, check if this locale has no country.
                if (true != withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode.isEmpty)) {
                    return true;
                }
            }
        }
        return false;
    }
}

String getLang(Locale l) => l == null
        ? null
        : l.countryCode != null && l.countryCode.isEmpty
        ? l.languageCode
        : l.toString();