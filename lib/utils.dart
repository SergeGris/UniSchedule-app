import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:week_of_year/week_of_year.dart';

import 'configuration.dart';
import 'globalkeys.dart';
import 'models/schedule.dart';
import 'provider.dart';

Future<void> refreshSchedule(WidgetRef ref) {
    GlobalKeys.hideWarningBanner();

    if (!UniScheduleConfiguration.loaded) {
        ref.invalidate(uniScheduleConfigurationProvider);
    }

    ref.invalidate(scheduleProvider);
    return Future<void>.value();
}

Future<void> refreshConfiguration(WidgetRef ref) {
    ref.invalidate(uniScheduleConfigurationProvider);
    return Future<void>.value();
}

RefreshIndicator getLoadingIndicator(RefreshCallback onRefresh) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
            builder: (final context, final constraints) => ListView(
                children: <Widget>[
                    SizedBox(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        child: const Center(child: CircularProgressIndicator.adaptive())
                    ),
                ],
            ),
        ),
    );
}

Widget getErrorContainer(String message) {
    return LayoutBuilder(
        builder: (final context, final constraints) => ListView(
            children: [
                const Center(
                    child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                    ),
                ),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(message),
                    ),
                ),
            ],
        ),
    );
}

void showSnackBar(BuildContext context, Widget content) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: content));
}

int? getWeekIndex(DateTime date, Schedule schedule) {
    if (schedule.studiesBegin == null || date.isBefore(schedule.studiesBegin!)
     || (schedule.studiesEnd  != null && date.isAfter(schedule.studiesEnd!))) {
        return null;
    }

    return date.weekOfYear - schedule.studiesBegin!.weekOfYear;
}

int getWeekParity(DateTime date, Schedule schedule, {bool showNextWeek = false}) {
    return ((getWeekIndex(date, schedule) ?? 0) + (showNextWeek ? 1 : 0)) % schedule.weeks.length;
}

String numberToWords(int n) {
    // Just a number. As is.
    if (n >= 100) {
        return '$n';
    }

    const a = [
        'ноль',
        'один',
        'два',
        'три',
        'четыре',
        'пять',
        'шесть',
        'семь',
        'восемь',
        'девять',
    ];

    const b = [
        'десять',
        'двадцать',
        'тридцать',
        'сорок',
        'пятьдесят',
        'шестьдесят',
        'семьдесят',
        'восемьдесят',
        'девяносто',
    ];

    const c = [
        'одиннадцать',
        'двенадцать',
        'тринадцать',
        'четырнадцать',
        'пятнадцать',
        'шестнадцать',
        'семнадцать',
        'восемнадцать',
        'девятнадцать',
    ];

    if (n < 10) {
        return a[n];
    } else if (10 < n && n < 20) {
        return c[n - 11];
    } else if (n % 10 == 0) {
        return b[n ~/ 10 - 1];
    } else {
        return b[(n - (n % 10)) ~/ 10 - 1] + ' ' + a[n % 10];
    }
}

extension ExtendedIterable<E> on Iterable<E> {
    // Like Iterable<T>.map but the callback has index as second argument.
    Iterable<T> mapIndexed<T>(T Function(E e, int i) callback) {
        var i = 0;
        return map((e) => callback(e, i++));
    }
}

extension ListFromMap<Key, Element> on Map<Key, Element> {
    List<T> toList<T>(T Function(MapEntry<Key, Element> entry) getElement) => entries.map(getElement).toList();
}

class Version {
    Version.fromString(String string) {
        final s = string.split('.');

        major = s.length > 0 ? int.parse(s[0]) : 0;
        minor = s.length > 1 ? int.parse(s[1]) : 0;
        patch = s.length > 2 ? int.parse(s[2]) : 0;
    }

    bool greaterThan(final Version other) =>
        (major > other.major
            || (major == other.major
                && (minor > other.minor
                    || (minor == other.minor
                        && (patch > other.patch)))));

    int major = 0;
    int minor = 0;
    int patch = 0;
}

extension TimeOfDayExtension on TimeOfDay {
    int differenceInMinutes(final TimeOfDay other) => (hour - other.hour) * 60 + (minute - other.minute);
    bool isAfterThan(final TimeOfDay other)        => differenceInMinutes(other) > 0;
    bool isBeforeThan(final TimeOfDay other)       => differenceInMinutes(other) < 0;
    bool isNotAfterThan(final TimeOfDay other)     => !isAfterThan(other);
    bool isNotBeforeThan(final TimeOfDay other)    => !isBeforeThan(other);
}

Future<bool> launchLink(BuildContext context, String link) async {
    final url = Uri.parse(link);

    // TODO add can launch url check which won't work on some phones
    // TODO fails on web version, but launchs link
    if (!await launchUrl(url)) {
        await showDialog(
            context: context,
            builder: (final context) => AlertDialog(
                title: const Text('Ошибка!'),
                content: Text('Не удалось открыть $url'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context), // TODO pop context?..
                        child: const Text('Понятно'),
                    )
                ]
            )
        );

        return Future.value(false);
    }

    return Future.value(true);
}

bool isDarkMode(final BuildContext context) => Theme.of(context).brightness == Brightness.dark;

Color primaryContainerColor(final BuildContext context) =>
    Theme.of(context).colorScheme.primaryContainer.withOpacity(isDarkMode(context) ? 0.2 : 1.0);

double getScale(final context, final fontSize) {
    return MediaQuery.textScalerOf(context).scale(fontSize) / fontSize;
}

double min(double a, double b) => a <= b ? a : b;

class Constants {
    static const double goldenRatio = 0.618033988751;
}

class UniScheduleTheme {
     UniScheduleTheme({required this.themeMode,
                       required this.colorSchemeSeed,
                       required this.label});
    ThemeMode themeMode;
    Color colorSchemeSeed;
    final String label;
}

final uniScheduleThemeSystem = UniScheduleTheme(themeMode: ThemeMode.system, colorSchemeSeed: Colors.indigoAccent, label: 'Системная');
final uniScheduleThemeLight  = UniScheduleTheme(themeMode: ThemeMode.light,  colorSchemeSeed: Colors.indigoAccent, label: 'Светлая');
final uniScheduleThemeDark   = UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.indigoAccent, label: 'Тёмная');
var   uniScheduleThemeCustom = UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.indigoAccent, label: 'Персональная');

final uniScheduleThemes = {
    'system': () => uniScheduleThemeSystem,
    'light':  () => uniScheduleThemeLight,
    'dark':   () => uniScheduleThemeDark,
    'custom': () => uniScheduleThemeCustom,
};

//TODO need?
// extension ColorExtension on String {
//   toColor() {
//       var hexColor = this.replaceAll("#", "");
//       if (hexColor.length == 6) {
//           hexColor = "FF" + hexColor;
//       }
//       if (hexColor.length == 8) {
//           return Color(int.parse("0x$hexColor"));
//       }
//   }
// }

extension StringExtension on Color {
    String toPrettyString({bool showAlpha = false}) {
        String twoDigits(int n) => (n >= 0x10 ? '' : '0') + n.toRadixString(16).toUpperCase();
        return '#'
        + twoDigits(red)
        + twoDigits(green)
        + twoDigits(blue)
        + (showAlpha ? twoDigits(alpha) : '');
    }
}
