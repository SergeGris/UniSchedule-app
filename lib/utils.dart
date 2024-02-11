import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:http/http.dart' as http;
import 'provider.dart';

import 'package:url_launcher/url_launcher.dart';

import 'models/schedule.dart';
import 'globalkeys.dart';
import 'configuration.dart';

Future<void> refreshSchedule(WidgetRef ref) {
    GlobalKeys.hideWarningBanner();

    if (!globalUniScheduleConfiguration.loaded) {
        ref.invalidate(uniScheduleConfigurationProvider);
    }

    ref.invalidate(scheduleProvider);
    return Future<void>.value();
}

RefreshIndicator getLoadingIndicator(RefreshCallback onRefresh) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(builder: (context, final constraints) {
                return ListView(
                    children: [
                        SizedBox(
                            height: constraints.maxHeight,
                            width: constraints.maxWidth,
                            child: const Center(child: CircularProgressIndicator.adaptive()))
                    ],
                );
        }),
    );
}

String plural(int n, List<String> variants) {
    int i = n % 10 == 1 && n % 100 != 11
        ? 0
        : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)
            ? 1
            : 2;

    return variants[i];
}

Widget getErrorContainer(String message) {
    return LayoutBuilder(
        builder: (final context, final constraints) {
            return ListView(
                children: [
                    const Center(
                        child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                        )
                    ),
                    Center(
                        child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(message),
                        )
                    )
                ]
            );
        }
    );
}

Future<String> downloadFileByUri(Uri uri) async {
    var response = await http.get(uri);
    return response.body;
}

// Возвращает строку в формате "День-недели, число месяц"
String dateTitle(WidgetRef ref) {
    final date = DateTime.now();

    // Именительный падеж (кто?/что?)
    const weekdays = [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
    ];

    // Винительный падеж (кого?/чего?)
    final months = [
        'января',
        'февраля',
        'марта',
        'апреля',
        'мая',
        'июня',
        'июля',
        'августа',
        'сентября',
        'октября',
        'ноября',
        'декабря',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}

int? getWeekIndex(DateTime date, Schedule schedule) {
    if (schedule.studiesBegin == null || date.isBefore(schedule.studiesBegin!)
     || (schedule.studiesEnd  != null && date.isAfter(schedule.studiesEnd!))) {
        return null;
    }

    return date.weekOfYear - schedule.studiesBegin!.weekOfYear;
}

int getWeekParity({required DateTime date,
                   required Schedule schedule,
                   required bool showCurrentWeek}) {
    return ((getWeekIndex(date, schedule) ?? 0) + (showCurrentWeek ? 0 : 1)) % schedule.weeks.length;
}

extension ExtendedIterable<E> on Iterable<E> {
    // Like Iterable<T>.map but the callback has index as second argument.
    Iterable<T> mapIndexed<T>(T Function(E e, int i) callback) {
        var i = 0;
        return map((e) => callback(e, i++));
    }
}

class Version {
    Version.fromString(String string) {
        final s = string.split('.');

        major = s.length > 0 ? int.parse(s[0]) : 0;
        minor = s.length > 1 ? int.parse(s[1]) : 0;
        patch = s.length > 2 ? int.parse(s[2]) : 0;
    }

    bool greaterThan(Version other) =>
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
    int differenceInMinutes(TimeOfDay other) => (hour - other.hour) * 60 + (minute - other.minute);

    bool isAfterThan(TimeOfDay other)     => hour * 60 + minute > other.hour * 60 + other.minute;
    bool isBeforeThan(TimeOfDay other)    => hour * 60 + minute < other.hour * 60 + other.minute;
    bool isNotAfterThan(TimeOfDay other)  => !isAfterThan(other);
    bool isNotBeforeThan(TimeOfDay other) => !isBeforeThan(other);
}

Future<void> launchUrl(BuildContext context, String url) async {
    if (await canLaunch(url)) {
        await launch(url);
    } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                title: const Text('Ошибка!'),
                content: Text('Не удалось открыть ${url}'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Понятно'),
                    ),
                ],
            ),
        );
    }
}

class UniScheduleTheme {
    const UniScheduleTheme({required this.themeMode,
                            required this.colorSchemeSeed,
                            required this.key,
                            required this.label});
    final ThemeMode themeMode;
    final Color colorSchemeSeed;
    final String key;
    final String label;
}

const uniScheduleThemes = [
    UniScheduleTheme(themeMode: ThemeMode.system, colorSchemeSeed: Colors.indigoAccent, key: 'system',     label: 'Системная'),
    UniScheduleTheme(themeMode: ThemeMode.light,  colorSchemeSeed: Colors.indigoAccent, key: 'light',      label: 'Светлая'),
    UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.indigoAccent, key: 'dark',       label: 'Тёмная'),
    //TODO Add new color themes
//    UniScheduleTheme(themeMode: ThemeMode.light,  colorSchemeSeed: Colors.pinkAccent,   key: 'light-pink', label: 'Светло-розовая'),
//    UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.pinkAccent,   key: 'dark-pink',  label: 'Тёмно-розовая'),
];
