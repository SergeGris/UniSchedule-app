// Copyright (C) 2024 Sergey Sushilin <sushilinsergey@yandex.ru>.
// This file is part of UniSchedule.

// UniSchedule is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.

// UniSchedule is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with UniSchedule.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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
            children: <Widget>[
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
    if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: content));
    }
}

int? getWeekIndex(DateTime date, Schedule schedule) {
    if (schedule.studiesBegin == null || date.isBefore(schedule.studiesBegin!)
        || (schedule.studiesEnd != null && date.isAfter(schedule.studiesEnd!))) {
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
    } else if (11 <= n && n <= 19) {
        return c[n - 11];
    } else if (n % 10 == 0) {
        return b[n ~/ 10 - 1];
    } else {
        return b[n ~/ 10 - 1] + ' ' + a[n % 10];
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

const kAnimationDuration = Duration(milliseconds: 200);

// TODO: Implement as extension
class AnimatedNavigator {
    @optionalTypeArgs
    static Future<T?> push<T extends Object?>(BuildContext context, Widget Function(BuildContext context) builder) async => Navigator.push<T?>(
        context,
        PageRouteBuilder(
            transitionDuration: kAnimationDuration,
            reverseTransitionDuration: kAnimationDuration,
            pageBuilder: (context, animation, secondaryAnimation) {
                return FadeTransition(
                    opacity: animation,
                    child: builder(context),
                );

                return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                        position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                        ).animate(animation),
                        child: builder(context),
                    ),
                );
            },
        )
    );
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
                    || (minor == other.minor && (patch > other.patch)))));

    int major = 0;
    int minor = 0;
    int patch = 0;
}

extension TimeOfDayExtension on TimeOfDay {
    String format24hour() {
        String twoDigits(int n) => n >= 10 ? '$n' : '0$n';
        return twoDigits(hour) + ':' + twoDigits(minute);
    }

    int differenceInMinutes(final TimeOfDay other) => (hour - other.hour) * 60 + (minute - other.minute);
    bool isAfterThan(final TimeOfDay other) => differenceInMinutes(other) > 0;
    bool isBeforeThan(final TimeOfDay other) => differenceInMinutes(other) < 0;
    bool isNotAfterThan(final TimeOfDay other) => !isAfterThan(other);
    bool isNotBeforeThan(final TimeOfDay other) => !isBeforeThan(other);
}

String plural(int n, List<String> variants) {
    final i = n % 10 == 1 && n % 100 != 11
        ? 0
        : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)
            ? 1
            : 2;

    return variants[i];
}

String timeToPrettyView(final int hours, final int minutes) {
    // Используем именительный падеж.
    final h = hours > 0   ? '$hours '   + plural(hours,   [ 'час', 'часа', 'часов' ])      : null;
    final m = minutes > 0 ? '$minutes ' + plural(minutes, [ 'минута', 'минуты', 'минут' ]) : null;

    return [ h, m ].nonNulls.join(' ');
}

Future<bool> launchLink(final BuildContext context, final String link) async {
    final url = Uri.parse(link);

    // TODO add can launch url check which won't work on some phones
    // TODO fails on web version, but launchs link
    if (!await launchUrl(url)) {
        await showDialog<void>(
            context: context,
            builder: (final context) => AlertDialog(
                title: const Text('Ошибка!'),
                content: Text('Не удалось открыть $url'),
                actions: <Widget>[
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Понятно'),
                    ),
                ],
            ),
        );

        return Future.value(false);
    }

    return Future.value(true);
}

bool isDarkMode(final BuildContext context) => Theme.of(context).brightness == Brightness.dark;

double textWidth(final BuildContext context, final String text, final TextStyle style) {
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
}

abstract final class Constants {
    static const double goldenRatio = 0.618033988751;
}

// FUCK TODO fucking magic constant. Pay attention to <https://stackoverflow.com/a/62536187>
double getScheduleTabHeight(final BuildContext context) => MediaQuery.textScalerOf(context).scale(60.0);

enum ColorTheme {
    system(ThemeMode.system, 'Системная'),
    light(ThemeMode.light, 'Светлая'),
    dark(ThemeMode.dark, 'Тёмная'),
    custom(null, 'Персональная');

    const ColorTheme(this._themeMode, this.label);

    ThemeMode get themeMode => this == custom ? CustomColorTheme.themeMode : _themeMode!;
    Color get colorSchemeSeed => this == custom ? CustomColorTheme.colorSchemeSeed : _colorSchemeSeed;

    final ThemeMode? _themeMode;
    final Color _colorSchemeSeed = Colors.indigoAccent;
    final String label;

    static ColorTheme fromString(String? name) => values.firstWhere((t) => t.name == name, orElse: () => system);
}

final class CustomColorTheme {
    static ThemeMode themeMode = ThemeMode.system;
    static Color colorSchemeSeed = Colors.indigoAccent;
}

extension StringExtension on Color {
    String toPrettyString({bool showAlpha = false}) {
        String twoHexDigits(int n) => (n >= 0x10 ? '' : '0') + n.toRadixString(16).toUpperCase();

        return '#'
            + twoHexDigits(red)
            + twoHexDigits(green)
            + twoHexDigits(blue)
            + (showAlpha ? twoHexDigits(alpha) : '');
    }
}

class ColoredElevatedCircle extends StatelessWidget {
    const ColoredElevatedCircle({super.key, required this.color, required this.size, this.elevation = 1});

    final Color color;
    final double elevation;
    final double size;

    @override
    Widget build(BuildContext context) => Material(
        elevation: elevation,
        type: MaterialType.circle,
        color: Colors.transparent,
        child: Icon(Icons.circle, color: color, size: size),
    );
}

class LinkSpan extends TextSpan {
    LinkSpan({
            required this.text,
            this.link,
            required this.onTap,
    }) : super(
        recognizer: TapGestureRecognizer()..onTap = () async => onTap(link ?? text),
        style: _textStyle,
    );

    static const _color = Color(0xFF3366CC);
    static const _textStyle = TextStyle(
        color: _color,
        decoration: TextDecoration.underline,
        decorationColor: _color,
    );
    final String text;
    final String? link;
    final void Function(String link) onTap;
}

class Link extends StatelessWidget {
    Link({super.key, required this.text, this.link});

    final String text;
    final String? link;
    bool _isHover = false;
    static const _color = Color(0xFF3366CC);

    @override
    Widget build(BuildContext context) {
        final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
        TextStyle? effectiveTextStyle = defaultTextStyle.style;

        if (MediaQuery.boldTextOf(context)) {
            effectiveTextStyle = effectiveTextStyle!.merge(
                const TextStyle(fontWeight: FontWeight.bold)
            );
        }

        return StatefulBuilder(
            builder: (context, setState) => MouseRegion(
                onEnter: (_) => setState(() => _isHover = true),
                onExit: (_) => setState(() => _isHover = false),
                cursor: SystemMouseCursors.click, // Change cursor to pointer
                child: GestureDetector(
                    onTap: () async => launchLink(context, link ?? text),
                    child: Text(
                        text,
                        style: effectiveTextStyle
                        ?.copyWith(
                            color: _color,
                            decoration: _isHover ? TextDecoration.underline : null,
                            decorationColor: _color,
                        ),
                        // style: TextStyle(
                        //     color: _color,
                        //     decoration: _isHover ? TextDecoration.underline : null,
                        //     decorationColor: _color,
                        // ),
                    ),
                ),
            )
        );
    }

    // @override
    // Widget build(BuildContext context) => StatefulBuilder(
    //     builder: (context, setState) => Text.rich(
    //         TextSpan(
    //             text: text,
    //             onEnter: (_) => setState(() => _isHover = true),
    //             onExit: (_) => setState(() => _isHover = false),
    //             recognizer: TapGestureRecognizer()..onTap = () async => launchLink(context, link ?? text),
    //             style: TextStyle(
    //                 color: _color,
    //                 decoration: _isHover ? TextDecoration.underline : TextDecoration.none,
    //                 decorationColor: _color,
    //             ),
    //         ),
    //     ),
    // );
}

abstract final class OS {
    static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    static bool get isWeb => kIsWeb;
    static bool get isWebAndroid => kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    static bool get isWebIOS => kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
}
