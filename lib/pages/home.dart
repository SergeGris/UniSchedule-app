import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/schedule.dart';
import '../scheduleloader.dart';
import '../utils.dart';
import '../widgets/class_card.dart';

class HomePageContent extends ConsumerStatefulWidget {
    const HomePageContent({super.key, required this.schedule});

    final Schedule schedule;

    @override
    ConsumerState<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends ConsumerState<HomePageContent> {
    String plural(int n, List<String> variants) {
        final i = n % 10 == 1 && n % 100 != 11
            ? 0
            : n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20)
                ? 1
                : 2;

        return variants[i];
    }

    String timeToPrettyView(int hours, int minutes) {
        final ph = plural(hours, ['час',  'часа',  'часов']);
        final pm = plural(minutes, ['минута', 'минуты', 'минут']);

        if (hours > 0 && minutes > 0) {
            return '$hours $ph $minutes $pm';
        } else if (hours > 0) {
            return '$hours $ph';
        } else if (minutes > 0) {
            return '$minutes $pm';
        } else {
            return '';
        }
    }

    List<Class> getClassesForDate(DateTime date) {
        final day = date.weekday - 1;
        final weekParity = getWeekParity(date, widget.schedule);
        final week = widget.schedule.weeks[weekParity];

        if (day >= week.days.length
            || week.days[day].classes.isEmpty
            || (widget.schedule.studiesBegin?.isAfter(date) ?? false)
            || (widget.schedule.studiesEnd?.isBefore(date) ?? false)) {
            return [];
        }

        return week.days[day].classes;
    }

    @override
    Widget build(BuildContext context) {
        final date = DateTime.now();

        // Rebuild widget each minute.
        Timer(
            Duration(
                // Update when minute number changed.
                seconds: 60 - date.second
            ),
            () {
                // If widget is not mounted (i.e. we are on other page),
                // then do nothing, otherwise rebuild widget.
                if (mounted) {
                    setState(() {});
                }
            },
        );

        final time = TimeOfDay.fromDateTime(date);
        var showProgress = true;
        var initialClasses = getClassesForDate(date).where((c) => c.name != null);
        var pendingClasses = initialClasses.where((c) => c.end.isAfterThan(time)).toList();

        late String listTitle;
        String? listSubTitle;

        if (initialClasses.isEmpty) {
            listTitle = 'Свободный день';
        } else if (pendingClasses.isEmpty) {
            listTitle = 'Пары закончились';
        } else if (pendingClasses.isNotEmpty) {
            final untilBegin = pendingClasses[0].start.differenceInMinutes(time);

            if (untilBegin < 0) { // Пара уже началась и идёт
                final untilEnd = pendingClasses[0].end.differenceInMinutes(time);
                final hours   = untilEnd ~/ 60;
                final minutes = untilEnd % 60;

                listTitle = 'Идёт ' + (pendingClasses[0].type?.name.toLowerCase() ?? 'пара');
                listSubTitle = 'До конца ${timeToPrettyView(hours, minutes)}';
            } else {
                final hours   = untilBegin ~/ 60;
                final minutes = untilBegin % 60;

                if (pendingClasses.length == initialClasses.length) {
                    listTitle = 'Пары ещё не начались';
                } else {
                    listTitle = 'Перерыв';
                }

                if (hours == 0 && minutes == 0) {
                    listTitle = 'Пара началась';
                } else {
                    listSubTitle = 'До начала ${timeToPrettyView(hours, minutes)}';
                }
            }
        } else {
            listTitle = 'Сегодня пар больше нет';
        }

        if (pendingClasses.isEmpty) {
            var daysToSkip = 0;

            do {
                initialClasses = getClassesForDate(date.add(Duration(days: ++daysToSkip)));
            } while (initialClasses.isEmpty && daysToSkip < 30);

            pendingClasses = initialClasses.where((c) => c.name != null).toList();

            if (pendingClasses.isNotEmpty) {
                showProgress = false;
                listSubTitle = 'Ближайшие пары '
                + (daysToSkip == 1
                    ? 'завтра'
                    : (daysToSkip == 2
                        ? 'послезавтра'
                        : numberToWords(daysToSkip - 1) + ' ' + plural(daysToSkip - 1, ['день', 'дня', 'дней'])));
            } else {
                listSubTitle = 'В ближайший месяц пар нет';
            }
        }

        return ListView.separated(
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: pendingClasses.length + 1,
            itemBuilder: (context, index) => index == 0
            ? ListTile(
                title: Text(
                    listTitle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                subtitle: listSubTitle != null
                ? Text(
                    listSubTitle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                )
                : null,
            )
            : ClassCard(
                classes: pendingClasses,
                index: index - 1,
                number: pendingClasses[index - 1].number,
                showProgress: showProgress,
                horizontalMargin: 8.0,
                borderRadius: 8.0
            ),
            separatorBuilder: (context, index) => index != 0
            ? const Divider(
                indent: 16.0,
                endIndent: 16.0
            )
            : const SizedBox.shrink(),
        );

        // return Scaffold(
        //     appBar: AppBar(
        //         flexibleSpace: ListTile(

        //             title: Text(
        //                 listTitle,
        //                 textAlign: TextAlign.center,
        //                 overflow: TextOverflow.fade,
        //                 style: TextStyle(
        //                     color: Theme.of(context).colorScheme.primary,
        //                 ),
        //             ),
        //             subtitle: listSubTitle != null
        //             ? Text(
        //                 listSubTitle,
        //                 textAlign: TextAlign.center,
        //                 overflow: TextOverflow.fade,
        //                 style: TextStyle(
        //                     color: Theme.of(context).colorScheme.primary,
        //                 ),
        //             )
        //             : null,
        //         ),
        //     ),

        //     body: ListView.separated(
        //         padding: const EdgeInsets.only(top: 8.0),
        //         itemCount: pendingClasses.length,
        //         itemBuilder: (context, index) => ClassCard(
        //             classes: pendingClasses,
        //             index: index,
        //             number: index + 1 + initialClasses.length - pendingClasses.length, // Учитываем количество прошедших пар
        //             showProgress: showProgress,
        //             horizontalMargin: 8.0,
        //             borderRadius: 8.0
        //         ),
        //         separatorBuilder: (context, index) => const Divider(
        //             indent: 16.0,
        //             endIndent: 16.0
        //         ),
        //     ),

        //     // body: ListView(
        //     //     children: <Widget>[
        //     //         ...classes.mapIndexed(
        //     //             (c, index) => ClassCard(
        //     //                 classes: classes,
        //     //                 index: index,
        //     //                 number: index + 1 + initialClasses.length - classes.length, // Учитываем количество прошедших пар
        //     //                 showProgress: showProgress,
        //     //                 horizontalMargin: 8.0,
        //     //                 borderRadius: 8.0
        //     //             ),
        //     //         )
        //     //     ],
        //     // )
        // );
    }
}

class HomePage extends ConsumerWidget {
    const HomePage({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        return ScheduleLoader(
            (schedule) {
                return HomePageContent(schedule: schedule);
            }
        );
    }
}
