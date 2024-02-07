import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:http/http.dart' as http;
import 'provider.dart';

import 'package:url_launcher/url_launcher.dart';

import 'models/schedule.dart';
import 'globalkeys.dart';
import 'manifest.dart';

Future<void> refreshSchedule(WidgetRef ref) {
    GlobalKeys.hideWarningBanner();

    if (!globalUniScheduleManifest.loaded) {
        ref.invalidate(uniScheduleManifestProvider);
    }

    return ref.refresh(scheduleProvider.future);
}

RefreshIndicator getLoadingIndicator(RefreshCallback onRefresh) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(builder: (context, constraints) {
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
        builder: (context, constraints) {
            return ListView(
                children: [
                    Center(
                        child: const Icon(
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
    print(uri);

    var response = await http.get(uri);
    return response.body;
}

String dayName(int number) {
    assert(number >= 1 && number <= 7);

    // Именительный падеж (кто?/что?)
    return [
        'Понедельник',
        'Вторник',
        'Среда',
        'Четверг',
        'Пятница',
        'Суббота',
        'Воскресенье',
    ][number - 1];
}

String dateTitle(WidgetRef ref) {
    final date = DateTime.now();

    // Винительный падеж (кого?/чего?)
    final month = [
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
    ][date.month - 1];

    return '${dayName(date.weekday)}, ${date.day} $month';
}

int? getWeekNumber(DateTime date, Schedule? schedule) {
    if (schedule == null
     || schedule.studiesBegin == null || date.isBefore(schedule.studiesBegin!)
     || (schedule.studiesEnd  != null && date.isAfter(schedule.studiesEnd!))) {
        return null;
    }

    return date.weekOfYear - schedule.studiesBegin!.weekOfYear;
}

extension ExtendedIterable<E> on Iterable<E> {
    /// Like Iterable<T>.map but the callback has index as second argument
    Iterable<T> mapIndexed<T>(T Function(E e, int i) callback) {
        var i = 0;
        return map((e) => callback(e, i++));
    }
}

List<int> parseVersion(String version) {
    final s = version.split('.');
    final v = [ 0, 0, 0 ];

    for (int i = 0; i < 3; i++) {
        if (i < s.length) {
            v[i] = int.parse(s[i]);
        } else {
            v[i] = 0;
            break;
        }
    }

    return v;
}

extension TimeOfDayExtension on TimeOfDay {
    int differenceInMinutes(TimeOfDay other) {
        return (this.hour - other.hour) * 60 + (this.minute - other.minute);
    }

    bool isAfterThan(TimeOfDay other) {
        return this.hour * 60 + this.minute > other.hour * 60 + other.minute;
    }

    bool isBeforeThan(TimeOfDay other) {
        return this.hour * 60 + this.minute < other.hour * 60 + other.minute;
    }

    bool isNotAfterThan(TimeOfDay other) {
        return !isAfterThan(other);
    }

    bool isNotBeforeThan(TimeOfDay other) {
        return !isBeforeThan(other);
    }
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
