import 'package:dropdown_button2/dropdown_button2.dart';
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

    if (!globalUniScheduleConfiguration.loaded) {
        ref.invalidate(uniScheduleConfigurationProvider);
    }

    ref.invalidate(scheduleProvider);
    return Future<void>.value();
}

RefreshIndicator getLoadingIndicator(RefreshCallback onRefresh) {
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
            builder: (final context, final constraints) => ListView(
                children: [
                    SizedBox(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        child: const Center(child: CircularProgressIndicator.adaptive())
                    )
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
                    )
                ),
                Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(message),
                    )
                )
            ]
        )
    );
}

String plural(int n, List<String> variants) {
    final i = n % 10 == 1 && n % 100 != 11
        ? 0
        : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)
            ? 1
            : 2;

    return variants[i];
}

// Возвращает строку в формате "День-недели, число месяц"
String dateTitle() {
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
    const months = [
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

    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];

    return '$weekday, $day $month';
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

Future<void> launchLink(BuildContext context, String link) async {
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
    }
}

class UniScheduleTheme {
    const UniScheduleTheme({required this.themeMode,
                            required this.colorSchemeSeed,
                            required this.label});
    final ThemeMode themeMode;
    final Color colorSchemeSeed;
    final String label;
}

const uniScheduleThemes = {
    'system': UniScheduleTheme(themeMode: ThemeMode.system, colorSchemeSeed: Colors.indigoAccent, label: 'Системная'),
    'light':  UniScheduleTheme(themeMode: ThemeMode.light,  colorSchemeSeed: Colors.indigoAccent, label: 'Светлая'),
    'dark':   UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.indigoAccent, label: 'Тёмная'),

    //TODO Add new color themes
    //    UniScheduleTheme(themeMode: ThemeMode.light,  colorSchemeSeed: Colors.pinkAccent,   key: 'light-pink', label: 'Светло-розовая'),
    //    UniScheduleTheme(themeMode: ThemeMode.dark,   colorSchemeSeed: Colors.pinkAccent,   key: 'dark-pink',  label: 'Тёмно-розовая'),
};

class UniScheduleDropDownButton extends StatelessWidget {
    const UniScheduleDropDownButton({
            required this.hint,
            required this.initialSelection,
            required this.items,
            required this.onSelected,
            this.alignment = Alignment.center,
            super.key,
    });

    final String hint;
    final String? initialSelection;
    final List<DropdownMenuItem<String>>? items;
    final ValueChanged<String?>? onSelected;
    final Alignment alignment;

    @override
    Widget build(BuildContext context) {
        return DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
                isExpanded: false,
                isDense: false,
                alignment: alignment,
                hint: Text(hint),
                items: items,
                value: initialSelection,
                onChanged: onSelected,

                iconStyleData: const IconStyleData(
                    icon: Icon(Icons.arrow_drop_down),
                    openMenuIcon: Icon(Icons.arrow_drop_up),
                ),

                buttonStyleData: ButtonStyleData(
                    // padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                ),

                dropdownStyleData: DropdownStyleData(
                    // isOverButton: true,

                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(16),
                        thickness: MaterialStateProperty.all<double>(16),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                    ),
                ),

                menuItemStyleData: const MenuItemStyleData(
                    // height: 40,
                    //padding: EdgeInsets.only(left: 16, right: 16),
                ),
            ),
        );
    }
}
